#!/bin/bash
echored () {
	echo "${TEXTRED}$1${TEXTRESET}"
}
echogreen () {
	echo "${TEXTGREEN}$1${TEXTRESET}"
}
usage () {
  echo " "
  echored "USAGE:"
  echogreen "ARCH=          (Default: arm) (Valid Arch values: arm, arm64, aarch64, x86, i686, x64, x86_64)"
  echogreen "VER=           (Default: 8.30)"
  echogreen "FULL=true (Default false) Set this to true to compile all of coreutils, otherwise only advanced cp/mv will be setup"
  echo " "
  exit 1
}

TEXTRESET=$(tput sgr0)
TEXTGREEN=$(tput setaf 2)
TEXTRED=$(tput setaf 1)
DIR=`pwd`
CHECK=false
LINARO=false
FULL=false
OIFS=$IFS; IFS=\|; 
while true; do
  case "$1" in
    -h|--help) usage;;
    "") shift; break;;
    ARCH=*|VER=*|FULL=*) eval $1; shift;;
    *) echored "Invalid option: $1!"; usage;;
  esac
done
IFS=$OIFS

[ -z $VER ] && VER=8.30
[[ $(wget -S --spider ftp.gnu.org/gnu/coreutils/coreutils-$VER.tar.xz 2>&1 | grep 'HTTP/1.1 200 OK') ]] || { echored "Invalid coreutils VER! Check this: ftp.gnu.org/gnu/coreutils/ for valid versions!"; usage; }
[ -z $ARCH ] && ARCH=arm
case $ARCH in
  arm64|aarch64) target_host=aarch64-linux-gnu; LINARO=true;;
  arm) target_host=arm-linux-gnueabi; LINARO=true;;
  x64|x86_64) target_host=x86_64-linux-gnu;;
  x86|i686) target_host=i686-linux-gnu;;
  *) echored "Invalid ARCH entered!"; usage;;
esac

# Setup
echogreen "Fetching coreutils $VER"
rm -rf coreutils-$VER
$FULL && rm -f coreutils-$ARCH || rm -f cp-$ARCH mv-$ARCH
[ -f "coreutils-$VER.tar.xz" ] || wget ftp.gnu.org/gnu/coreutils/coreutils-$VER.tar.xz
tar -xf coreutils-$VER.tar.xz
if $LINARO; then
  echogreen "Fetching Linaro gcc"
  [ -f gcc-linaro-7.4.1-2019.02-x86_64_$target_host.tar.xz ] || wget https://releases.linaro.org/components/toolchain/binaries/latest-7/$target_host/gcc-linaro-7.4.1-2019.02-x86_64_$target_host.tar.xz
  [ -d gcc-linaro-7.4.1-2019.02-x86_64_$target_host ] || tar -xf gcc-linaro-7.4.1-2019.02-x86_64_$target_host.tar.xz

  # Add the standalone toolchain to the search path.
  export PATH=`pwd`/gcc-linaro-7.4.1-2019.02-x86_64_$target_host/bin:$PATH
fi

# Apply patches - originally by atdt and Sonelli @ github
echogreen "Applying patches"
cd $DIR/coreutils-$VER
patch -p1 -i $DIR/advcpmv-$VER.patch
[ $? -ne 0 ] && { echored "ADVC patching failed! Did you verify line numbers? See README for more info"; exit 1; }
patch -p0 -i $DIR/coreutils-android-$VER.patch
[ $? -ne 0 ] && { echored "Android patching failed! Did you verify line numbers? See README for more info"; exit 1; }

# Configure
echogreen "Configuring for $ARCH"
# Fix for mktime_internal build error for arm/64 cross-compile
sed -i -e '/WANT_MKTIME_INTERNAL=0/i\WANT_MKTIME_INTERNAL=1\n$as_echo "#define NEED_MKTIME_INTERNAL 1" >>confdefs.h' -e '/^ *WANT_MKTIME_INTERNAL=0/,/^ *fi/d' configure
if $FULL; then
  ./configure --host=$target_host --disable-nls --enable-single-binary=symlinks --without-selinux --without-gmp --with-gnu-ld CFLAGS='-static -O2' LDFLAGS='-static -O2' #--enable-no-install-program=stdbuf
  [ $? -eq 0 ] || { echored "Configure failed!"; exit 1; }
else
  ./configure --host=$target_host --without-gmp --with-gnu-ld CFLAGS='-static -O2' LDFLAGS='-static -O2'
  [ $? -eq 0 ] || { echored "Configure failed!"; exit 1; }
fi
# Build
echogreen "Building"
[ "$(grep "#define HAVE_MKFIFO 1" lib/config.h)" ] || echo "#define HAVE_MKFIFO 1" >> lib/config.h
sed -i 's/^MANS = .*//g' Makefile
make
[ $? -eq 0 ] || { echored "Build failed!"; exit 1; }
echogreen "Processing coreutils"
if $FULL; then
  cp src/coreutils $DIR/coreutils-$ARCH
  if $LINARO; then
    $target_host-strip $DIR/coreutils-$ARCH
  else
    strip $DIR/coreutils-$ARCH
  fi
else
  for MODULE in cp mv; do
    cp src/$MODULE $DIR/$MODULE-$ARCH
    if $LINARO; then
      $target_host-strip $DIR/$MODULE-$ARCH
    else
      strip $DIR/$MODULE-$ARCH
    fi
  done
fi
exit 0
