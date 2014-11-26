IOTrackerOnWeb
==============

An HTTP/File I/O tracker tweak for iOS. Just inject the dylib to target App and view log on http://iPhone.local:8080

# How to Build

~~~sh
# make libCocoaHTTPServer.a
cd CocoaHTTPServer/
make && make headers
cd ..

# make tweak
make clean package
make install #THEOS_DEVICE_IP=iPhone.local
~~~

# Usage

Change [IOTracker.plist](https://github.com/upbit/IOTrackerOnWeb/blob/master/IOTracker.plist) for Tweak inject process.

IOTracker will listen on 8080, so access `http://<ip_address>:8080` in Chrome:

![screenshot](https://raw.github.com/upbit/IOTrackerOnWeb/master/screenshot.png)
