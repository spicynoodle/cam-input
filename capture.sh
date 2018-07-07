#!/bin/bash

set -ev

## capture image
out="out.jpeg"
streamer -c /dev/video0 -b 256 -o $out

## use it siganture as a file name
sig=$(identify -verbose $out | grep signature | awk -F':' '{print$2}' | xargs).jpeg
mv $out $sig

## add geotag
coordinates=$(wget https://whataremycoordinates.com/ -O - -o /dev/null | pup '.coordinates' | sed -n '2p')
lat=$(echo $coordinates | awk -F',' '{print$1}')
lon=$(echo $coordinates | awk -F',' '{print$2}' | xargs)

exiftool -overwrite_original -GPSLongitude=$lat -GPSLatitude=$lon $sig

## upload to s3
bucket="spicy-noodle"
aws s3 cp $sig s3://$bucket/$sig

mkdir -p .backup
mv $sig .backup
