#!/bin/bash

########################################################
#                                                      #
#   Script pour la creation de d'un certificat fille   #
#                                                      #
########################################################

nom_certif=$1
password_certif=$2
password_certif_root=$3

# On cree le repertoire du certificat fille et fichiers utiles
mkdir -p /tp_pki/$nom_certif/newcerts
touch /tp_pki/$nom_certif/index.txt
echo '01' > /tp_pki/$nom_certif/serial
echo "$password_certif_root" > /tp_pki/$nom_certif/ca.pass

echo "#debut CA_$nom_certif" >> /tp_pki/openssl.cnf
echo "[ CA_$nom_certif ]" >> /tp_pki/openssl.cnf
echo "dir		= ." >> /tp_pki/openssl.cnf
echo "certs		= \$dir/$nom_certif/certs" >> /tp_pki/openssl.cnf
echo "new_certs_dir	= \$dir/$nom_certif/newcerts" >> /tp_pki/openssl.cnf
echo "database	= \$dir/$nom_certif/index.txt" >> /tp_pki/openssl.cnf
echo "certificate	= \$dir/$nom_certif/$nom_certif.pem" >> /tp_pki/openssl.cnf
echo "serial		= \$dir/$nom_certif/serial" >> /tp_pki/openssl.cnf
echo "private_key	= \$dir/$nom_certif/$nom_certif.key" >> /tp_pki/openssl.cnf
echo "default_days	= 365" >> /tp_pki/openssl.cnf
echo "default_md	= sha1" >> /tp_pki/openssl.cnf
echo "preserve	= no" >> /tp_pki/openssl.cnf
echo "policy		= policy_match" >> /tp_pki/openssl.cnf
echo " " >> /tp_pki/openssl.cnf
echo "#fin CA_$nom_certif" >> /tp_pki/openssl.cnf

# On cree le couple de cle
openssl genrsa -passout stdin -des3 -out /tp_pki/$nom_certif/$nom_certif.key 2048 <<EOF
$password_certif
EOF

# On cree un certificat non signe
openssl req -new -nodes -batch -newkey rsa:2048 -keyout /tp_pki/$nom_certif/$nom_certif.key -out /tp_pki/$nom_certif/$nom_certif.crs -config /tp_pki/openssl.cnf -subj "/C=FR/ST=Ile-de-France/L=Grigny/O=Hassane CIE/CN=www.$nom_certif.fr/emailAddress=$nom_certif@live.fr"

# On signe avec la cle privee CA
openssl ca -passin file:/tp_pki/$nom_certif/ca.pass -batch -config /tp_pki/openssl.cnf -extensions CA_SSL -out /tp_pki/$nom_certif/$nom_certif.pem -infiles /tp_pki/$nom_certif/$nom_certif.crs

# On supprime ensuite le mot de passe du certif root
rm /tp_pki/$nom_certif/ca.pass
