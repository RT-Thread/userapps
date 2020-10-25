#ifndef __VI_UTILS_H__
#define __VI_UTILS_H__

#include <rtthread.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>
#include <dfs_posix.h>
#ifdef RT_USING_POSIX
#include <dfs_poll.h>
#include <sys/types.h>
#endif

#include "optparse.h"

#define FAST_FUNC
#define BB_VER "1.29.3"
#define BB_BT "rtt"
#define MAIN_EXTERNALLY_VISIBLE
#define NOINLINE
#define xmalloc malloc
#define xrealloc realloc
#define xstrdup strdup
#define fflush_all() fflush(NULL)
#define bb_putchar putchar
#define bb_error_msg_and_die(...) printf(__VA_ARGS__)

#ifdef VI_MAX_LEN
#define CONFIG_FEATURE_VI_MAX_LEN VI_MAX_LEN
#else
#define CONFIG_FEATURE_VI_MAX_LEN 4096
#endif

#define ENABLE_FEATURE_EDITING_ASK_TERMINAL 0
#define ENABLE_FEATURE_LESS_ASK_TERMINAL 0

#ifdef VI_ENABLE_VI_ASK_TERMINAL
#define ENABLE_FEATURE_VI_ASK_TERMINAL 1
#define IF_FEATURE_VI_ASK_TERMINAL(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_ASK_TERMINAL 0
#define IF_FEATURE_VI_ASK_TERMINAL(...)
#endif

#ifdef VI_ENABLE_COLON
#define ENABLE_FEATURE_VI_COLON 1
#define IF_FEATURE_VI_COLON(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_COLON 0
#define IF_FEATURE_VI_COLON(...)
#endif

#ifdef VI_ENABLE_SEARCH
#define ENABLE_FEATURE_VI_SEARCH 1
#define IF_FEATURE_VI_SEARCH(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_SEARCH 0
#define IF_FEATURE_VI_SEARCH(...)
#endif

#ifdef VI_ENABLE_READONLY
#define ENABLE_FEATURE_VI_READONLY 1
#define IF_FEATURE_VI_READONLY(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_READONLY 0
#define IF_FEATURE_VI_READONLY(...)
#endif

#ifdef VI_ENABLE_SET
#define ENABLE_FEATURE_VI_SET 1
#define IF_FEATURE_VI_SET(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_SET 0
#define IF_FEATURE_VI_SET(...)
#endif

#ifdef VI_ENABLE_SETOPTS
#define ENABLE_FEATURE_VI_SETOPTS 1
#define IF_FEATURE_VI_SETOPTS(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_SETOPTS 0
#define IF_FEATURE_VI_SETOPTS(...)
#endif

#ifdef VI_ENABLE_WIN_RESIZE
#define ENABLE_FEATURE_VI_WIN_RESIZE 1
#define IF_FEATURE_VI_WIN_RESIZE(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_WIN_RESIZE 0
#define IF_FEATURE_VI_WIN_RESIZE(...)
#endif

#ifdef VI_ENABLE_YANKMARK
#define ENABLE_FEATURE_VI_YANKMARK 1
#define IF_FEATURE_VI_YANKMARK(...) __VA_ARGS__
#define ARRAY_SIZE(x) ((unsigned)(sizeof(x) / sizeof((x)[0])))
#else
#define ENABLE_FEATURE_VI_YANKMARK 0
#define IF_FEATURE_VI_YANKMARK(...)
#endif

#ifdef VI_ENABLE_DOT_CMD
#define ENABLE_FEATURE_VI_DOT_CMD 1
#define IF_FEATURE_VI_DOT_CMD(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_DOT_CMD 0
#define IF_FEATURE_VI_DOT_CMD(...)
#endif

#ifdef VI_ENABLE_UNDO
#define ENABLE_FEATURE_VI_UNDO 1
#define IF_FEATURE_VI_UNDO(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_UNDO 0
#define IF_FEATURE_VI_UNDO(...)
#endif

#ifdef VI_ENABLE_UNDO_QUEUE
#define ENABLE_FEATURE_VI_UNDO_QUEUE 1
#define IF_FEATURE_VI_UNDO_QUEUE(...) __VA_ARGS__
#define CONFIG_FEATURE_VI_UNDO_QUEUE_MAX  VI_UNDO_QUEUE_MAX
#else
#define ENABLE_FEATURE_VI_UNDO_QUEUE 0
#define IF_FEATURE_VI_UNDO_QUEUE(...)
#endif

#ifdef VI_ENABLE_SEARCH
#define ENABLE_FEATURE_VI_SEARCH 1
#define IF_FEATURE_VI_SEARCH(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_SEARCH 0
#define IF_FEATURE_VI_SEARCH(...)
#endif

#ifdef VI_ENABLE_REGEX_SEARCH
#define ENABLE_FEATURE_VI_REGEX_SEARCH 1
#define IF_FEATURE_VI_REGEX_SEARCH(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_REGEX_SEARCH 0
#define IF_FEATURE_VI_REGEX_SEARCH(...)
#endif

#ifdef VI_ENABLE_8BIT
#define ENABLE_FEATURE_VI_8BIT 1
#define IF_FEATURE_VI_8BIT(...) __VA_ARGS__
#else
#define ENABLE_FEATURE_VI_8BIT 0
#define IF_FEATURE_VI_8BIT(...)
#endif

