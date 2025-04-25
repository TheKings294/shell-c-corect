#!/bin/bash

facto() {
    number=$1
    result=1

    if [ "$number" -lt 0 ]; then
        echo "Erreur : le nombre doit être positif."
        return 1
    fi

    for (( i=1; i<=number; i++ )); 
    do
        result=$((result * i))
    done

    echo $result
}

set_note() {
    note=$1
    name=$(<readme.txt)

    if [ ! "$(find . -type f -name "note.csv")" ]; then
        touch note.csv
        echo "Nom,Prénom,Note">note.csv
    fi

    echo "'$(echo "$name" | awk '{print $2}')','$(echo "$name" | awk '{print $1}')',$note">>note.csv

    echo "La note de l'eleve est : $note"
}

status=0
error_message_special_case=("Erreur: Mauvais nombre de parametres" "Erreur: nombre negatif")
note=0

files=$(find . -type f \( -name "*.c" -o -name "*.h" -o -name "Makefile" -o -iname "readme*" \) | wc -l)
[ "$files" -eq 4 ] && echo "Fichier trouvé debut de la notation" || (echo "Auccun fichier trouvé"; status=1;)

make all

exec=$(find . -type f ! -path "*.sh" -exec test -x {} \; -print | wc -l)
[ "$exec" -eq 1 ] && echo "Code compilé !" || (echo "Erreur lors de la compilation"; status=1;)

if [ "$status" -ne 0 ]; then 
    echo "$note"
    exit 1
fi 

note=$((note + 2))

fileName=$(find . -type f ! -path "*.sh" -exec test -x {} \; -print)

for ((i=0; i<10; i++));   
do
    result=$("./$fileName" $i)
    if [[ $(facto $i) -ne $result ]]; then
        set_note $note
        exit 1
    fi
done

note=$((note + 5))

result=$("./$fileName" 0)
if [[ $result -eq 1 ]]; then 
    note=$((note + 3))
fi

result=$("$fileName")
if [[ $result != "${error_message_special_case[0]}" ]]; then
    set_note $note
    exit 1
fi
note=$((note + 4))
result=$("$fileName" -1)
if [[ $result != "${error_message_special_case[1]}" ]]; then
    set_note $note
    exit 1
fi
note=$((note + 4))

set_note $note