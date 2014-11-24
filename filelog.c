/************************************************
 *
 *	A simple FileLog library (2010)
 *
 ************************************************/
#include "filelog.h"
#include <string.h>
#include <time.h>

#define MIN(x, y) ( (x<y) ? (x):(y) )

#define MAX_LINES 4096
 
static inline
int get_file_lines(logfile_t *pLogFile)
{
	if (pLogFile == NULL) return -1;
	
	FILE *fp;
	char *buf[MAX_LINES];
	register int lcount = 0;
	
	fp = fopen(pLogFile->szLogPath, "r");
	fseek(fp, 0, SEEK_SET);
	
	while (fgets((char*)&buf[0], MAX_LINES, fp) != NULL) lcount++;
	
	fclose(fp);
	
	return lcount;
}

// 初始化
int init_filelog(logfile_t *pLogFile, const char *szLogPath, const unsigned long ulMaxLognum)
{
	if ((pLogFile == NULL) || (szLogPath == NULL)) return -1;
	
	int iLen;
	logfile_t *pstlog = pLogFile;
	
	memset(pstlog, 0, sizeof(logfile_t));
	
	iLen = MIN(strlen(szLogPath), MAX_PATH_LEN-1);
	memcpy(pstlog->szLogPath, szLogPath, iLen);
	
	pstlog->fp = fopen(pstlog->szLogPath, "a+");
	if (pstlog->fp == NULL) return -2;
	
	pstlog->ulLogLines = get_file_lines(pstlog);
	pstlog->ulMaxLines = ulMaxLognum;
	
	return 0;
}

// 向 szBuffer 中写入时间信息
int get_time_str(char *szBuffer)
{
	if (szBuffer == NULL) return -1;
	
#if (LOG_TIME_LEVEL == 1)
	snprintf(szBuffer, MAX_TIME_LEN, "[%u] ", (unsigned int)time(NULL));
	return 0;
#else
	return -2;
#endif
}

// 滚卷日志文件
int rolling_log(logfile_t *pLogFile)
{
	if (pLogFile == NULL) return -1;
	
	int i;
	char szPathFrom[MAX_PATH_LEN+4];		// PATH+(.XX)
	char szPathTo[MAX_PATH_LEN+4];
	
	fclose(pLogFile->fp);
	
	for (i = 255; i >= 0; i--) {
		if (i != 0) {
			snprintf(szPathFrom, MAX_PATH_LEN+3, "%s.%d", pLogFile->szLogPath, i);
		} else {
			memcpy(szPathFrom, pLogFile->szLogPath, MAX_PATH_LEN);
		}
		
		if (access(szPathFrom, W_OK) == 0) {
			snprintf(szPathTo, MAX_PATH_LEN+3, "%s.%d", pLogFile->szLogPath, i+1);
			if (rename(szPathFrom, szPathTo) < 0) {
				goto rolling_end;
			}
		}
	}
	// reset log lines
	pLogFile->ulLogLines = 0;

rolling_end:
	pLogFile->fp = fopen(pLogFile->szLogPath, "a");
	if (pLogFile->fp == NULL)
		return -2;
	return 0;
}
