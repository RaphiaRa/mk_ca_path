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
input_=$bundle_
count_=0
doWrite_=0
file_=""
filepath_=""
while IFS= read -r line_
do
    if [ "$line_" = "-----BEGIN CERTIFICATE-----" ]; then
        doWrite_=1
        file_="cert-$count_.pem"
	filepath_="$path_/$file_"
        rm -f $filepath_
        count_=$((count_+1))
    fi
    if [ "$doWrite_" == "1" ]; then
        echo "$line_" >> $filepath_
    fi
    if [ "$line_" = "-----END CERTIFICATE-----" ]; then
        doWrite_=0
	ln -s $file_ $path_/"$(openssl x509 -hash -noout -in $filepath_)".0
    fi
done < "$input_"
