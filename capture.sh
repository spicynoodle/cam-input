#!/bin/bash

set -ev

## capture image
out="out.jpeg"
streamer -c /dev/video0 -b 256 -o $out

## use it siganture as a file name
sig=$(identify -verbose $out | grep signature | awk -F':' '{print$2}').jpeg
mv $out $sig
