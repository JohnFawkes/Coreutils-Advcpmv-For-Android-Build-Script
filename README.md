## Advanced Cp/Mv for Android Build Script ##

Advanced Copy is a mod for the GNU cp and GNU mv tools which adds a progress
bar and provides some info on what's going on. It was written by Florian Zwicke
and released under the GPL.

Source repository for advanced cp/mv patches is: https://github.com/atdt/advcpmv
Original website (http://beatex.org/web/advancedcopy.html) appears to be dead. You can still find it via the Internet Archive: https://web.archive.org/web/20131115171331/http://beatex.org/web/advancedcopy.html

The android patches are from here: https://github.com/Sonelli/android-coreutils

## Build instructions

```
sudo apt install build-essential # For debian/ubuntu based distributions - install dev tools for yours
./build_coreutils.bash
```
Binaries will be in `out-$ARCH` folder

## Notes

There will be build errors at the end but it doesn't effect the cp or mv binaries so they can be safely ignored