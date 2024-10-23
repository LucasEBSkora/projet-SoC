#!/bin/bash
for fullfile in testbench/*; do
    filename=$(basename -- "$fullfile")
    filename="${filename%_tb.vhd}"
    echo $filename
    make TESTBENCH=$filename test
done
