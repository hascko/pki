#!/bin/bash

########################################################
#                                                      #
#   Script pour la creation de d'un certificat fille   #
#                                                      #
########################################################

nom_certif=$1
password_certif=$2
password_certif_root=$3
pays=$4
departement=$5
ville=$6
organisation=$7
cname=$8
email=$9

repertoire="opt/rootpki"

# On cree le repertoire du certificat fille et fichiers utiles
mkdir -p /$repertoire/$nom_certif/newcerts
mkdir -p /$repertoire/$nom_certif/archives
touch /$repertoire/$nom_certif/index.txt
echo '01' > /$repertoire/$nom_certif/serial
echo "$password_certif_root" > /$repertoire/$nom_certif/ca.pass


echo "[ ca ]
default_ca	= root_cbi

[ root_cbi ]
dir				= /opt/rootpki
certs			= \$dir/root_cbi/certs
new_certs_dir	= \$dir/root_cbi/newcerts
database		= \$dir/root_cbi/index.txt
certificate		= \$dir/root_cbi/root_cbi.pem
serial			= \$dir/root_cbi/serial
private_key		= \$dir/root_cbi/root_cbi.key
default_days	= 365
default_md		= sha1
preserve		= no
policy			= policy_anything
crl				= \$dir/root_cbi/crl.pem

[ $nom_certif ]
dir 			= /opt/rootpki/$nom_certif
certs			= \$dir/certs
new_certs_dir	= \$dir/newcerts
database		= \$dir/index.txt
certificate		= \$dir/$nom_certif.pem
serial			= \$dir/serial
private_key		= \$dir/$nom_certif.key
default_days	= 365
default_md		= sha1
preserve		= no
policy			= policy_match
crl				= \$dir/crl.pem

[ policy_match ]
countryName				= match
stateOrProvinceName		= match
localityName			= match
organizationName		= match
organizationalUnitName	= optional
commonName				= supplied
emailAddress			= optional

[ policy_anything ]
countryName				= optional
stateOrProvinceName		= optional
localityName			= optional
organizationName		= optional
organizationalUnitName	= optional
commonName				= supplied
emailAddress			= optional

[ req ]
distinguished_name	= req_distinguished_name

[ req_distinguished_name ]
countryName			= Pays
countryName_default		= $pays
stateOrProvinceName		= Departement
stateOrProvinceName_default	= $departement
localityName			= Ville
localityName_default		= $ville
organizationName		= Organisation
organizationName_default	= $organisation
commonName			= $cname
commonName_max			= 64
emailAddress			= $email
emailAddress_max		= 40

[ CA_ROOT ]
nsComment			= "\"CA Racine\""
subjectKeyIdentifier		= hash
authorityKeyIdentifier		= keyid,issuer:always
basicConstraints		= critical,CA:TRUE,pathlen:1
keyUsage			= keyCertSign, cRLSign

[ CA_SSL ]
nsComment			= "\"CA SSL\""
basicConstraints		= critical,CA:TRUE,pathlen:0
subjectKeyIdentifier		= hash
authorityKeyIdentifier		= keyid,issuer:always
issuerAltName			= issuer:copy
keyUsage			= keyCertSign, cRLSign
nsCertType			= sslCA

[ SERVER_RSA_SSL ]
nsComment			= ""Certificat Serveur SSL""
subjectKeyIdentifier		= hash
authorityKeyIdentifier		= keyid,issuer:always
issuerAltName			= issuer:copy
subjectAltName			= DNS:www.webserver.com, DNS:www.webserver-bis.com
basicConstraints		= critical,CA:FALSE
keyUsage			= digitalSignature, nonRepudiation, keyEncipherment
nsCertType			= server
extendedKeyUsage		= serverAuth

[ CLIENT_RSA_SSL ]
nsComment			= ""Certificat Client SSL""
subjectKeyIdentifier		= hash
authorityKeyIdentifier		= keyid,issuer:always
issuerAltName			= issuer:copy
subjectAltName			= critical,email:copy,email:user-bis@domain.com,email:user-ter@domain.com
basicConstraints		= critical,CA:FALSE
keyUsage			= digitalSignature, nonRepudiation
nsCertType			= client
extendedKeyUsage		= clientAuth" > /$repertoire/$nom_certif/openssl.cnf

# On cree le couple de cle
openssl genrsa -passout stdin -des3 -out /$repertoire/$nom_certif/$nom_certif.key 2048 <<EOF
$password_certif
EOF

# On cree un certificat non signe
openssl req -new -nodes -batch -newkey rsa:2048 -keyout /$repertoire/$nom_certif/$nom_certif.key -out /$repertoire/$nom_certif/$nom_certif.crs -config /$repertoire/$nom_certif/openssl.cnf -subj "/C=$pays/ST=$departement/L=$ville/O=$organisation/CN=$cname/emailAddress=$email"

# On signe avec la cle privee CA
openssl ca -passin file:/$repertoire/$nom_certif/ca.pass -batch -config /$repertoire/$nom_certif/openssl.cnf -extensions CA_SSL -out /$repertoire/$nom_certif/$nom_certif.pem -infiles /$repertoire/$nom_certif/$nom_certif.crs

# On supprime ensuite le mot de passe du certif root
rm /$repertoire/$nom_certif/ca.pass

# On construit le crt final pour vérifier les certificats qui découleront de cette CA fille
cat /$repertoire/root_cbi/root_cbi.pem /$repertoire/$nom_certif/$nom_certif.pem > /$repertoire/$nom_certif/CAChain.crt

