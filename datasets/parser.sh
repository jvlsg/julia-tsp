#!/bin/bash
wc -l $1 | cut -f 1 -d " " | xargs grep "1 " $1 -A | cut -f 2,3 -d " "