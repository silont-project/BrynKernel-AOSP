#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Android Kernel Build Script

# Add Depedency
#apt-get -y install bc build-essential zip curl libstdc++6 git default-jre default-jdk wget nano python-is-python3 gcc clang libssl-dev rsync flex bison && pip3 install telegram-send

# Clean Before Build
make mrproper

# Main environtment
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$KERNEL_DIR/AnyKernel3
CONFIG=onc_defconfig
CROSS_COMPILE="aarch64-linux-gnu-"
CROSS_COMPILE_ARM32="arm-linux-gnueabi-"
PATH=:"${KERNEL_DIR}/kapak-clang/bin:${PATH}:${KERNEL_DIR}/stock/bin:${PATH}:${KERNEL_DIR}/stock_32/bin:${PATH}"

# Export
export ARCH=arm64
export CROSS_COMPILE
export CROSS_COMPILE_ARM32

# Build start
START=$(date +%s)
make O=out $CONFIG
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-linux-android-

if ! [ -a $KERN_IMG ]; then
    echo "Build error!"
    exit 1
fi

cd $ZIP_DIR
make clean &>/dev/null
cd ..

# For MIUI Build
# Credit Adek Maulana <adek@techdro.id>
OUTDIR="$KERNEL_DIR/out/"
VENDOR_MODULEDIR="$KERNEL_DIR/AnyKernel3/modules/vendor/lib/modules"
STRIP="$KERNEL_DIR/stock/bin/$(echo "$(find "$KERNEL_DIR/stock/bin" -type f -name "aarch64-*-gcc")" | awk -F '/' '{print $NF}' |\
            sed -e 's/gcc/strip/')"
for MODULES in $(find "${OUTDIR}" -name '*.ko'); do
    "${STRIP}" --strip-unneeded --strip-debug "${MODULES}"
    "${OUTDIR}"/scripts/sign-file sha512 \
            "${OUTDIR}/certs/signing_key.pem" \
            "${OUTDIR}/certs/signing_key.x509" \
            "${MODULES}"
    find "${OUTDIR}" -name '*.ko' -exec cp {} "${VENDOR_MODULEDIR}" \;
done
echo -e "\n(i) Done moving modules"

cd $ZIP_DIR
cp $KERN_IMG zImage
make normal &>/dev/null
echo "Flashable zip generated under $ZIP_DIR."
echo "Please Wait ... Pushing ZIP Kernel to Telegram ..."

# Push to Telegram
END=$(date -u +%s)
DURATION=$(( END - START ))

cd $KERNEL_DIR/AnyKernel3
mv "$(echo SiLonT-*.zip)" "$KERNEL_DIR"
cd $KERNEL_DIR

# Get Telegram Script
wget https://raw.githubusercontent.com/MumetNgoding/Magic-Script/main/telegram
chmod +x telegram

# Add New Variable
KBUILD_BUILD_TIMESTAMP=$(date)
export KBUILD_BUILD_TIMESTAMP
CPU=$(lscpu | sed -nr '/Model name/ s/.*:\s*(.*) @ .*/\1/p')
HEAD_COMMIT="$(git rev-parse HEAD)"
GITHUB_URL="https://github.com/MumetNgoding/BrynKernel-AOSP/commits/"
COMMIT=$(git log --pretty=format:'%h: %s' -1)

# Get Script Source
./telegram -f "$(echo -e SiLonT-*.zip)" "$(echo ⚒️  [*BUILDING*] ⚒️  ️$'\n' HEAD MESSAGE:$'\n' $COMMIT $'\n' COMMIT URL: $'\n' ${GITHUB_URL}${HEAD_COMMIT} $'\n' DATE: $'\n' $KBUILD_BUILD_TIMESTAMP $'\n' BUILD USING: $'\n' $CPU $'\n' CC AUTHOR: $'\n' @BryanHafidzTorvalds $'\n' DURATION: $'\n' $DURATION Seconds $'\n' ⚒️  [*COMPLETE*] ⚒️  )"
rm "$(echo SiLonT-*.zip)"
rm telegram
echo -e "\n(!) Done Push to Telegram"
# Build end
