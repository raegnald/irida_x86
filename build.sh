#!/bin/bash

set -e

output_name="irida.exe";

# Build
dune build --release;
mv -f ./_build/default/bin/main.exe $output_name;

# Run if argument is passed
if [ "$1" == "run" ]; then
  ./$output_name;
else
  echo "./$output_name";
fi
