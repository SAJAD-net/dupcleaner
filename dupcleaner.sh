#!/usr/bin/bash


echo "> recording all the existing files in : `pwd`" 
find $1 -type f -print > ".dup.cleaner.files.txt"
echo -e "< done.\n"

echo "> generating the hashes"
while IFS=$'\n' read -r line; do
	md5sum "$line" | cut -d ' ' -f 1 >> ".dup.cleaner.hashes.txt"
done < .dup.cleaner.files.txt
echo -e "< done.\n"

echo "> finding the duplicates"
sort .dup.cleaner.hashes.txt | uniq -d >> .dup.cleaner.duphashes.txt
echo -e "< done.\n"

echo "> deleting the duplicates"
duplicates=0
while IFS=$'\n' read -r line; do
	fhash=$(md5sum "$line" | cut -d ' ' -f 1)
	if grep "$fhash" .dup.cleaner.duphashes.txt; then
		echo "deleting : $line"
		rm "$line"
		sed -i "/$fhash/d" .dup.cleaner.duphashes.txt
		duplicates=`expr $duplicates + 1`
	fi
done < .dup.cleaner.files.txt
rm .dup.cleaner.*
echo -e "\n< done. total duplicate files deleted : $duplicates"
