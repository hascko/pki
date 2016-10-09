#!/bin/bash

nom_certif_fille=$1
password_root=$2
certif_root="ca"
nb_files=$(find ./$certif_root/newcerts/ -type f | wc -l)
echo "$password_root" > /tp_pki/$certif_root/ca.pass

i=0

while [ "$i" -lt "$nb_files" ]
do
let i++
fichier=0$i.pem
cmp -s ./$nom_certif_fille/$nom_certif_fille.pem ./$certif_root/newcerts/$fichier

if [ $? -eq 0 ];then
	openssl ca -passin file:/tp_pki/$certif_root/ca.pass -batch -config ./openssl.cnf -name CA_default -revoke ./$certif_root/newcerts/$fichier
	openssl ca -gencrl -passin file:/tp_pki/$certif_root/ca.pass -batch -config ./openssl.cnf -extensions CA_SSL -name CA_default -crldays 1 -out ./$certif_root/crl.pem
	openssl crl -in ./$certif_root/crl.pem -text -noout
fi
let i--

let i++
done

rm /tp_pki/$certif_root/ca.pass
