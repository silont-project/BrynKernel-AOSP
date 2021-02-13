#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Android Kernel Build Script

# Install build package for debian based linux
# sudo apt install bc bash git-core gnupg build-essential \
#    zip curl make automake autogen autoconf autotools-dev libtool shtool python \
#    m4 gcc libtool zlib1g-dev flex bison libssl-dev

# Clone toolchain
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android-10.0.0_r41 --depth=1 stock
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android-10.0.0_r41 --depth=1 stock_32
#git clone https://github.com/arter97/arm64-gcc.git --depth=1 gcc64
#git clone https://github.com/arter97/arm32-gcc.git --depth=1 gcc32

# Clone AnyKernel3
git clone https://github.com/MumetNgoding/AnyKernel3.git -b master

#Download Clang
if [ ! -d clang ]; then
git clone https://github.com/GengKapak/GengKapak-clang --depth=1 kapak-clang
#    git clone https://github.com/silont-project/silont-clang.git --depth=1
#    git clone https://github.com/arter97/arm64-gcc.git --depth=1
#    git clone https://github.com/arter97/arm32-gcc.git --depth=1
#    git clone https://github.com/MumetNgoding/proton-clang.git --depth=1
fi

# Download libufdt
if [ ! -d libufdt ]; then
    wget https://android.googlesource.com/platform/system/libufdt/+archive/refs/tags/android-10.0.0_r41/utils.tar.gz
    mkdir -p libufdt
    tar xvzf utils.tar.gz -C libufdt
    rm utils.tar.gz
fi
