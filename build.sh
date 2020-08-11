#!/bin/bash

# This script builds openssl+libcurl+nghttp2+ngtcp2+nghttp3 libraries for Android
#
# Credits:
# Bachue Zhou, @bachue
#   https://github.com/bachue/Build-cURL-nghttp2-nghttp3-ngtcp2-android
#

################################################
# EDIT this section to Select Default Versions #
################################################

LIBCURL="7.71.1"    # https://curl.haxx.se/download.html
NGHTTP2="1.42.0"    # https://nghttp2.org/

# Global flags
engine=""
buildnghttp2="-n"
buildngtcp2="-n"
buildnghttp3="-n"
disablebitcode=""
colorflag=""

# Formatting
default="\033[39m"
wihte="\033[97m"
green="\033[32m"
red="\033[91m"
yellow="\033[33m"

bold="\033[0m${white}\033[1m"
subbold="\033[0m${green}"
normal="${white}\033[0m"
dim="\033[0m${white}\033[2m"
alert="\033[0m${red}\033[1m"
alertdim="\033[0m${red}\033[2m"

usage ()
{
    echo
    echo -e "${bold}Usage:${normal}"
    echo
    echo -e "  ${subbold}$0${normal} [-c ${dim}<curl version>${normal}] [-n ${dim}<nghttp2 version>${normal}] [-d] [-e] [-x] [-h]"
    echo
    echo "         -c <version>   Build curl version (default $LIBCURL)"
    echo "         -n <version>   Build nghttp2 version (default $NGHTTP2)"
    echo "         -d             Compile without HTTP2 support"
    echo "         -e             Compile with OpenSSL engine support"
    echo "         -b             Compile without bitcode"
    echo "         -x             No color output"
    echo "         -h             Show usage"
    echo
    exit 127
}

while getopts "o:c:n:dexh\?" o; do
    case "${o}" in
        c)
            LIBCURL="${OPTARG}"
            ;;
        n)
            NGHTTP2="${OPTARG}"
            ;;
        d)
            buildnghttp2=""
            ;;
        e)
            engine="-e"
            ;;
        b)
            disablebitcode="-b"
            ;;
        x)
            bold=""
            subbold=""
            normal=""
            dim=""
            alert=""
            alertdim=""
            colorflag="-x"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

## Welcome
echo -e "${bold}Build-OpenSSL-cURL${dim}"
echo "This script builds OpenSSL, nghttp2 and libcurl for MacOS (OS X), iOS and tvOS devices."
echo "Targets: x86_64, armv7, armv7s, arm64 and arm64e"
echo

set -e

## OpenSSL Build
echo
cd openssl
echo -e "${bold}Building OpenSSL${normal}"
./openssl-build.sh $engine $colorflag
cd ..
