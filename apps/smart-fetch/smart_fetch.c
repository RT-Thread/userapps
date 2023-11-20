/*
 * Copyright (c) 2023, Real-Thread Technology Co., Ltd
 *
 * SPDX-License-Identifier: GPL-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2023-06-06     Mr'Zhou      the first version
 */

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <getopt.h>
#include <sys/utsname.h>
#include <sys/statfs.h>
#include <sys/sysinfo.h>
#include "smart_fetch.h"
#include <string.h>

static void smart_fetch_print_info()
{
    printf("\033[20A \n");
    printf(RED " %s time: " NONE BLUE "%d-%d-%d " NONE GREEN "%d:%d:%d\n" NONE, RIGHT_MOVE, (1900 + smart_p->tm_year), ( 1 + smart_p->tm_mon), smart_p->tm_mday, (smart_p->tm_hour + 12), smart_p->tm_min, smart_p->tm_sec);
    printf("%s %s sysname: " NONE "%s  %s" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_info.sysname);
    printf("%s %s nodename: " NONE "%s %s" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_info.nodename);
    printf("%s %s release:  " NONE "%s %s" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_info.release);
    printf("%s %s version:  " NONE "%s %s" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_info.version);
    printf("%s %s machine:  " NONE "%s %s" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_info.machine);
    printf("%s %s domainname:  " NONE "%s %s" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_info.__domainname);
    printf("%s %s f_bsize:   " NONE "%s %u" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_block.f_bsize);
    printf("%s %s f_blocks:  " NONE "%s %u" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_block.f_blocks);
    printf("%s %s f_bfree:   " NONE "%s %u" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_block.f_bfree);
    printf("%s %s f_bavail:  " NONE "%s %u" NONE "\n",RIGHT_MOVE, smart_title_color, smart_info_color, smart_sys_block.f_bavail);
    printf("%s \n", RIGHT_MOVE);
    printf("%s \n", RIGHT_MOVE);
    printf("%s \n", RIGHT_MOVE);
    printf("%s \n", RIGHT_MOVE);
    printf("%s " RED "github id:" NONE FONT_FLICKER GREEN GITHUB_ID NONE "\n", RIGHT_MOVE);
    printf("%s \n", RIGHT_MOVE);
    printf(" %s" FONT_FLICKER BG_BLACK "   " BG_RED "   " BG_GREEN "   " BG_YELLOW "   " BG_BLUE "   " BG_PURPLE "   " BG_CYAN "   " BG_WHITE "   " NONE "\n", RIGHT_MOVE );
    printf(" %s" BG_BLACK "   " BG_RED "   " BG_GREEN "   " BG_YELLOW "   " BG_BLUE "   " BG_PURPLE "   " BG_CYAN "   " BG_WHITE "   " NONE "\n", RIGHT_MOVE);

}

static void smart_fetch_print_logo()
{
    printf("\n \
         \e[0;31m.oyssssssssssssssssssssssssssy+.\e[0m              \n    \
        \e[0;31m/yossssssss\e[0mrrrr\e[0;31msssss\e[0mrrrr\e[0;31msssssssoy+\e[0m               \n    \
       \e[0;31m:h/sssssssss\e[0mrrrr\e[0;31msss\e[0mrrrr\e[0;31msssssssssh+-\e[0m               \n    \
      \e[0;31mys.ssssssssss\e[0mrrrrrrr\e[0;31msssssssssssssss+-p\e[0m          \n    \
     \e[0;31mh+-sssssssssss\e[0mrrrr\e[0;31msssssssssssssssssss:h/\e[0m         \n    \
    \e[0;31mh+-ssssssssssss\e[0mrrrr\e[0;31mssssssssssssssssssss+a'\e[0m            \n    \
   \e[0;31m/dmsssssssssssss\e[0mrrrr\e[0;31msssssssssssssssssssssz8`\e[0m       \n    \
  \e[0;31mc/ysssssssssssssss\e[0m\e[5m\e[3;32mrt-thread\e[0m\e[0;31mssssssssssssssss-f'\e[0m        \n    \
 \e[0;31mp/osssss\e[0mttttttttttttt\e[0;31mssssss\e[0mtttttttttttt\e[0;31msssss+j;\e[0m     \n    \
 \e[0;31mp/osssss\e[0mttttttttttttt\e[0;31mssssss\e[0mttttttttttttt\e[0;31msssss+j;\e[0m        \n    \
  \e[0;31mc/yssssssss\e[0mttttt\e[0;31mssssssssssssss\e[0mttttt\e[0;31mssssssss-k/\e[0m     \n    \
  \e[0;31m/dmssssssss\e[0mttttt\e[0;31mssssssssssssss\e[0mttttt\e[0;31msssssss*c'\e[0m      \n    \
   \e[0;31mh+-sssssss\e[0mttttt\e[0;31mssssssssssssss\e[0mttttt\e[0;31mssssss+a'\e[0m           \n    \
    \e[0;31mh+-ssssss\e[0mttttt\e[0;31mssssssssssssss\e[0mttttt\e[0;31msssss:h/\e[0m            \n    \
     \e[0;31mys.sssss\e[0mttttt\e[0;31mssssssssssssss\e[0mttttt\e[0;31mssss+-p\e[0m         \n    \
      \e[0;31m:h/ssss\e[0mttttt\e[0;31mssssssssssssss\e[0mttttt\e[0;31msssh+-\e[0m          \n    \
       \e[0;31m/yosssssssssssssssssssssssssssssoy+\e[0m             \n    \
        \e[0;31m.oysssssssssssssssssssssssssssy+.\e[0m              \n    \
    ");
}

