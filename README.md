# ARTIK-5-backup
Script to backup/clone an ARTIK-520
This is intended to backup/clone an ARTIK-520 running the Samsung default Fedora Image. Not tested and likely won't work on Resin.io images.

# Prerequisites

* Clearly you need an ARTIK-520
* You need a Mini-SD Card on which to dump the system
* Works best if you have added 'pv' to your ARTIK-520

run dnf install pv

# Usage
just copy this script to your ARTIK-520 and run as root. 

It **will** take a very long time to run, depending on how much you've added to your system

# Notes
If you don't have an SD Card with the Samsung ARTIK-5 boot system on it, just create one.
This script will replace the default rootfs.tar.gz with a clone of your system.
It will preserve the original rootfs.tar.gz file for you.

