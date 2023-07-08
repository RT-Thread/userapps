/*
 * Copyright (c) 2023, Real-Thread Technology Co., Ltd
 *
 * SPDX-License-Identifier: GPL-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2023-06-06     Bernard      the first version
 */

#ifndef SMART_FETCH_H__
#define SMART_FETCH_H__

#define ERROR_SYS_INFO -1
#define SUCCESS_SYS_INFO 0

#define NONE                 "\e[0m"
#define BLACK                "\e[0;30m"
#define L_BLACK              "\e[1;30m"
#define RED                  "\e[0;31m"
#define L_RED                "\e[1;31m"
#define GREEN                "\e[0;32m"
#define L_GREEN              "\e[1;32m"
#define BROWN                "\e[0;33m"
#define YELLOW               "\e[1;33m"
#define BLUE                 "\e[0;34m"
#define L_BLUE               "\e[1;34m"
#define PURPLE               "\e[0;35m"
#define L_PURPLE             "\e[1;35m"
#define CYAN                 "\e[0;36m"
#define L_CYAN               "\e[1;36m"
#define GRAY                 "\e[0;37m"
#define WHITE                "\e[1;37m"

#define BG_BLACK             "\e[40m"
#define BG_RED               "\e[41m"
#define BG_GREEN             "\e[42m"
#define BG_YELLOW            "\e[43m"
#define BG_BLUE              "\e[44m"
#define BG_PURPLE            "\e[45m"
#define BG_CYAN              "\e[46m"
#define BG_WHITE             "\e[47m"

#define BOLD                 "\e[1m"
#define UNDERLINE            "\e[4m"
#define BLINK                "\e[5m"
#define REVERSE              "\e[7m"
#define HIDE                 "\e[8m"
#define CLEAR                "\e[2J"
#define CLRLINE              "\r\e[K"

#define RIGHT_MOVE           "\e[60C"
#define FONT_FLICKER         "\e[5m"

#define GITHUB_ID            "zmq810150896"
const struct option smart_long_option[] =
    {
        "title_color", 1, NULL, 't',
        "info_color", 1, NULL, 'c',
        "disable", 1, NULL, 'd',
        "bold", 0, NULL, 'b',
        "help", 0, NULL, 'h',
        {NULL, 0, NULL, 0}
    };

struct statfs smart_sys_block;
struct utsname smart_sys_info;
struct tm *smart_p;

const char const *smart_short_option = "t:c:d:bh";
int smart_bold_font = 0;
char smart_title_color[16]=RED;
char smart_info_color[16]=GREEN;
char smart_sys_path[256] = "/";

#endif  /*__SMART_FETCH_H__*/
