#!/bin/sh

printExample()
{
    echo "Usage: mk_ca_path.sh <path to ca bundle> <path to destination dir>" >&2
}

bundle_=$1
path_=$2

if [ -z "$bundle_" ]; then
    echo 'Error: Path to ca bundle file is missing' >&2
    printExample
    exit 1
fi
if [ -z "$path_" ]; then
    echo 'Error: Path to destination dir is missing' >&2
    printExample
    exit 1
fi
if [ ! -f "$bundle_" ]; then
    echo 'Error: Ca bundle not found: $bundle_' >&2
    exit 1
fi
if [ ! -d "$path_" ]; then
    echo 'Error: Destination path doesn'\''t exist: $path_' >&2
    exit 1
fi
if ! [ -x "$(command -v openssl)" ]; then
    echo 'Error: openssl not found.' >&2
    exit 1
fi
if ! [ -x "$(command -v c_rehash)" ]; then
    echo 'Error: c_rehash (Part of openssl) not found.' >&2
    exit 1
fi
input_=$bundle_
count_=0
doWrite_=0
file_=""
while IFS= read -r line_
do
    if [ "$line_" = "-----BEGIN CERTIFICATE-----" ]; then
        doWrite_=1
        file_="$path_/cert-$count.pem"
        rm -f $file_ 
        count_=$((count_+1))
    fi
    if [ "$doWrite_" == "1" ]; then
        echo "$line_" >> $file_
    fi
    elif [ "$line_" = "-----END CERTIFICATE-----" ]; then
        doWrite_=0
    fi
done < "$input_"