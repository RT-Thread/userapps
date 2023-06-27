#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.xmake/plugins/

for var in $(ls -d */); do
    rm -rf ~/.xmake/plugins/${var}
    cp -rf ${script_dir}/${var} ~/.xmake/plugins/
done
