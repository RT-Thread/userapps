/*
 * Copyright (c) 2006-2020, RT-Thread Development Team
 *
 * SPDX-License-Identifier: GPL-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2023-9-14      zbtrs        The first version
 */


#include <stdio.h>
#include <unistd.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>

#define rtt_screen_width 480
#define rtt_screen_height 272


int main (int argc, char *argv[]) 
{
    int ret = -1;
    AVFormatContext *pFormatCtx = NULL; 
    int videoStream;
    AVCodecParameters *pCodecParameters = NULL; 
    AVCodecContext *pCodecCtx = NULL;
    AVCodec *pCodec = NULL;
    AVFrame *pFrame = NULL;
    AVPacket packet;
    

    SDL_Rect rect;
    SDL_Window *win = NULL;
    SDL_Renderer *renderer = NULL;
    SDL_Texture *texture = NULL;

    if(( argc != 2 ))
    {
        printf("error input arguments!\n");
        return(1);
    }

    // 默认窗口大小
    int w_width  = rtt_screen_width;
    int w_height = rtt_screen_height;

    // use dummy video driver
    SDL_setenv("SDL_VIDEODRIVER","rtt",1);
    //Initialize SDL
    if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
    {
        printf( "SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        return -1;
    }

    // 打开输入文件
    if (avformat_open_input(&pFormatCtx, argv[1], NULL, NULL) != 0) 
    {
        printf("Couldn't open video file!: %s\n", argv[1]);
        goto __exit; 
    }

    // 找到视频流
    videoStream = av_find_best_stream(pFormatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (videoStream == -1) 
    {
        printf("Din't find a video stream!\n");
        goto __exit;// Didn't find a video stream
    }

    // 流参数
    pCodecParameters = pFormatCtx->streams[videoStream]->codecpar;

    // 获取解码器
    pCodec = avcodec_find_decoder(pCodecParameters->codec_id);
    if (pCodec == NULL) 
    {
        printf("Unsupported codec!\n");
        goto __exit; // Codec not found
    }

    // 初始化一个编解码上下文
    pCodecCtx = avcodec_alloc_context3(pCodec);
    if (avcodec_parameters_to_context(pCodecCtx, pCodecParameters) != 0) 
    {
        printf("Couldn't copy codec context\n");
        goto __exit;// Error copying codec context
    }

    // 打开解码器
    if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0) 
    {
        printf("Failed to open decoder!\n");
        goto __exit; // Could not open codec
    }

    // Allocate video frame
    pFrame = av_frame_alloc();
    if (NULL == pFrame) {
        printf("av_frame_alloc error\n");
        goto __exit;
    }

    w_width = pCodecCtx->width;
    w_height = pCodecCtx->height;

    // 创建窗口
    win = SDL_CreateWindow("Media Player",
                            SDL_WINDOWPOS_UNDEFINED,
                            SDL_WINDOWPOS_UNDEFINED,
                            w_width, w_height,
                            SDL_WINDOW_SHOWN );
    if (!win) 
    {
        printf("Failed to create window by SDL\n");
        goto __exit;
    }

    // 创建渲染器
    renderer = SDL_CreateRenderer(win, -1, 0);
    if (!renderer) 
    {
        printf("Failed to create Renderer by SDL\n");
        goto __exit;
    }

    // 创建纹理
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_IYUV,
                                SDL_TEXTUREACCESS_STREAMING,
                                w_width,
                                w_height);
    if (!texture) {
        printf("SDL_CreateTexture Error: %s\n",SDL_GetError());
        goto __exit;
    }

    int receive_frame_ret = 0;

    // 读取数据
    while (av_read_frame(pFormatCtx, &packet) >= 0) 
    {
        if (packet.stream_index == videoStream) 
        {
            // 解码
            avcodec_send_packet(pCodecCtx, &packet);
            while (receive_frame_ret = avcodec_receive_frame(pCodecCtx, pFrame) == 0) 
            {
                if (receive_frame_ret < 0) {
                    printf("avcodec_receive_frame error: %d\n",receive_frame_ret);
                    goto __exit;
                }
                SDL_UpdateYUVTexture(texture, NULL,
                                    pFrame->data[0], pFrame->linesize[0],
                                    pFrame->data[1], pFrame->linesize[1],
                                    pFrame->data[2], pFrame->linesize[2]);

                // set size of Window
                rect.x = 0;
                rect.y = 0;
                rect.w = pCodecCtx->width;
                rect.h = pCodecCtx->height;

                SDL_RenderClear(renderer);
                SDL_RenderCopy(renderer, texture, NULL, &rect);
                SDL_RenderPresent(renderer);
            }
        }

        av_packet_unref(&packet);
    }

    __exit:

    if (pFrame) 
    {
        av_frame_free(&pFrame);
    }

    if (pCodecCtx) 
    {
        avcodec_close(pCodecCtx);
    }

    if (pCodecParameters) 
    {
        avcodec_parameters_free(&pCodecParameters);
    }

    if (pFormatCtx) 
    {
        avformat_close_input(&pFormatCtx);
    }

    if (win) 
    {
        SDL_DestroyWindow(win);
    }

    if (renderer) 
    {
        SDL_DestroyRenderer(renderer);
    }

    if (texture) 
    {
        SDL_DestroyTexture(texture);
    }

    SDL_Quit();

    return ret;
}