#!/bin/bash

set -e

output_name="irida.exe";

if command -v dune &> /dev/null; then
  # Build
  dune build --release;
  mv -f ./_build/default/bin/main.exe $output_name;

  # Run if argument is passed
  if [ "$1" == "run" ]; then
    ./$output_name;
  else
    echo "./$output_name";
  fi

  # TODO: create a command to generate documentation
  #   Hint: do it with `dune build @doc-private`
else
  echo "Cannot build: dune needs to be installed";
fi