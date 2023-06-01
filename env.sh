#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export XMAKE_RCFILES=${script_dir}/tools/scripts/xmake.lua
export RT_XMAKE_LINK_TYPE="static"
