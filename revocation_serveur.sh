#!/bin/bash

file1=$1
nom_certif=$2
nb_files=$(find ./$nom_certif/newcerts/ -type f | wc -l)

i=0

while [ "$i" -lt "$nb_files" ]
do
let i++
fichier=0$i.pem
cmp -s ./$nom_certif/$file1.pem ./$nom_certif/newcerts/$fichier

if [ $? -eq 0 ];then
	openssl ca -config ./openssl.cnf -name CA_$nom_certif -revoke ./$nom_certif/newcerts/$fichier
	openssl ca -gencrl -config ./openssl.cnf -extensions SERVEUR_RSA_SSL -name CA_$nom_certif -crldays 1 -out ./$nom_certif/crl.pem
	openssl crl -in ./$nom_certif/crl.pem -text -noout
fi
let i--

let i++
done
