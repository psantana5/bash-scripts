#!/bin/bash

toilet -F gay --gay "File Comparer" -w 120

#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 file1 file2"
  exit 1
fi

file1=$1
file2=$2

if [ ! -f $file1 ]; then
  echo "$file1 does not exist or is not a file"
  exit 1
fi

if [ ! -f $file2 ]; then
  echo "$file2 does not exist or is not a file"
  exit 1
fi

if diff $file1 $file2 >/dev/null ; then
  echo "The files $file1 and $file2 are identical"
else
  echo "The files $file1 and $file2 are different"
  diff $file1 $file2
fi
