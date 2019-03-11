## Coreutils with Advanced cp/mv for Android Build Script ##

This will build static coreutils binary with applet symlinks (busybox style) and apply progress bar patches to cp/mv ("advanced cp/mv")

Advanced Copy is a mod for the GNU cp and GNU mv tools which adds a progress
bar and provides some info on what's going on. It was written by Florian Zwicke
and released under the GPL.

Source repository for advanced cp/mv patches is: (https://github.com/atdt/advcpmv)
Original website (http://beatex.org/web/advancedcopy.html) appears to be dead. You can still find it via the Internet Archive: https://web.archive.org/web/20131115171331/http://beatex.org/web/advancedcopy.html

The android patches are from here: )https://github.com/Sonelli/android-coreutils(

This website: (https://www.tecmint.com/advanced-copy-command-shows-progress-bar-while-copying-files) shows what it looks like

## Build instructions

```
sudo apt install build-essential gcc-multilib # For debian/ubuntu based distributions - install dev tools for yours
./build_coreutils.bash VER=8.30 ARCH=<ARCH> FULL=<true|false>
```
Binaries will be in `out-$ARCH` folder
If you set FULL to true, a static coreutils binary with symlinks for each applet will be generated. Otherwise, static advanced cp and mv binaries will be generated

## Usage
`cp -g file file2`
`mv -g file file2`

## Notes

There will be build errors at the end but it doesn't effect the cp or mv binaries so they can be safely ignored
You can modify it to build all of coreutils - just remove the --enable-install-program=cp,mv flag from configure and change the for loop at the bottom to read the modules file instead
