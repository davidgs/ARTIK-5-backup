# ARTIK-5-backup
Script to backup/clone an ARTIK-520
This is intended to backup/clone an ARTIK-520 running the Samsung default Fedora Image. Not tested and likely won't work on Resin.io images.

# Prerequisites

* Clearly you need an ARTIK-520
* You need a Mini-SD Card on which to dump the system
* Works best if you have added 'pv' to your ARTIK-520

run dnf install pv

# Usage
Just copy this script to your ARTIK-520 and run as root. 

Your SD Card should have the same version of the OS on it as the ARTIK-5 is already running, whatever that OS is. This has **ONLY** been tested on the Samsung Artik-520 Fedora (22 & 24) distros, so if you're using something else, you should really test it first. 

It will re-partition your SD Card to expand partition 3 to be as large as possible. In case there are some odd layout characteristics, it will find the existing first sector of partition 3, and the total number of available secotrs, and calculate the correct partition map from there. 

In order to catch any customizations you may have done, the script will ask you 2 questions:

**Enter additonal (non-recursive) Directory: ** 

Enter any directories you wish to be preserved **NON-RECURSIVELY** So really it will just save the place-holder of the directory. Hit <enter> to end that.

**Enter additonal (recursive) Directory or File:** 

Any directory entered here will be added, recursively, to the archive. Single files will also be added. Again, hit <enter> on a blank line to end.

It **will** take a very long time to run, depending on how much you've added to your system

# Notes
If you don't have an SD Card with the Samsung ARTIK-5 boot system on it, just create one.
This script will replace the default rootfs.tar.gz with a clone of your system.
It will preserve the original rootfs.tar.gz file for you.

