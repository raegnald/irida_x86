#!/bin/sh

# Build the compiler
./build.sh > /dev/null &&

# Generate assembly
./irida.exe $1 > asm.asm &&

# Compile the assembly
nasm -felf64 asm.asm &&

# Link the object file
ld asm.o &&

./a.out