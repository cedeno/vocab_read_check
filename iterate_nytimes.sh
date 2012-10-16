#!/bin/bash

for FILENAME in $(find ./www.nytimes.com/2012 -type f )
do
lynx -dump -force_html -nolist $FILENAME
done
