 #! /bin/sh
for i in $(find -name \*.csv); do
   sed -$i.bk 'y/'"ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ"'/'"AAAAAAACEEEEIIIIDNOOOOOOUUUUYPSaaaaaaaceeeeiiiionoooooouuuuyby"'/' $i
done
