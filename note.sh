#!/bin/bash

facto() {
    number=$1
    result=1

    if [ "$number" -lt 0 ]; then
        echo "Erreur : le nombre doit être positif."
        return 1
    fi

    for (( i=1; i<=$number; i++ )); 
    do
        result=$((result * i))
    done

    echo $result
}

status=0

files=$(find . -type f \( -name "*.c" -o -name "*.h" -o -name "Makefile" -o -iname "readme*" \) | wc -l)
[ "$files" -eq 4 ] && echo "Fichier trouvé debut de la notation" || (echo "Auccun fichier trouvé"; status=1;)

make all

exec=$(find . -type f ! -path "*.sh" -exec test -x {} \; -print | wc -l)
[ "$exec" -eq 1 ] && echo "Code compilé !" || (echo "Erreur lors de la compilation"; status=1;)

if [ "$status" -ne 0 ]; then 
    exit 1
fi 

fileName=$(find . -type f ! -path "*.sh" -exec test -x {} \; -print)

for ((i=0; i<10; i++));   
do
    result=$(./$fileName $i)
    if [[ $(facto $i) -ne $result ]]; then
        echo "Le code est faux"
    fi
done