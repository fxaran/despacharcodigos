#!/bin/bash

### Description
#
#   Crea los ficheros con su codigo e institucion correspondiente
#   Se crea el directorio codigos en el Home del usuario

### Uso
#
#  ./despachar.sh {archivo-codigos}

###
#
# archivo codigos
codigos=$1
codigos=${codigos:?'no suministrado'}

arch_aux="/tmp/archivo_temporal.txt"

############################
n=0
while read x; do
  if [ $(expr $n % 2) -eq 0 ]; then
        unset l1
  	l1="$x"
  else
        unset l2
  	l2="$x"
  	echo "$l1 $l2" >> $arch_aux
  fi
  n=`expr 1 + $n`
done < $codigos

cat $arch_aux > $codigos
rm $arch_aux
###############################


asn=~/Documentos/vencert/otrs/Docs/asn.csv

# archivo auxiliar
faux=~/faux.txt

# Ordenamos
sort $codigos > $faux
cp $faux $codigos
rm $faux

### VAR
# patter mail
pmail='s/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/\n&\n/ig;s/(^|\n)[^@]*(\n|$)/\n/g;s/^\n|\n$//g;/^$/d'
# rutas
r=~/codigos/
# var auxiliar
aux=""
# save
s=""
# formato
f=txt

if [ -d $r ]; then
  rm -r ${r}* > /dev/null 2>&1
else
  mkdir -p $r
fi

while IFS= read -r x
do
  # Codigo
  y=`echo $x | cut -d, -f1 | sed 's/"//g'`
  # Ruta absoluta
  s="${r}${y}.$f"
  n="${r}nulos.$f"

  # Si el Codigo no existe en asn.csv, entonces guardar en nulo
  if [ -z $y ]; then
    echo $x >> $n
  #
  elif [[ ! $x =~ .*asn.* ]] && [ "$y" != "$aux" ]; then
    IFS=$'\n'
    l=( $(grep $y $asn) )
    n=( `echo $l | cut -d, -f2` )
    m=( `echo $l | sed -r $pmail` )
    echo -e "#################################" >> $s
    echo -e "#### Codigo\n$y" >> $s
    echo -e "####Institucion\n$n" >> $s
    echo -e "####Correo(s)\n${m[*]}" >> $s
    echo -e "#################################" >> $s
    echo "" >> $s
    echo "'asn','ip','timestamp','malware','src_port','dst_ip','dst_port','dst_host'" >> $s
    echo $x >> $s
  else
    echo $x >> $s
  fi
  aux=$y
done < $codigos
echo "Los codigos se han movido a $r"
echo "Finalizado."