void smart_fetch_get_time()
{
    time_t timep;
    time(&timep);
    smart_p = localtime(&timep);
}

int smart_fetch_get_utsname()
{
    memset(&smart_sys_info, '\0', sizeof(smart_sys_info));
    if(uname(&smart_sys_info) != -1)
    {
        return SUCCESS_SYS_INFO;
    }
    return ERROR_SYS_INFO;
}

int smart_fetch_get_statfs()
{
    if(statfs(smart_sys_path,&smart_sys_block) != -1)
    {
        return SUCCESS_SYS_INFO;
    }
    return ERROR_SYS_INFO;
}

int smart_fetch_get_memory()
{
    char buffer[1024];
    FILE *fp;
    fp = popen("free", "r");
    if(fp < 0)
    {
        return ;
    }
    while(fgets(buffer , sizeof(buffer), fp) != NULL)
    {
        printf("%s", buffer);
    }
    pclose(fp);
    return SUCCESS_SYS_INFO;
}

static void smart_fetch_color_parser(int b_font,char *t_color)
{
    char color[16];
    if(t_color == NULL)
    {
        return ;
    }
    memset(color, '\0', sizeof(color));
    if(smart_bold_font != 0)
    {
        if((strcmp(t_color,"BLACK")) == 0)
        {
            strcpy(color,L_BLACK);
        }
        else if((strcmp(t_color,"RED")) == 0)
        {
            strcpy(color,L_RED);
        }
        else if((strcmp(t_color,"GREEN")) == 0)
        {
            strcpy(color,L_GREEN);
        }
        else if((strcmp(t_color,"YELLOW")) == 0)
        {
            strcpy(color,YELLOW);
        }
        else if((strcmp(t_color,"BLUE")) == 0)
        {
            strcpy(color,L_BLUE);
        }
        else if((strcmp(t_color,"PURPLE")) == 0)
        {
            strcpy(color,L_PURPLE);
        }
        else if((strcmp(t_color,"CYAN")) == 0)
        {
            strcpy(color,L_CYAN);
        }
        else if((strcmp(t_color,"WHITE")) == 0)
        {
            strcpy(color,WHITE);
        }
        else
        {
            strcpy(color,L_RED);
        }

    }
    else
    {
        if((strcmp(t_color,"BLACK")) == 0)
        {
            strcpy(color,BLACK);
        }
        else if((strcmp(t_color,"RED")) == 0)
        {
            strcpy(color,RED);
        }
        else if((strcmp(t_color,"GREEN")) == 0)
        {
            strcpy(color,GREEN);
        }
        else if((strcmp(t_color,"YELLOW")) == 0)
        {
            strcpy(color,BROWN);
        }
        else if((strcmp(t_color,"BLUE")) == 0)
        {
            strcpy(color,BLUE);
        }
        else if((strcmp(t_color,"PURPLE")) == 0)
        {
            strcpy(color,PURPLE);
        }
        else if((strcmp(t_color,"CYAN")) == 0)
        {
            strcpy(color,CYAN);
        }
        else if((strcmp(t_color,"WHITE")) == 0)
        {
            strcpy(color,GRAY);
        }
        else
        {
            strcpy(color,GREEN);
        }
    }
    memset(t_color, '\0', sizeof(t_color));
    strcpy(t_color, color);
}

static void smart_fetch_color_deal()
{
    smart_fetch_color_parser(smart_bold_font, smart_title_color);
    smart_fetch_color_parser(smart_bold_font, smart_info_color);
}

static void smart_fetch_help()
{
    printf("\t\tsmart_fetch help\n");
    printf("\t\t cmd\texplain\n");
    printf("\t\t -t \t:update titile color\n");
    printf("\t\t -c \t:update information color\n");
    printf("\t\t -d \t:disable info\n");
    printf("\t\t -b \t:blod font\n");
    printf("\t\t example : smart-fetch -b -c YELLOW -t GREEN \n");
}

int smart_fetch_param_parser(int argc, char **argv)
{
    char *opt;
    int idx;
    if (argc < 1)
    {
        return SUCCESS_SYS_INFO;
    }
    memset(smart_title_color, '\0', sizeof(smart_title_color));
    memset(smart_info_color, '\0', sizeof(smart_info_color));
    while((idx = getopt_long(argc, argv, smart_short_option, smart_long_option, NULL)) != EOF)
    {
        switch(idx)
        {
        case 't' :
            opt = optarg;
            strcpy(smart_title_color, opt);
            break;
        case 'c' :
            opt = optarg;
            strcpy(smart_info_color, opt);
            break;
        case 'd' :
            opt = optarg;
            break;
        case 'b' :
            smart_bold_font = 1;
            break;
        case 'h' :
            smart_fetch_help();
            return ;
        default :
            break;
        }
    }
    smart_fetch_color_deal();
    smart_fetch_get_time();
    smart_fetch_get_utsname();
    smart_fetch_get_statfs();
    smart_fetch_print_logo();
    smart_fetch_print_info();
    return SUCCESS_SYS_INFO;
}

int main(int argc, char **argv)
{
    smart_fetch_param_parser(argc, argv);
    return 0;
}
