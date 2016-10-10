#!/bin/bash

#######################################
#                                     #
#  Script de gestion des certificats  #
#                                     #
#######################################

repertoire="tp_pki/pki"

reponse="oui"
while [ $reponse == "oui" ]
do
echo "BIENVENUE SUR LA PLATE-FORME DE GESTION DES CERTIFICATS"
echo "QUE SOUHAITEZ-VOUS FAIRE ?"
echo "1- Creer un certificat fille"
echo "2- Revoquer un certificat fille"
echo "3- Creer un certificat serveur"
echo "4- Revoquer un certificat serveur"
echo "5- Creer un certificat client"
echo "6- Revoquer un certificats client"
echo "Faites votre choix en entrant le chiffre correspondant !"

read choix

case $choix in
	"1")
		echo "Entrez le nom du nouveau certificat fille"
		read nom_certif
		echo "Entrez le mot de passe du nouveau certificat fille"
		read password_certif
		echo "Entrez le mot de passe du certificat root"
		read password_certif_root
		echo "Entrez le common name du nouveau certificat fille"
		read cname
		echo "Entrez l'adresse email"
		read email
		/$repertoire/script_ca_fille.sh $nom_certif $password_certif $password_certif_root $cname $email
		echo "Le certificat fille $nom_certif a bien ete cree"
	;;
	"2")
		echo "Entrez le nom du certificat fille"
		read nom_certif
		echo "Entrez le mot de passe root"
		read password_root
		/$repertoire/revocation_ca_fille.sh $nom_certif $password_root
		echo "Le certificat fille $nom_certif a bien ete revoque"
	;;
	"3")
		echo "Entrez le nom du nouveau certificat serveur"
		read nom_certif
		echo "Entrez le nom du certificat fille"
		read nom_certif_fille
		echo "Entrez le mot de passe du nouveau certificat serveur"
		read password_serveur
		echo "Entrez le mot de passe du certificat fille"
		read password_certif_fille
		echo "Entrez le common name du nouveau certificat fille"
		read cname
		echo "Entrez l'adresse email"
		read email
		/$repertoire/script_serveur.sh $nom_certif $nom_certif_fille $password_serveur $password_certif_fille $cname $email
		echo "Le certificat serveur $nom_certif a bien ete cree"
	;;
	"4")
		echo "Entrez le nom du serveur"
		read serveur
		echo "Entrez le nom du certificat fille"
		read certif_fille
		/$repertoire/revocation_serveur.sh $serveur $certif_fille
		echo "Le certificat serveur $serveur du certificat fille $certif_fille a bien ete revoque"
	;;
	"5")
		echo "Entrez le nom du nouveau certificat client"
		read nom_certif
		echo "Entrez le nom du certificat fille"
		read nom_certif_fille
		echo "Entrez le mot de passe du nouveau certificat client"
		read password_serveur
		echo "Entrez le mot de passe du certificat fille"
		read password_certif_fille
		echo "Entrez le common name du nouveau certificat fille"
		read cname
		echo "Entrez l'adresse email"
		read email
		/$repertoire/script_serveur.sh $nom_certif $nom_certif_fille $password_serveur $password_certif_fille $cname $email
		echo "Le certificat client $nom_certif a bien ete cree"
	;;
	"6")
		echo "Entrez le nom du client"
		read client
		echo "Entrez le nom du certificat fille"
		read certif_fille
		/$repertoire/revocation_serveur.sh $client $certif_fille
		echo "Le certificat serveur $serveur du certificat fille $certif_fille a bien ete revoque"
	;;
esac
	echo "Lisez bien les propositions svp"
	echo "Voulez-vous continuer ?"
	read reponse
done
