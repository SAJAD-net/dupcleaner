#!/usr/bin/bash

startt=`date +%s`
echo "> recording all the existing files in : $1" 
find $1 -type f -print > ".dup.cleaner.files.txt"
echo -e "< done. total files : `wc -l .dup.cleaner.files.txt | cut -d ' ' -f 1`\n"

echo "> calculating the hashes"
while IFS=$'\n' read -r line; do
	md5sum "$line" >> ".dup.cleaner.hashes.txt"
done < .dup.cleaner.files.txt
echo -e "< done.\n"

echo "> finding the duplicates"
awk 'NR==FNR{a[$1]++;next;}{ if (a[$1] > 1)print;}' .dup.cleaner.hashes.txt \
	.dup.cleaner.hashes.txt | sort -u -k1,1 | cut -d ' ' -f 3- > .dup.cleaner.dupfiles.txt
echo -e "< done. total duplicates : `wc -l .dup.cleaner.dupfiles.txt | cut -d ' ' -f 1`\n"

echo "> deleting the duplicates"
duplicates=0
while IFS=$'\n' read -r line; do
	echo "deleting : $line"
	rm "$line" && duplicates=`expr $duplicates + 1`
done < .dup.cleaner.dupfiles.txt
rm .dup.cleaner.*
endt=`date +%s`
totallt=`expr $endt - $startt`
echo -e "\n< done.\n"
echo -e "total duplicate files deleted : $duplicates in $totallt seconds!"
