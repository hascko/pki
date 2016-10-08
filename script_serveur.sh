#!/bin/bash

#########################################################
#                                                       #
#   Script pour la creation de d'un certificat server   #
#                                                       #
#########################################################

nom_serveur=$1
nom_certif=$2
password_serveur=$3
password_certif_fille=$4

echo "$password_certif_fille" > /tp_pki/$nom_certif/ca.pass

# On cree le couple de cle
openssl genrsa -passout stdin -des3 -out /tp_pki/$nom_certif/$nom_serveur.key 1024 <<EOF
$password_serveur
EOF

# On cree un certificat non signe
openssl req -new -nodes -batch -newkey rsa:1024 -keyout /tp_pki/$nom_certif/$nom_serveur.key -out /tp_pki/$nom_certif/$nom_serveur.crs -config /tp_pki/openssl.cnf -subj "/C=FR/ST=Ile-de-France/L=Grigny/O=Hassane CIE/CN=www.$nom_serveur.fr/emailAddress=$nom_serveur@live.fr"

# On signe avec la cle privee CA
openssl ca -passin file:/tp_pki/$nom_certif/ca.pass -batch -name CA_$nom_certif -config /tp_pki/openssl.cnf -extensions SERVER_RSA_SSL -out /tp_pki/$nom_certif/$nom_serveur.pem -infiles /tp_pki/$nom_certif/$nom_serveur.crs

# On supprime ensuite le mot de passe du certif root
rm /tp_pki/$nom_certif/ca.pass
