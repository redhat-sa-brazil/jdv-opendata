 #! /bin/sh
for i in $(find -name \*.csv); do
   iconv $i -f iso-8859-1 -t utf8 -o $i.2
    awk '{ sub("\r$", ""); print }' $i.2 > $i
done
