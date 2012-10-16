#!/bin/bash

for FILENAME in $(find ./www.foxnews.com -type f | grep 2012 )
do
lynx -dump -force_html -nolist $FILENAME
done
