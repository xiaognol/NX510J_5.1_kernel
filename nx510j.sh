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
ROOT_DIR=$PWD
IMAGE_OUT=$PWD/obj/KERNEL_OBJ/arch/arm64/boot/Image
IMAGE_OUT_DIR=$PWD/obj/bootimg_out
KERNEL_MODULES_INSTALL=$PWD/obj/lib/modules/
MODULES_FINAL_OUT=$KERNEL_MODULES_INSTALL../../system/lib/modules/
PATCH_SYSTEM=$IMAGE_OUT_DIR/KERNEL_MAKE/PATCH/system

rm -rf $PATCH_SYSTEM/
rm -rf $IMAGE_OUT_DIR/
rm -rf $KERNEL_MODULES_INSTALL
rm -rf $MODULES_FINAL_OUT
##############################################################################
# make zImage
##############################################################################
mkdir -p ./obj/KERNEL_OBJ/
make -j4 O=./obj/KERNEL_OBJ/ msm8994_NX510J_official_defconfig
make -j4 O=./obj/KERNEL_OBJ/
make -j4 O=./obj/KERNEL_OBJ/ modules && \
make -j4 O=./obj/KERNEL_OBJ/ INSTALL_MOD_PATH=$KERNEL_MODULES_INSTALL modules_install

if [ ! -e "$MODULES_FINAL_OUT" ]; then \
mkdir -p $MODULES_FINAL_OUT
fi
if [ ! -e "$PATCH_SYSTEM" ]; then \
mkdir -p $PATCH_SYSTEM/lib/modules/qca_cld
fi

    mdpath=`find $KERNEL_MODULES_INSTALL -type f -name modules.order`;\
    if [ "$mdpath" != "" ];then\
        mpath=`dirname $mdpath`;\
        ko=`find $mpath/kernel -type f -name *.ko`;\
        for i in $ko; do "$CROSS_COMPILE"strip --strip-unneeded $i;\
        mv $i $MODULES_FINAL_OUT; done;\
        rm -rf $mpath; \
    fi
##############################################################################	
# MODULES COPY
##############################################################################

cp -r $MODULES_FINAL_OUT../../ $PATCH_SYSTEM/ 
mv $PATCH_SYSTEM/lib/modules/wlan.ko $PATCH_SYSTEM/lib/modules/qca_cld/qca_cld_wlan.ko		
##############################################################################
# Copy Kernel Image
##############################################################################
cp -r $ROOT_DIR/KERNEL_MAKE $IMAGE_OUT_DIR
#chmod 777 $IMAGE_OUT_DIR/mktools/files
cp -f $IMAGE_OUT $IMAGE_OUT_DIR/KERNEL_MAKE/mktools/files/zImage
#mv $IMAGE_OUT $IMAGE_OUT_DIR/KERNEL_MAKE/mktools/files/Image $IMAGE_OUT $IMAGE_OUT_DIR/KERNEL_MAKE/mktools/files/zImage
##############################################################################
$IMAGE_OUT_DIR/KERNEL_MAKE/mktools/mkboot $IMAGE_OUT_DIR/KERNEL_MAKE/mktools/files $IMAGE_OUT_DIR/KERNEL_MAKE/PATCH/boot.img

##############################################################################
# ZIP&SIGH PATCH
##############################################################################
cd $IMAGE_OUT_DIR/KERNEL_MAKE/PATCH
zip -r boot_patch.zip *
cd $ROOT_DIR
java -jar $IMAGE_OUT_DIR/KERNEL_MAKE/mktools/sign/signapk.jar -w $IMAGE_OUT_DIR/KERNEL_MAKE/mktools/sign/security/testkey.x509.pem $IMAGE_OUT_DIR/KERNEL_MAKE/mktools/sign/security/testkey.pk8 $IMAGE_OUT_DIR/KERNEL_MAKE/PATCH/boot_patch.zip $ROOT_DIR/obj/boot_patch_signed.zip

