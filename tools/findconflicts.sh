#!/bin/bash
find . -mindepth 1 -type f -printf '%p %f\n' | sort -t ' ' -k 2,2 | uniq -f 1 --all-repeated=separate | cut -d' ' -f1