#!/bin/bash
###############################################################################
#
#                           Kernel Build Script 
#
###############################################################################
# 2011-10-24 effectivesky : modified
# 2010-12-29 allydrop     : created
###############################################################################
##############################################################################
# set toolchain
##############################################################################
export ARCH=arm64
# export CROSS_COMPILE=~/cm10.1/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin/arm-eabi-
export CROSS_COMPILE=/home/zjl/mokeel/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export TARGET_PRODUCT=NX510J

##############################################################################
# make zImage
##############################################################################
mkdir -p ./obj/KERNEL_OBJ/
make KCFLAGS=-mno-android -j4 O=./obj/KERNEL_OBJ/ msm8994_NX510J_official_defconfig
make  KCFLAGS=-mno-android -j4 O=./obj/KERNEL_OBJ/
##############################################################################
# Copy Kernel Image
##############################################################################
cp -f ./obj/KERNEL_OBJ/arch/arm64/boot/Image .
