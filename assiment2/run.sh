#!/bin/bash

as -g -o $1.o $1.s
ld -o $1 $1.o
rm -rf $1.o
