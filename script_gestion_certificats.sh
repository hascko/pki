#!/bin/bash

#######################################
#                                     #
#  Script de gestion des certificats  #
#                                     #
#######################################

repertoire="tp_pki/pki"
repertoire1="opt/rootpki/root_cbi"

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
		nb_filles_existantes=$(awk '/^V/{x+=1}END{print x}' /$repertoire1/index.txt)
		limit=5

		if [ "$nb_filles_existantes" -lt "$limit" ];then
			echo "Entrez le nom du nouveau certificat fille"
			read nom_certif
			echo "Entrez le mot de passe du nouveau certificat fille"
			read password_certif
			echo "Entrez le mot de passe du certificat root"
			read password_certif_root
			echo "Entrez le pays (utilisez les initiaux. Ex: FR pour France)"
			read pays
			echo "Entrez le département"
			read departement
			echo "Entrez la ville"
			read ville
			echo "Entrez l'organisation"
			read organisation
			echo "Entrez le common name du nouveau certificat fille"
			read cname
			echo "Entrez l'adresse email"
			read email
			/$repertoire/script_ca_fille.sh $nom_certif $password_certif $password_certif_root $pays $departement $ville $organisation $cname $email
			echo "Le certificat fille $nom_certif a bien ete cree"
		else
			echo "Désolé le quota limite d'Authorités filles est atteind"
		fi
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
		echo "Choisissez le nom de l'authorité fille pour votre certificat svp"
		ls -Ad /opt/rootpki/*/ | cut -d"/" -f4 > random
		sed '/root_cbi/d' random > random1 && mv -f random1 random; rm -f random1
		sed '/archives/d' random > random1 && mv -f random1 random; rm -f random1
		#sed '/newcerts/d' random > random1 && mv -f random1 random; rm -f random1
		IFS=$'\n'
		tableau=( $( cat random ) )

		i=0
		while [ "$i" -lt "${#tableau[*]}" ]
		do
			echo $((i+1))- ${tableau[$i]}
			let i++
		done
		read h
		let h--
		nom_certif_fille=${tableau[$h]}
		rm random
		echo "Entrez le mot de passe de l'authorité fille"
		read password_certif_fille
		echo "Entrez le nom du nouveau certificat serveur"
		read nom_certif
		echo "Entrez le mot de passe du nouveau certificat serveur"
		read password_serveur
		echo "Entrez le common name du nouveau certificat serveur"
		read cname
		echo "Entrez l'adresse email"
		read email
		/$repertoire/script_serveur.sh $nom_certif $nom_certif_fille $password_serveur $password_certif_fille $cname $email
		echo "Le certificat serveur $nom_certif a bien ete cree"
	;;
	"4")
		echo "Choisissez le nom de l'authorité fille du certificat à révoquer"
		ls -Ad /opt/rootpki/*/ | cut -d"/" -f4 > random
		sed '/root_cbi/d' random > random1 && mv -f random1 random; rm -f random1
		sed '/archives/d' random > random1 && mv -f random1 random; rm -f random1
		#sed '/newcerts/d' random > random1 && mv -f random1 random; rm -f random1
		IFS=$'\n'
		tableau=( $( cat random ) )

		i=0
		while [ "$i" -lt "${#tableau[*]}" ]
		do
			echo $((i+1))- ${tableau[$i]}
			let i++
		done
		read h
		let h--
		certif_fille=${tableau[$h]}
		rm random
		echo "Choisissez le nom du certificat serveur à révoquer"
		ls -Ad /opt/rootpki/$certif_fille/*/ | cut -d"/" -f5 > random
		sed '/archives/d' random > random1 && mv -f random1 random; rm -f random1
		sed '/newcerts/d' random > random1 && mv -f random1 random; rm -f random1
		IFS=$'\n'
		tableau=( $( cat random ) )

		i=0
		while [ "$i" -lt "${#tableau[*]}" ]
		do
			echo $((i+1))- ${tableau[$i]}
			let i++
		done
		read e
		let e--
		serveur=${tableau[$e]}
		rm random
		/$repertoire/revocation_serveur.sh $serveur $certif_fille
		echo "Le certificat serveur $serveur du certificat fille $certif_fille a bien été révoqué"
	;;
	"5")
		echo "Choisissez le nom de l'authorité fille pour votre certificat svp"
		ls -Ad /opt/rootpki/*/ | cut -d"/" -f4 > random
		sed '/root_cbi/d' random > random1 && mv -f random1 random; rm -f random1
		sed '/archives/d' random > random1 && mv -f random1 random; rm -f random1
		#sed '/newcerts/d' random > random1 && mv -f random1 random; rm -f random1
		IFS=$'\n'
		tableau=( $( cat random ) )

		i=0
		while [ "$i" -lt "${#tableau[*]}" ]
		do
			echo $((i+1))- ${tableau[$i]}
			let i++
		done
		read h
		let h--
		nom_certif_fille=${tableau[$h]}
		rm random
		echo "Entrez le mot de passe du certificat fille"
		read password_certif_fille
		echo "Entrez le nom du nouveau certificat client"
		read nom_certif
		echo "Entrez le mot de passe du nouveau certificat client"
		read password_client		
		echo "Entrez le common name du nouveau certificat fille"
		read cname
		echo "Entrez l'adresse email"
		read email
		/$repertoire/script_serveur.sh $nom_certif $nom_certif_fille $password_client $password_certif_fille $cname $email
		echo "Le certificat client $nom_certif a bien été créé"
	;;
	"6")
		echo "Choisissez le nom de l'authorité fille du certificat à révoquer"
		ls -Ad /opt/rootpki/*/ | cut -d"/" -f4 > random
		sed '/root_cbi/d' random > random1 && mv -f random1 random; rm -f random1
		sed '/archives/d' random > random1 && mv -f random1 random; rm -f random1
		#sed '/newcerts/d' random > random1 && mv -f random1 random; rm -f random1
		IFS=$'\n'
		tableau=( $( cat random ) )

		i=0
		while [ "$i" -lt "${#tableau[*]}" ]
		do
			echo $((i+1))- ${tableau[$i]}
			let i++
		done
		read h
		let h--
		certif_fille=${tableau[$h]}
		rm random
		echo "Choisissez le nom du certificat serveur à révoquer"
		ls -Ad /opt/rootpki/$certif_fille/*/ | cut -d"/" -f5 > random
		sed '/archives/d' random > random1 && mv -f random1 random; rm -f random1
		sed '/newcerts/d' random > random1 && mv -f random1 random; rm -f random1
		IFS=$'\n'
		tableau=( $( cat random ) )

		i=0
		while [ "$i" -lt "${#tableau[*]}" ]
		do
			echo $((i+1))- ${tableau[$i]}
			let i++
		done
		read e
		let e--
		client=${tableau[$e]}
		rm random
		/$repertoire/revocation_serveur.sh $client $certif_fille
		echo "Le certificat serveur $serveur du certificat fille $certif_fille a bien été révoque"
	;;
esac
	echo "Lisez bien les propositions svp"
	echo "Voulez-vous continuer ?"
	read reponse
done