#define SET_PTR_TO_GLOBALS(x) do { \
	(*(struct globals**)&ptr_to_globals) = (void*)(x); \
	barrier(); \
} while (0)
#define FREE_PTR_TO_GLOBALS() do { \
	if (ENABLE_FEATURE_CLEAN_UP) { \
		free(ptr_to_globals); \
	} \
} while (0)

/* "Keycodes" that report an escape sequence.
 * We use something which fits into signed char,
 * yet doesn't represent any valid Unicode character.
 * Also, -1 is reserved for error indication and we don't use it. */
enum {
	KEYCODE_UP       =  -2,
	KEYCODE_DOWN     =  -3,
	KEYCODE_RIGHT    =  -4,
	KEYCODE_LEFT     =  -5,
	KEYCODE_HOME     =  -6,
	KEYCODE_END      =  -7,
	KEYCODE_INSERT   =  -8,
	KEYCODE_DELETE   =  -9,
	KEYCODE_PAGEUP   = -10,
	KEYCODE_PAGEDOWN = -11,
	// -12 is reserved for Alt/Ctrl/Shift-TAB
#if 0
	KEYCODE_FUN1     = -13,
	KEYCODE_FUN2     = -14,
	KEYCODE_FUN3     = -15,
	KEYCODE_FUN4     = -16,
	KEYCODE_FUN5     = -17,
	KEYCODE_FUN6     = -18,
	KEYCODE_FUN7     = -19,
	KEYCODE_FUN8     = -20,
	KEYCODE_FUN9     = -21,
	KEYCODE_FUN10    = -22,
	KEYCODE_FUN11    = -23,
	KEYCODE_FUN12    = -24,
#endif
	/* Be sure that last defined value is small enough
	 * to not interfere with Alt/Ctrl/Shift bits.
	 * So far we do not exceed -31 (0xfff..fffe1),
	 * which gives us three upper bits in LSB to play with.
	 */
	//KEYCODE_SHIFT_TAB  = (-12)         & ~0x80,
	//KEYCODE_SHIFT_...  = KEYCODE_...   & ~0x80,
	//KEYCODE_CTRL_UP    = KEYCODE_UP    & ~0x40,
	//KEYCODE_CTRL_DOWN  = KEYCODE_DOWN  & ~0x40,
	KEYCODE_CTRL_RIGHT = KEYCODE_RIGHT & ~0x40,
	KEYCODE_CTRL_LEFT  = KEYCODE_LEFT  & ~0x40,
	//KEYCODE_ALT_UP     = KEYCODE_UP    & ~0x20,
	//KEYCODE_ALT_DOWN   = KEYCODE_DOWN  & ~0x20,
	KEYCODE_ALT_RIGHT  = KEYCODE_RIGHT & ~0x20,
	KEYCODE_ALT_LEFT   = KEYCODE_LEFT  & ~0x20,

	KEYCODE_CURSOR_POS = -0x100, /* 0xfff..fff00 */
	/* How long is the longest ESC sequence we know?
	 * We want it big enough to be able to contain
	 * cursor position sequence "ESC [ 9999 ; 9999 R"
	 */
	KEYCODE_BUFFER_SIZE = 16
};

typedef enum {FALSE = 0, TRUE = !FALSE} bool;
typedef int smallint;
typedef unsigned smalluint;

#if defined(_MSC_VER) || defined(__CC_ARM)
#define ALIGN1
#define barrier()
#define	F_OK	0
#define	R_OK	4
#define	W_OK	2
#define	X_OK	1
int isblank(int ch);
int isatty (int  fd);
#else
#define ALIGN1 __attribute__((aligned(1)))
/* At least gcc 3.4.6 on mipsel system needs optimization barrier */
#define barrier() __asm__ __volatile__("":::"memory")
#endif

#define ENABLE_DEBUG 1
#ifdef VI_ENABLE_COLON
char* FAST_FUNC xstrndup(const char *s, int n);
char* last_char_is(const char *s, int c);
#endif

#ifdef VI_ENABLE_SETOPTS
char* FAST_FUNC skip_whitespace(const char *s);
char* FAST_FUNC skip_non_whitespace(const char *s);
#endif

#ifdef RT_USING_POSIX
void bb_perror_msg(const char *s, ...);
int safe_read(int fd, void *buf, size_t count);
int safe_poll(struct pollfd *ufds, nfds_t nfds, int timeout);
ssize_t FAST_FUNC full_write(int fd, const void *buf, size_t len);
ssize_t FAST_FUNC full_read(int fd, void *buf, size_t len);
#else
int wait_read(int fd, void *buf, size_t len, int timeout);
#define full_read read
#define full_write write
#endif

#ifdef VI_ENABLE_WIN_RESIZE
int FAST_FUNC get_terminal_width_height(int fd, unsigned *width, unsigned *height);
#endif

#ifdef VI_ENABLE_SEARCH
char* FAST_FUNC strchrnul(const char *s, int c);
#endif

#ifdef __GNUC__
int strncasecmp(const char *s1, const char *s2, size_t n);
int strcasecmp (const char *s1, const char *s2);
char * strdup(const char *s);
#endif

void* xzalloc(size_t size);
void bb_show_usage(void);
int64_t read_key(int fd, char *buffer, int timeout);
void *memrchr(const void* ptr, int ch, size_t pos);

extern struct finsh_shell *shell;

#endif
