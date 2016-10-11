#!/bin/bash

nom_certif_fille=$1
password_root=$2
certif_root="root_cbi"
repertoire="opt/rootpki"
nb_files=$(find /$repertoire/$certif_root/newcerts/ -type f | wc -l)
echo "$password_root" > /$repertoire/$certif_root/ca.pass

i=0

while [ "$i" -lt "$nb_files" ]
do
let i++
fichier=0$i.pem
cmp -s /$repertoire/$nom_certif_fille/$nom_certif_fille.pem /$repertoire/$certif_root/newcerts/$fichier

if [ $? -eq 0 ];then
	openssl ca -passin file:/$repertoire/$certif_root/ca.pass -batch -config /$repertoire/$nom_certif_fille/openssl.cnf -name $certif_root -revoke /$repertoire/$certif_root/newcerts/$fichier
	openssl ca -gencrl -passin file:/$repertoire/$certif_root/ca.pass -batch -config /$repertoire/$nom_certif_fille/openssl.cnf -extensions CA_SSL -name $certif_root -crldays 1 -out /$repertoire/$certif_root/crl.pem
	openssl crl -in /$repertoire/$certif_root/crl.pem -text -noout
fi
let i--

let i++
done

rm /$repertoire/$certif_root/ca.pass
cp -R /$repertoire/$nom_certif_fille/ /$repertoire/archives
rm -R /$repertoire/$nom_certif_fille/