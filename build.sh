#!/bin/bash

# Detects the best architecture version supported by the CPU
detect_arch() {
    local features
    features=$(grep -oP 'flags\s*:\s*\K.*' /proc/cpuinfo | head -n 1)

    if echo "$features" | grep -q 'avx2'; then
        echo "x86-64-v4"
    elif echo "$features" | grep -q 'sse4_2'; then
        echo "x86-64-v3"
    elif echo "$features" | grep -q 'sse4_1'; then
        echo "x86-64-v2"
    else
        echo "no support for x86-64-v2, v3, or v4"
        return 1
    fi
}

# Run architecture detection
arch=$(detect_arch)

if [[ "$arch" == "x86-64-v4" || "$arch" == "x86-64-v3" || "$arch" == "x86-64-v2" ]]; then
    echo "Compiling for $arch"
    CC=clang CXX=clang++ CFLAGS="-O3 -march=${arch}" CXXFLAGS="-O3 -march=${arch}" ./configure --enable-win64
    make -j $(nproc)
else
    echo "Compilation not supported."
fi
