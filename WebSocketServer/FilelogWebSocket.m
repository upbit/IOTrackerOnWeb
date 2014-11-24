///
/// Modify from iSpyServer/shellWebSocket.xm (Apache License)
///   https://github.com/BishopFox/iSpy/blob/master/iSpyServer/shellWebSocket.xm
///
#import "FilelogWebSocket.h"
#import "FLogObjectiveC.h"

#import <sys/ioctl.h>

#define BUFSIZE (16384)
#define MAX_READ_FAILURES (3)

#ifndef MAX
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#endif

@implementation FilelogWebSocket

- (void)didOpen {
	[super didOpen];
	[self createSyslogWatch];
}

- (void)didReceiveMessage:(NSString *)msg {
	NSLog(@"WebSocket - CMD> %@", msg);
	const char *command = [msg cStringUsingEncoding:NSUTF8StringEncoding];
	write(self.masterPTY, &command[0], (size_t)[msg length]);
}

- (void)didClose {
	kill(self.childPID, SIGQUIT);
	kill(self.childPID, SIGTERM);
	kill(self.childPID, SIGKILL);
	sleep(1);

	int info;
	waitpid(self.childPID, &info, WNOHANG);

	NSLog(@"WebSocket - WebShell connection closed.");

	[super didClose];
}

//

- (int)forkNewPTY {
	// open a handle to a master PTY 
	if ((self.masterPTY = open("/dev/ptmx", O_RDWR | O_NOCTTY | O_NONBLOCK)) == -1) {
		NSLog(@"WebSocket - Could not open /dev/ptmx");
		return -11;
	}

	// establish proper ownership of PTY device
	if (grantpt(self.masterPTY) == -1) {
		NSLog(@"WebSocket - Could not grantpt()");
		return -12;	
	}

	// unlock slave PTY device associated with master PTY device
	if (unlockpt(self.masterPTY) == -1) {
		NSLog(@"WebSocket - Could not unlockpt()");
		return -13;
	}

	pid_t pid = fork();
	if (pid == 0) {
		if ((self.slavePTY = open(ptsname(self.masterPTY), O_RDWR | O_NOCTTY)) == -1) {
			NSLog(@"WebSocket - Could not open ptsname(%s)", ptsname(self.masterPTY));
			return -21;
		}

		// setup PTY and redirect stdin, stdout, stderr to it
		setsid();
		ioctl(self.slavePTY, TIOCSCTTY, 0);
		dup2(self.slavePTY, 0);		// stdin
		dup2(self.slavePTY, 1);		// stdout
		dup2(self.slavePTY, 2);		// stderr
		close(self.masterPTY);
		return 0;
	}

	// parent return pid
	return pid;
}

- (void)pipeDataToWebsocket {
	fd_set readSet;
	char buf[BUFSIZE];
	int numBytes, numFileDescriptors;
	static int failCount = 0;

	int fdMasterPTY = self.masterPTY;

	while (1) {
		numFileDescriptors = 0;
		FD_ZERO(&readSet);
		FD_SET(fdMasterPTY, &readSet);
		numFileDescriptors = MAX(numFileDescriptors, fdMasterPTY);
		
		// wait for something interesting to happen on a socket, or abort in case of error
		if (select(numFileDescriptors + 1, &readSet, NULL, NULL, NULL) == -1) {
			close([self masterPTY]);
			[self stop];
			return;
		}
		
		if (FD_ISSET(fdMasterPTY, &readSet)) {
			memset(buf, 0, BUFSIZE);
			if ((numBytes = read(fdMasterPTY, buf, BUFSIZE-1)) < 1) {
				// Ok, crap. A read(2) error occured.
				// Maybe the child process hasn't started yet.
				// Maybe the child process terminated.
				// Let's handle this a little gracefully.
				if (failCount >= MAX_READ_FAILURES) {
					close([self masterPTY]);
					[self stop];
					return;
				}

				sleep(1);

			} else {
				failCount = 0;

				// pass the data from the child process to the websocket, where it's passed to the browser.
				[self sendMessage:[NSString stringWithUTF8String:buf]];
			}
		}
	} 
}

- (void)createSyslogWatch {
	self.childPID = [self forkNewPTY];
	if (self.childPID < 0) {
		// fork PTY error
		[self stop];
		return;
	}

	if (self.childPID == 0) {
		// child process
		NSString *full_path = [[FLogObjectiveC sharedInstance] fullPath];
		const char *prog[] = { "/usr/bin/tail", "-n","100", "-f",[full_path cStringUsingEncoding:NSUTF8StringEncoding], NULL };
		const char *envp[] = { NULL };

		// replace current process with command
		execve((const char *)prog[0], (char **)prog, (char **)envp);

		// never returns if success
		return;
	}

	NSLog(@"fork child pid=%d success", (int)self.childPID);

	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		[self pipeDataToWebsocket];
	});

	return;
}

@end
