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

echo "$password_certif_fille" > /tp_pki/$nom_certif/ca.pass

# On cree le couple de cle
openssl genrsa -passout stdin -des3 -out /tp_pki/$nom_certif/$nom_client.key 1024 <<EOF
$password_client
EOF

# On cree un certificat non signe
openssl req -new -nodes -batch -newkey rsa:1024 -keyout /tp_pki/$nom_certif/$nom_client.key -out /tp_pki/$nom_certif/$nom_client.crs -config /tp_pki/openssl.cnf -subj "/C=FR/ST=Ile-de-France/L=Grigny/O=Hassane CIE/CN=www.$nom_client.fr/emailAddress=$nom_client@live.fr"

# On signe avec la cle privee CA
openssl ca -passin file:/tp_pki/$nom_certif/ca.pass -batch -name CA_$nom_certif -config /tp_pki/openssl.cnf -extensions CLIENT_RSA_SSL -out /tp_pki/$nom_certif/$nom_client.pem -infiles /tp_pki/$nom_certif/$nom_client.crs

# On supprime ensuite le mot de passe du certif root
rm /tp_pki/$nom_certif/ca.pass
