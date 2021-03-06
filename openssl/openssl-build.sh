#!/bin/bash

# This script downloads and builds the Android openSSL libraries

# Credits:
#
# Gustavo Genovese, @gcesarmza
#   https://github.com/gcesarmza/curl-android-ios/blob/master/curl-compile-scripts/build_Android.sh
# Bachue Zhou, @bachue
#   https://github.com/bachue/Build-cURL-nghttp2-nghttp3-ngtcp2-android

set -e

# Custom build options
CUSTOMCONFIG="enable-ssl-trace enable-tls1_3"

# Formatting
default="\033[39m"
wihte="\033[97m"
green="\033[32m"
red="\033[91m"
yellow="\033[33m"

bold="\033[0m${green}\033[1m"
subbold="\033[0m${green}"
archbold="\033[0m${yellow}\033[1m"
normal="${white}\033[0m"
dim="\033[0m${white}\033[2m"
alert="\033[0m${red}\033[1m"
alertdim="\033[0m${red}\033[2m"

# set trap to help debug build errors
trap 'echo -e "${alert}** ERROR with Build - Check /tmp/openssl*.log${alertdim}"; tail -n 3 /tmp/openssl*.log' INT TERM EXIT

NDK_VERSION="20b"
ANDROID_EABI_VERSION="4.9"
ANDROID_API_VERSION="21"

usage ()
{
    echo
    echo -e "${bold}Usage:${normal}"
    echo
    echo -e "  ${subbold}$0${normal} [-n ${dim}<NDK version>${normal}] [-a ${dim}<Android API version>${normal}] [-e ${dim}<EABI version>${normal}] [-x] [-h]"
    echo
    echo "         -n   NDK version (default $NDK_VERSION)"
    echo "         -a   NDK version (default $ANDROID_API_VERSION)"
    echo "         -e   EABI version (default $ANDROID_EABI_VERSION)"
    echo "         -x   disable color output"
    echo "         -h   show usage"
    echo
    trap - INT TERM EXIT
    exit 127
}

while getopts "n:a:e:xh\?" o; do
    case "${o}" in
        n)
            NDK_VERSION="${OPTARG}"
            ;;
        a)
            ANDROID_API_VERSION="${OPTARG}"
            ;;
        e)
            ANDROID_EABI_VERSION="${OPTARG}"
            ;;
        x)
            bold=""
            subbold=""
            normal=""
            dim=""
            alert=""
            alertdim=""
            archbold=""
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "ANDROID_NDK_HOME must be set" >&2
    exit 1
fi

buildAndroid()
{
    ARCH=$1
    TARGET=$2
    ANDROID_EABI=$3

    echo -e "${subbold}Building openssl for ${archbold}${ARCH}${dim}"
    ORIGINAL_PATH="$PATH"
    export PATH="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin:${ANDROID_NDK_HOME}/toolchains/${ANDROID_EABI}/prebuilt/linux-x86_64/bin:$PATH"
    pushd . > /dev/null
    cd openssl
    ./Configure no-shared no-asm ${TARGET} --prefix="/tmp/openssl-${ARCH}" --openssldir="/tmp/openssl-${ARCH}" $CUSTOMCONFIG -D__ANDROID_API__="$ANDROID_API_VERSION" &> "/tmp/openssl-${ARCH}.log"
    make -j8 >> "/tmp/openssl-${ARCH}.log" 2>&1
    make install_sw -j8 >> "/tmp/openssl-${ARCH}.log" 2>&1
    make clean >> "/tmp/openssl-${ARCH}.log" 2>&1

    popd > /dev/null
    export PATH="$ORIGINAL_PATH"
}

echo -e "${bold}Cleaning up${dim}"
rm -rf openssl /tmp/openssl-*

echo "Cloning openssl"
git clone --depth 1 -b OpenSSL_1_1_1g-quic-draft-29 https://github.com/tatsuhiro-t/openssl.git

echo "** Building OpenSSL 1.1.1 **"
buildAndroid x86 android-x86 "x86-${ANDROID_EABI_VERSION}"
buildAndroid x86_64 android-x86_64 "x86_64-${ANDROID_EABI_VERSION}"
buildAndroid arm android-arm "arm-linux-androideabi-${ANDROID_EABI_VERSION}"
buildAndroid arm64 android-arm64 "aarch64-linux-android-${ANDROID_EABI_VERSION}"

#reset trap
trap - INT TERM EXIT

echo -e "${normal}Done"
