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
$cname=$5
$email=$6

$repertoire=/opt/rootpki

#On créé le répertoire du serveur
mkdir /$repertoire/$nom_certif/$nom_serveur
echo "$password_certif_fille" > /$repertoire/$nom_certif/ca.pass

# On cree le couple de cle
openssl genrsa -passout stdin -des3 -out /$repertoire/$nom_certif/$nom_serveur/$nom_serveur.key 1024 <<EOF
$password_serveur
EOF

# On cree un certificat non signe
openssl req -new -nodes -batch -newkey rsa:1024 -keyout /$repertoire/$nom_certif/$nom_serveur/$nom_serveur.key -out /$repertoire/$nom_certif/$nom_serveur/$nom_serveur.crs -config /$repertoire/$nom_certif/openssl.cnf -subj "/CN=$cname/emailAddress=$email"

# On signe avec la cle privee CA
openssl ca -passin file:/$repertoire/$nom_certif/ca.pass -batch -name $nom_certif -config /$repertoire/$nom_certif/openssl.cnf -extensions SERVER_RSA_SSL -out /$repertoire/$nom_certif/$nom_serveur/$nom_serveur.pem -infiles /$repertoire/$nom_certif/$nom_serveur/$nom_serveur.crs

# On supprime ensuite le mot de passe du certif root
rm /$repertoire/$nom_certif/ca.pass
