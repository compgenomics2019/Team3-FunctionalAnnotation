folder=$1
for file in $folder/*
do
    mv -i "$file" "${file}3"
done
