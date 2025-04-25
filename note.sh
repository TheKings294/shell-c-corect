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

indentation() {
  local line_on="$1"
  local space_needed="$2"
  local spaces=0

  for (( i=0; i<${#line_on}; i++ )); do
    if [ "${line_on:$i:1}" = " " ]; then
      ((spaces++))
    else
      break
    fi
  done

  if [ "$spaces" -ne "$space_needed" ]; then
    echo 1
  else
    echo 0
  fi
}

status=0
error_message_special_case=("Erreur: Mauvais nombre de parametres" "Erreur: nombre negatif")
note=0

files=$(find . -type f \( -name "*.c" -o -name "*.h" -o -name "Makefile" -o -iname "readme*" \) | wc -l)
[ "$files" -eq 4 ] && echo "Fichier trouvé debut de la notation" || (echo "Auccun fichier trouvé"; status=1;)

make all


if [[ $(find . -type f ! -path "*.sh" -exec test -x {} \; -print | wc -l) -eq 1 ]]; then
  echo "Code compilé !"
else
  echo "Erreur lors de la compilation"
  status=1
fi

if [ "$status" -ne 0 ]; then 
    echo "$note"
    set_note $note
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

file_main_c=$(find . -type f -name main.c)

nb_space=0
is_line_over_80=false
is_indentation_incorrect=false
in_comment_block=false

while IFS= read -r line || [ -n "$line" ]; do
  nb_chars=${#line}

  if [[ "$line" =~ ^[[:space:]]*/\* ]]; then
    in_comment_block=true
  fi

  if $in_comment_block; then
    if [[ "$line" =~ \*/ ]]; then
      in_comment_block=false
    fi
    ((ligne_num++))
    continue
  fi

  if [ "$nb_chars" -gt 80 ]; then
    is_line_over_80=true
  fi

  if [[ "$line" =~ ^[[:space:]]*// ]]; then
    ((ligne_num++))
    continue
  fi

  for (( i=0; i<nb_chars; i++ )); do
    char="${line:$i:1}"
    if [ "$char" = "{" ]; then
      if [ "$(indentation "$line" "$nb_space")" -eq 1 ]; then
        is_indentation_incorrect=true
      fi
      ((nb_space+=2))
    elif [ "$char" = "}" ]; then
      ((nb_space-=2))
      if [ "$(indentation "$line" "$nb_space")" -eq 1 ]; then
        is_indentation_incorrect=true
      fi
    fi
  done

  if [[ "$line" =~ [a-zA-Z0-9] ]]; then
    if [ "$(indentation "$line" "$nb_space")" -eq 1 ]; then
      is_indentation_incorrect=true
    fi
  fi

  ((ligne_num++))

done < "$file_main_c"

if [ "$is_indentation_incorrect" = true ]; then
  echo "indentation : $is_indentation_incorrect"
  note=$((note - 2))
fi

if [ "$is_line_over_80" = true ]; then
  echo "line over 80 : $is_line_over_80"
  note=$((note - 2))
fi

if [[ $(grep -E '^\s*int\s+factorielle\s*\(\s*int\s+number\s*\)' $file_main_c) ]]; then 
   note=$((note + 2))
fi

make clean

exec=$(find . -type f ! -path "*.sh" -exec test -x {} \; -print | wc -l)
[ "$exec" -eq 0 ] && echo "Executable suprimé" || (echo "Erreur lors de la supression"; status=1;)

if [ "$status" -ne 0 ]; then 
    note=$((note - 2))
fi 

set_note $note
