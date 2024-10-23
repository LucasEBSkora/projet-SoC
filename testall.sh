#!/bin/bash
for fullfile in testbench/*; do
    filename=$(basename -- "$fullfile")
    case $filename in *_tb.vhd)\
        filename="${filename%_tb.vhd}";\
        echo $filename;\
        make TESTBENCH=$filename test;; \
    esac
    
done
