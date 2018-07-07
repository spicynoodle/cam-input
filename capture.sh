#!/bin/bash

set -ev

## capture image
out="out.jpeg"
streamer -c /dev/video0 -b 256 -o $out

## add geotag
coordinates=$(wget https://whataremycoordinates.com/ -O - -o /dev/null | pup '.coordinates' | sed -n '2p')
lat=$(echo $coordinates | awk -F',' '{print$1}')
lon=$(echo $coordinates | awk -F',' '{print$2}' | xargs)
echo $lat
echo $lon

exiftool -overwrite_original -GPSLongitude=$lat -GPSLatitude=$lon $out

## use it siganture as a file name
filename=$(identify -verbose $out | grep signature | awk -F':' '{print$2}' | xargs)%$lat%$lon%.jpeg
echo $filename

## upload to s3
bucket="spicy-noodle"
aws s3 cp $out s3://$bucket/$filename --acl public-read

rm -f $out
