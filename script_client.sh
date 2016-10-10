#!/bin/bash

#########################################################
#                                                       #
#   Script pour la creation de d'un certificat client   #
#                                                       #
#########################################################

nom_client=$1
nom_certif=$2
password_client=$3
password_certif_fille=$4
$cname=$5
$email=$6

repertoire=/opt/rootpki

echo "$password_certif_fille" > /$repertoire/$nom_certif/ca.pass

# On cree le couple de cle
openssl genrsa -passout stdin -des3 -out /$repertoire/$nom_certif/$nom_client/$nom_client.key 1024 <<EOF
$password_client
EOF

# On cree un certificat non signe
openssl req -new -nodes -batch -newkey rsa:1024 -keyout /$repertoire/$nom_certif/$nom_client/$nom_client.key -out /$repertoire/$nom_certif/$nom_client/$nom_client.crs -config /$repertoire/$nom_certif/openssl.cnf -subj "/CN=$cname/emailAddress=$email"

# On signe avec la cle privee CA
openssl ca -passin file:/$repertoire/$nom_certif/ca.pass -batch -name CA_$nom_certif -config /$repertoire/$nom_certif/openssl.cnf -extensions CLIENT_RSA_SSL -out /$repertoire/$nom_certif/$nom_client/$nom_client.pem -infiles /$repertoire/$nom_certif/$nom_client/$nom_client.crs

# On supprime ensuite le mot de passe du certif root
rm /$repertoire/$nom_certif/ca.pass
