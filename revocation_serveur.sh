#!/bin/bash

file1=$1
nom_certif=$2
repertoire="opt/rootpki/$nom_certif"

nb_files=$(find /$repertoire/newcerts/ -type f | wc -l)

i=0

while [ "$i" -lt "$nb_files" ]
do
let i++
fichier=0$i.pem
cmp -s /$repertoire/$file1/$file1.pem /$repertoire/newcerts/$fichier

if [ $? -eq 0 ];then
	openssl ca -config /$repertoire/openssl.cnf -name $nom_certif -revoke /$repertoire/newcerts/$fichier
	openssl ca -gencrl -config /$repertoire/openssl.cnf -extensions SERVEUR_RSA_SSL -name $nom_certif -crldays 1 -out /$repertoire/crl.pem
	openssl crl -in /$repertoire/crl.pem -text -noout
fi
let i--

let i++
done
cp -R /$repertoire/$file1/ /$repertoire/archives
rm -R /$repertoire/$file1/