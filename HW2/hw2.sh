#!/bin/sh

usage() {
    echo "hw2.sh -i INPUT -o OUTPUT [-c csv|tsv] [-j]" >&2;
    echo "" >&2;
    echo "Available Options:" >&2;
    echo "" >&2;
    echo "-i: Input file to be decoded" >&2;
    echo "-o: Output directory" >&2;
    echo "-c csv|tsv: Output files.[ct]sv" >&2;
    echo "-j: Output info.json" >&2;
    exit 2
}
outputInfo=false
outputFileType=""
while getopts ':i:o:c:j' opt; do
    case $opt in
        i) inputFile="$OPTARG";;
        o) outputFileDir="$OPTARG";;
        c) outputFileType="$OPTARG";;
        j) outputInfo=true;;
        ?) usage;;
    esac
done

if [ -z "$inputFile" ] || [ -z "$outputFileDir" ]; then
    usage
fi


invaldCount=0

mkdir -p $outputFileDir

file=`sed -e 's/,/,\n/g' $inputFile`
file=`echo "$file" | sed -e 's/{/{\n/g'`
file=`echo "$file" | sed -e 's/}/}\n/g'`
fileCount=`echo "$file" | grep '"type":' | grep -c ^`

name=`echo "$file" | grep '"name":' | sed -n -e 1p | cut -d '"' -f 4`
author=`echo "$file" | grep '"author":' | sed -n -e 1p | cut -d '"' -f 4`
date=`echo "$file" | grep '"date":' | sed -n -e 1p | cut -d ':' -f 2 | cut -d ',' -f 1 | tr -d ' '`

if [ "$outputFileType" = "csv" ]; then
    dia=","
elif [ "$outputFileType" = "tsv" ]; then
    dia='\t'
fi

if [ "$outputFileType" = "csv" ] || [ "$outputFileType" = "tsv" ]; then
    touch ${outputFileDir}/files.${outputFileType}
    echo -e "filename${dia}size${dia}md5${dia}sha1" >> ${outputFileDir}/files.${outputFileType}
fi

if $outputInfo; then
    echo "{" >> ${outputFileDir}/info.json
    echo -e "\t\"name\": \"${name}\"," >> ${outputFileDir}/info.json
    echo -e "\t\"author\": \"${author}\"," >> ${outputFileDir}/info.json
    echo -e "\t\"date\": \"`date -Iseconds -r ${date}`\"" >> ${outputFileDir}/info.json
    echo "}" >> ${outputFileDir}/info.json
fi

for idx in `seq 1 $fileCount`; do
    filename=`echo "$file" | grep '"name":' | sed -n -e $((${idx} + 1))p | cut -d '"' -f 4`
    data=`echo "$file" | grep '"data":' | sed -n -e ${idx}p | cut -d '"' -f 4`
    md5=`echo "$file" | grep '"md5":' | sed -n -e ${idx}p | cut -d '"' -f 4`
    sha=`echo "$file" | grep '"sha-1":' | sed -n -e ${idx}p | cut -d '"' -f 4`
    pathCount=`echo ${filename} | grep -o "/" | wc -l | tr -d ' '`
    if [ $pathCount -gt 0 ]; then
        path=`echo ${filename} | cut -d "/" -f 1-${pathCount}`
        mkdir -p ${outputFileDir}/${path}
    fi
    # path=`echo "$filename" | cut -n -d '/' -f 1-${pathCount}`
    # echo "path: $path"
    # echo "filename: $filename"
    # mkdir -p ${outputFileDir}/${path}
    decoded=`echo "$data" | base64 -d`
    echo "$decoded" > ${outputFileDir}/$filename
    # realMd5=`md5 -q -s $filename`
    realMd5=`md5sum  ${outputFileDir}/$filename | cut -d " " -f 1`
    realSha=`sha1sum ${outputFileDir}/$filename | cut -d " " -f 1`
    size=`wc -c ${outputFileDir}/$filename | awk '{$1=$1;print}' | cut -d " " -f 1`
    if [ "$outputFileType" = "csv" ] || [ "$outputFileType" = "tsv" ]; then
        echo -e "${filename}${dia}${size}${dia}${md5}${dia}${sha}" >> ${outputFileDir}/files.${outputFileType}
    fi


    if [ $md5 != $realMd5 ] || [ $sha != $realSha ] ; then
        invalidCount=$(( $invalidCount + 1 ))
    fi

done


exit $invalidCount