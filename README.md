# Jenkins / Docker / Kubernetes / Helm / Ansible
How to Deploy a Docker Application on kubernetes with Helm, Ansible and Jenkins

Dans cet article nous allons montrer étape par étape comment builder une image docker, la déployer dans kubernetes à l’aide de Helm, Ansible et Jenkins.
Kubernetes est compatible avec la majorité des outils d’intégration continue / déploiement continue (CI / CD) qui permet aux développeurs d’exécuter des tests, de déployer des builds dans Kubernetes et de mettre à jour des applications sans interruption.
Jenkins est désormais l’un des outils CI / CD les plus populaires.
Cet article se concentrera sur la configuration d’un pipeline CI / CD avec Jenkins et Helm sur Kubernetes.

Présentation du guide
Nous suivrons ces étapes:

```
Installation de Docker
Installation de Kubernetes
Installation de Helm
Installation de Ansible
Déploiement Helm
Installation de Jenkins
Déploiement avec Jenkins
```

Installation de Docker

Dans notre exemple on va installer Docker sous Windows, la procédure est différente pour les autres OS.
Si vous disposez d’un Windows professionnel alors il faut utiliser Docker for windows
Si vous utilisez un Windows familial alorss il faut installer Docker ToolBox
Installation de Kubernetes

Dans notre exemple on va installer Kubernetes sous Windows familial pour cela on va installer minikube. Les différentes procédures d’installation sont décrites ici pour les autres OS et Windows professionnel Le guide de démarrage de minikube: https://kubernetes.io/fr/docs/setup/learning-environment/minikube/ Ci-dessous la liste de quelques commandes utiles avec minikube

									
## Modifier la config minikube
minikube config
    minikube config set memory 1024  //Est un exemple pour reconfigurer la mémoire vive

## Accéder à l'interface web d'administration Kubernetes
minikube dashboard

## Récupérer l'adresse IP du cluster en cours d'exécution
minikube ip 

## Obtenir les logs de l'instance en cours d'exécution pour du débogage
minikube logs 

    -f ou --follow : Suivre en permanence les logs de Minikube
    
    -n ou --length : Nombre de lignes à afficher (50 par défaut)
    
    --problems : Afficher uniquement les logs qui pointent vers des problèmes connus

## Se connecter en ssh sur le nœud Minikube
minikube ssh

## Démarrer un cluster Kubernetes local
minikube start

    --cpu  : Nombre de processeurs alloués au minikube VM (2 par défaut)
    
    --disk-size  : Taille de disque allouée à la VM minikube (format ], où unité = b, k, m or g) (par défaut "20g")
    
    --memory  : Quantité de RAM allouée à la VM mini-cube en Mo (par défaut 2048)
    
    --vm-driver  : Hyperviseur à utiliser (par défaut VirtualBox)

## Supprimer un cluster Kubernetes local
minikube delete

## Obtenir le statut d'un cluster Kubernetes local
minikube status

## Arrêter un cluster Kubernetes en cours d'exécution
minikube stop 

## Afficher le numéro de la version actuelle et la plus récente de Minikube 
minikube update-check 

## Afficher la version de Minikube
minikube version
								

Installation d'Ansible

Pour installer ansible sous Linux il suffit de suivre la documentation officielle https://docs.ansible.com/ansible/latest/installation_guide/index.html Dans notre cas pour l’installation sous windows 10, nous allons activer/installer Ubuntu TLS, ensuite installer ansible Merci à Microsoft. Il est désormais possible d’installer Ubuntu sur Windows 10!! Recherchez les fonctionnalités Windows dans la zone de recherche. Et lorsque le « Activer ou désactiver les fonctionnalités de Windows » apparaît, cliquez dessus.

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/3f2d6ba2-d9e6-4498-b0e4-9f292ceca92a)


Une fenêtre s’ouvrira avec un tas de fonctionnalités. Faites défiler vers le bas et cochez la case Sous-système Windows pour Linux option. Et après cela, cliquez sur le bouton OK.

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/87c052b4-7bbb-485e-92c6-568079be9922)

Ouvrez le Microsoft Store et recherchez Ubuntu pour installer la dernière version.

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/d920cf1d-6d4a-4bc8-afa7-f32058780f61)

Après l’installation, vous verrez un bouton de lancement, utilisez-le pour ouvrir Ubuntu bash. Sur Ubuntu bash, il vous demandera de définir le nom d’utilisateur et le mot de passe de l’utilisateur par défaut. Il est temps d’installer Ansible avec les commandes suivantes.

```								
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```							

Appuyez sur Y lorsqu’il demande…

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/0973a2a4-e1ae-40f4-8c3c-1190365503c6)


L’installation d’ansible s’est terminée avec succès.
Installation de helm

Il existe plusieurs façons d’installer Helm, dans notre cas nous allons utiliser choco pour l’installer sur windows 10

```							
choco install kubernetes-helm
```

#Avec la version 3 de Helm, pas besoin d'exzcuter la commande helm init
								

Voir la documentation pour obtenir plus d’options: https://helm.sh/docs/intro/install/ Maintenant qu’on a installé Docker, Kubernetes, Helm et Ansible sur notre machine windows 10, on va cloner une repository helm chart: https://github.com/Diallos/aws-helm-kubernetes.git dans un répertoire de votre choix.

									
>git clone https://github.com/Diallos/aws-helm-kubernetes.git
>cd aws-helm-kubernetes
								

Il faut démarrer si ce n’est pas déjà fait: docker ensuite kubernetes pour les étapes suivantes. Ensuite On va builder en local l’image docker de notre repository « aws-helm-kubernetes » mais avant de le faire on va setter les variables d’environnement de minikube pour qu’il trouve les images docker en local sinon le cluster kubernetes ne pourra pas le « puller » et on risque d’avoir l’erreur suivante lors du déploiement:

								
Warning Failed 4s (x2 over 19s) kubelet, minikube Failed to pull image "aws-helm-kubernetes:v.01": rpc error: code = Unknown desc = Error response from daemon: pull access denied for aws-app:v.01, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
Warning Failed 4s (x2 over 19s) kubelet, minikube Error: ErrImagePull
								

Pour les systèmes Linux exécuter la commande suivante:

								
>eval $(minikube docker-env)
							

Dans notre cas sous windows 10

								
>minikube docker-env
							

On aura le résultat suivant:

								
>SET DOCKER_TLS_VERIFY=1
>SET DOCKER_HOST=tcp://192.168.99.102:2376
>SET DOCKER_CERT_PATH=C:\Users\diall.minikube\certs
>SET MINIKUBE_ACTIVE_DOCKERD=minikube
							

Donc il faudra setter tous ces variables d’environnement ci-dessous Après on build l’image docker depuis le repo qu’on vient de cloner « aws-helm-kubernetes » et pour ça on va exécuter les commandes suivantes:

								
>npm init --y
>npm install express
>docker build -f Dockerfile -t aws-helm-kubernetes:v.01 .
							

On va obtenir une image docker qui a pour nom aws-helm-kubernetes

>aws-helm-kubernetes:v.01
							
Déployons l’image docker dans kubernetes à l’aider du Helm Chart

Tout d’abord il faut se déplacer dans le répertoire du helm chart « aws-helm-kubernetes/helm » puis l’installer comme ci-dessous:

									
>cd helm
>helm install -f values.yaml hello-world .
								

On obtiendra le résultat suivant:

```									
NAME: hello-world
LAST DEPLOYED: Tue Sep 29 16:02:10 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```						

Et on affiche les pods avec la commande kubectl get pods

									
>kubectl get pods
>
```
NAME READY STATUS RESTARTS AGE
aws-aws-helm-7fd44b78d9-wv9v9 1/1 Running 0 2m12s
traefik-6f7dcc868f-x4sfn 1/1 Running 1 25h
```						

On vient de voir comment builder et déployer en local une image docker dans un cluster kubertenes à l’aide du helm chart
Déployons l’image docker dans kubernetes à l’aider d’Ansible

Dans notre étude de cas, on va utiliser ansible pour déployer l’image docker dans le cluster kubernetes, donc ansible a besoin de docker, du helm et de kubernetes Pour rappel Ansible est installé dans WSL donc il n’est pas accessible depuis notre prompt Windows et depuis le WSL ansible n’a pas accès non plus au docker, au kubernetes et au helm insallé dans Windows. Dans la section suivante on faire de tel sorte que le docker et le kubernetes installés sous windows 10 familial soit directement accessible dans WSL, la procédure est différente pour Windows professionnel mais l’idée reste la même.
Installation de kubectl dans WSL

Exécutons les commandes suivantes pour l’installation kubectl

```									
$ sudo apt-get update && sudoapt-get install -y apt-transport-https   

$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -                       

$ echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list       

$ sudo apt-getupdate               
$ sudo apt-get install -y kubectl
```							

Ensuite on va lier minikube de Windows 10 à notre kubectl dans WSL

```								
$ kubectl config set-cluster minikube --server=https://: --certificate-authority=/mnt/c/Users//.minikube/ca.crt 

$kubectl config set-credentials minikube --client-certificate=/mnt/c/Users//.minikube/client.crt --client-key=/mnt/c/Users//.minikube/client.key

$kubectl config set-context minikube --cluster=minikube --user=Minikube
```							

Où vous devez remplacer:
• par l’IP public de votre cluster Minikube.
• par le port utilisé par le cluster Minikube.
• par votre login Widows
Maintenant vous pouvez vous connecter à votre cluster kubernetes depuis WSL

```								
$ kubectl config use-context minikube
$ kubectl get nodes
```							

Installation de docker dans WSL

Il faut installer docker dans WSL en suivant la procédure officielle: https://docs.docker.com/engine/install/ubuntu/
Ensuite on va faire de tel sorte que le docker installé dans WSL pointe vers notre docker-machine installé sous Windows 10

```							
$ mkdir -p ~/.docker
$ ln -s /mnt/c/Users//.docker/machine/certs/ca.pem ~/.docker/ca.pem
$ ln -s /mnt/c/Users//.docker/machine/certs/ca-key.pem ~/.docker/ca-key.pem
$ ln -s /mnt/c/Users//.docker/machine/certs/cert.pem ~/.docker/cert.pem
$ ln -s /mnt/c/Users//.docker/machine/certs/key.pem ~/.docker/key.pem
```							

Ajouter dans le .bashsrc les lignes suivantes:

```		
export DOCKER_HOST=tcp://192.168.99.100:2376
export DOCKER_CERT_PATH=/mnt/c/Users//.docker/machine/certs
export DOCKER_TLS_VERIFY=1
export COMPOSE_CONVERT_WINDOWS_PATHS=1
```							

A noter qu’il faut remplacer par votre login de Windows

									
Puis en toute dernière position on va installer Helm dans WSL en suivant la 
procédure officielle: https://helm.sh/docs/intro/install/
								

Maintenant que notre environnement a fini d’être configurée passons au deployement de notre image docker dans le cluster kubernetes avec ansible
Nous avons déjà notre playbook Ansible « aws-helm-kubernetes.yml » dans le dossier helm de notre repository « aws-helm-kubernetes/helm » dans windows
Le playbook que nous utiliserons dans cet article reprend les différentes commandes utilisées ci-dessus pour déployer l’image docker dans k8s, il ressemble à ceci:

```					
- hosts: localhost
  vars:
    Namespace: "default"
  gather_facts: no
  connection: local
  tasks:
    - name: Create Namespace {{ Namespace }}
      command: "kubectl create namespace {{ Namespace }}"
      ignore_errors: yes
    - name: Deploy Hello World
      command: "helm install -f values.yaml hello-world ."
      delegate_to: localhost
      ignore_errors: yes
```						

Et, enfin, on démarre docker puis kubernetes et on exécute le playbook.

```							
>cd /c/home/projects/aws-helm-kubernetes/helm
>ansible-playbook aws-helm-kubernetes.yml --connection=local
```						

On voit bien ci-dessous avec la commande « kubectl get pods » dans WSL qu’on a réussi à déployer notre image docker dans kubernetes à l’aide d’ansible et helm

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/14416f49-f721-4451-837b-aa83ecfc11ec)


On vient de voir comment builder et déployer en local une image docker dans un cluster kubertenes avec ansible

Jenkins CI / CD

Jenkins est assez facile à configurer, à modifier et à étendre. Il déploie le code instantanément et génère des rapports de test. Jenkins peut être configuré selon vos besoins.
Notre objectif est d’utiliser Jenkins pour builder et déployer l’image docker dans kubernetes à l’aide de Helm et Ansible
Étapes CI / CD

Le processus CI / CD avec Jenkins en général
Extrait le code,
Exécute des tests unitaires,
Dockerise une application,
Pousse l’application Dockerized dans le Docker Registry , et
Utilise Ansible Playbooks pour déployer l’application Dockerizée sur Kubernetes.
Pour voir comment cela fonctionne, commençons par l’installation de Jenkins.
Nous utiliserons une machine Windows avec Docker et Kubernetes déjà installés.
Installation de Jenkins

Téléchargement Pour télécharger votre copie de Jenkins, allez directement sur la page https://jenkins.io/download/ et sélectionner l’archive qui convient pour votre système d’exploitation. Dans ce tutoriel, j’ai sélectionné le war pour windows. Vous pouvez aussi en fonction des besoins, télécharger l’installeur windows. Seulement dans ce cas, l’étape d’installation va différer par rapport à la présentation qui va suivre. Installation et exécution 2 façons de procéder pour installer Jenkins: via l’archive war ou via l’installeur windows.
Si vous avez opté de télécharger la version avec le zip contenant l’installeur windows, pour effectuer l’installation, il suffit d’extraire et lancer le fichier exécutable, en suite suivre les indications pour terminer l’installation.
Ici nous abordons l’installation via l’archive war.
L'archive war téléchargé est un conteneur tomcat qui peut être installé dans un serveur d’application comme tomcat. Il peut être aussi exécuté directement à partir de la commande suivante depuis une console windows.
java -jar jenkins.war
En cas d’erreur, vérifier que le jdk est bien installé.
Si tout se passe bien, Cette commande démarre Jenkins sur le port 8080. Il sera possible de modifier le port lorsque nous allons configurer l’instance. Vérifier que sur la console windows, aucune erreur n’est reportée. Vous pouvez alors accéder à l’url http://localhost:8080. Patienter pendant le chargement de la page. Merci de ne pas fermer la console windows qui vous a permis de démarrer jenkins.
Suivez les instruction de configuration de démarrage de Jenkins. Si vous voyez la fenêtre ci-dessous, lorsque vous allez sur http://localhost:8080, pas de panique, tout va bien. Jenkins veut juste s’assurer qu’il s’agit bien d’un administrateur du poste sur le quel vous essayez de l’installer. Suivez les instructions. Copiez et collez le mot de passe comme indiqué.

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/3e85f97f-fae3-4ee5-bc5f-b5e45d8f80e1)

Pour obtenir le mot de passe administrateur initial, il suffit d’ouvrir le fichier indiqué sur la copie d’écran:
Collez le mot de passe dans le champ «Mot de passe administrateur» et appuyez sur Continuer. Si vous êtes nouveau sur Jenkins, nous vous recommandons de sélectionner «Installer les plugins suggérés». Vous pouvez maintenant voir que Jenkins installe des plugins.

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/f28122a8-0a5b-4a7f-a684-f595757fc792)

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/9614a6d8-7231-4381-862a-35f225915b8d)

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/09f18256-4f17-451d-bf1f-d687e1ada1b7)

Cliquer sur « Continuer en tant qu’Administrateur » et Vous arrivez sur la page d’accueil de Jenkins

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/e5f15435-808c-420e-9e00-adcbfe0ca4f8)

Préparation du serveur Jenkins

Configurons Jenkins Server, qui implique les plug-ins Docker, Ansible, Helm et Docker.
Installation du plugin Blue Ocean

Accédez à http://localhost:8080/pluginManager/available et recherchez le plug-in « Blue Ocean » et cliquer sur « Install without restart » ou « Installer sans redémarrer »

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/f7340f48-41fd-4726-8ef5-a47380c57555)

Installation du plug-in Jenkins Docker

Le plug-in Docker nous permet d’utiliser Docker pour provisionner dynamiquement des agents de génération, exécuter une seule génération, puis envoyer une image dans le registre. Accédez à http://localhost:8080/pluginManager/available et recherchez le plug-in « CloudBees Docker Build and Publish ». Cliquez sur «Télécharger maintenant» et cochez la case pour redémarrer.
Création du projet de pipeline dans « Blue Ocean »

Chaque fois que vous créez un projet Pipeline dans Blue Ocean, Jenkins en fait un projet Pipeline à plusieurs branches en coulisses. Cela devient évident si vous accédez à l’interface classique de Jenkins après avoir créé un projet Pipeline dans « Blue Ocean » ; vous verrez que Jenkins aura créé le projet comme un projet « Pipeline multi-branches ». Retournons voir Jenkins et l’interface de Blue Ocean. Pour ce faire, on va naviguer sur http://localhost:8080/blue en mode connecté ou aller sur http://localhost:8080/, en mode connecté et cliquer sur « Open Blue Ocean » sur la gauche.
Dans la boîte Bienvenue à Jenkins au centre de l’interface Océan bleu, cliquez sur Créer un nouveau pipeline pour lancer l’assistant de création de pipeline. Note : Si vous ne voyez pas cette case, cliquez sur « Nouveau pipeline » en haut à droite.
Dans la section Où stocker votre code, cliquez sur GitHub.
Création du projet de pipeline dans « Blue Ocean »

Le fichier Jenkins que nous utilisons pour le pipeline ressemble à ceci:

```			
def Namespace = "default"
def ImageName = "aws-helm-kubernetes"
def ImageTag = "v.01"
def Creds = "1960cfcf-bb7d-462d-a545-34e036069f4e"
def GitURL = "https://github.com/Diallos/aws-helm-kubernetes.git"
	
pipeline {

	agent { docker { image 'node:6.3' } }
	
    stages {

		stage('Checkout'){
			steps {
				checkout([$class: 'GitSCM',
				branches: [[name: '*/master']],
				doGenerateSubmoduleConfigurations: false,
				extensions: [],
				submoduleCfg: [],
				userRemoteConfigs: [[credentialsId: "${Creds}", url: "${GitURL}"]]]
				)
			}
		}
		
		stage('BUILD'){
			steps {
			  sh "npm init --y"
			  sh "npm install express"
			}
		}
		stage('Docker Build and Push to local registry'){
			steps {
				sh "docker build -f Dockerfile -t ${ImageName}:${ImageTag} ."
			}
		}
		stage('Deploy on K8s'){
			steps {
				sh "ansible-playbook aws-helm-kubernetes.yml --connection=local"
			}
		}	 
    }
}
```							

Regardons plus en profondeur le fichier Jenkins. Première étape: définir des variables.

```					
def Namespace = "default"
// Le namespace par defaut dans kubernetes
def ImageName = "aws-helm-kubernetes"
// Le nom de notre image docker
def ImageTag = "v.01"
// Le tag de l'image docker
def Creds = "1960cfcf-bb7d-462d-a545-34e036069f4e"
// Les identifiants user/mot de passe de jenkins pour github
def GitURL = "https://github.com/Diallos/aws-helm-kubernetes.git"
//L'url de notre repository
```						

Deuxième étape: extraire / cloner le repo github, ce code est générer depuis le Jenkins via la section « Syntaxe du pipeline » expliqué à la fin de cet article

```			
stage('Checkout'){
	steps {
	checkout([$class: 'GitSCM',
	branches: [[name: '*/master']],
	doGenerateSubmoduleConfigurations: false,
	extensions: [],
	submoduleCfg: [],
	userRemoteConfigs: [[credentialsId: "${Creds}", url: "${GitURL}"]]]
	)
   }
}
```						

Étape trois: exécutez des tests unitaires.

```					
stage('BUILD'){
	steps {
	  sh "npm init --y"
	  sh "npm install express"
	}
}				
```

Étape quatre: Docker build.

```				
stage('Docker Build and Push to local registry'){
	steps {
	sh "docker build -f Dockerfile -t ${ImageName}:${ImageTag} ."
	}
}
```						

Étape cinq: appelez le playbook Ansible pour déployer sur K8s.

```							
stage('Deploy on K8s'){
	steps {
	sh "ansible-playbook aws-helm-kubernetes.yml --connection=local"
	}
}
```						

Accédez à l’application en cours d’exécution dans Kubernetes.

									
$ kubectl get svc // to get the IP/Port of the application
								

Maintenant URL http://public-node-ip: node-port .
Voilà, nous avons démontré un workflow CI / CD simple avec Jenkins, Docker, Ansible, Helm et Kubernetes! Si vous utilisez un référentiel privé pour l’image docker, il faut s’authentifier auprès de ce référentiel
Génération de la syntaxe de pipeline pour Git et le registre Docker à mettre dans le Jenkinsfile

Aller à la section Syntaxe du pipeline ( http://localhost:8080/Nom_du_job/PIPELINE/pipeline-syntax/) qui nous aidera à générer le code de script de pipeline qui peut être utilisé pour définir diverses étapes. Choisissez une étape qui vous intéresse (pour ça va être Git puis Docker), configurez-la, cliquez sur Generate Pipeline Scriptet vous verrez une instruction Pipeline Script qui appellera une étape avec cette configuration.

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/6f16a67b-66b6-4e42-9088-6a6d4107bc55)

Sélectionnez git et fournissez l’URL du référentiel et le nom d’utilisateur / mot de passe. Si le référentiel est privé, il générera la syntaxe pour vous. Si vous utilisez Docker Hub , sélectionnez celui withdocker-registryque nous avons installé auparavant et fournissez les informations d’identification du registre ( https://index.docker.io/v1/pour Docker Hub). Cliquez sur «Générer un script de pipeline» et vous obtiendrez un script comme celui-là que vous utiliserez comme informations d’identification.

									
withDockerRegistry([credentialsId: '85f99fe6-cff4–9064-a85s-a77de72ad87h', url: 'https://index.docker.io/v1/'])
								

Et vous l’utiliserez comme suit dans le Jenkinsfile

```						
node{
  def Namespace = "****"
  def ImageName = "****"
  def Creds = "********"
}
stage('Docker Build, Push'){
    withDockerRegistry([credentialsId: "${Creds}",url:   'https://index.docker.io/v1/']) {
          sh "docker build -t ${ImageName}:${imageTag} ."
          sh "docker push ${ImageName}"
    }
}
```							



# AWS
How to Deploy a Docker Application on AWS ECS with Terraform

 AWS (Amazon Web Services)

Amazon Web Services est une division du groupe américain de commerce électronique Amazon, spécialisée dans les services de cloud computing à la demande pour les entreprises et particuliers.

Comment déployer une application Docker sur AWS ECS avec Terraform.
Passez de la création d’une application Node simple à son conteneurisation, son équilibrage de charge et son déploiement.

Dans cet article, on va voir étape par étape le processus de déploiement d’une application Node sur AWS ECS avec Terraform.

Présentation du guide
Nous suivrons ces étapes:

    Créez une application Node simple et exécutez-la localement
    Dockerizer l’application Node
    Créez un référentiel d’images sur AWS ECR et poussez l’image
    Créez un cluster AWS ECS
    Créez un task (une tâche) AWS ECS
    Créez un service AWS ECS
    Créez un loadbalancer (un équilibreur de charge)

Les technologies utilisées dans ce guide sont:

    Amazon ECS un service d’orchestration de conteneurs entièrement géré
    Amazon ECR un registre de conteneurs Docker entièrement géré
    Terraform: une infrastructure open source comme outil de code

Conditions préalables
-Un compte AWS
-Node installé
-Docker installé et avoir de l’expérience dans son utilisation
-Terraform installé
-AWS Cli

Étape 1. Créez une application de node simple

Tout d’abord, exécutez les commandes suivantes pour créer et accéder au répertoire de notre application:

									
$ mkdir node-docker-ecs 
$ cd node-docker-ecs
								

Ensuite, créez un npmprojet:

									
$ npm init --y
								

Installez Express :

									
$ npm install express
								

Créez un index.jsfichier avec le code suivant:

									
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => res.send('Hello World!'))

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
								

L’application peut alors s’exécuter avec cette commande:

									
$ node index.js
								

Vous devriez voir votre application sur http://localhost:3000/:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/555508c1-d637-41af-966e-8d00b93012fb)


Étape 2. Dockerisation de l’application Node

Si vous êtes nouveau sur Docker, je recommande fortement le guide de démarrage officiel. Je vous promets qu’ils valent bien votre temps. Créez un Dockerfiledans votre répertoire de projet et remplissez-le avec le code suivant:

									
# Use an official Node runtime as a parent image
FROM node:12.7.0-alpine

# Set the working directory to /app
WORKDIR '/app'

# Copy package.json to the working directory
COPY package.json .

# Install any needed packages specified in package.json
RUN yarn

# Copying the rest of the code to the working directory
COPY . .

# Make port 3000 available to the world outside this container
EXPOSE 3000

# Run index.js when the container launches
CMD ["node", "index.js"]
								

Étape 3. Envoyez l’application Node à AWS ECR

Il est maintenant temps de pousser notre conteneur vers un service de registre de conteneurs – dans ce cas, nous utiliserons AWS ECR:
AWS ECR

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/04ece568-b3e1-4e0f-85f9-9fdc7a5f6065)


Au lieu d’utiliser l’interface AWS, nous utiliserons terraform pour créer notre référentiel. Dans votre répertoire, créez un fichier appelé main.tf. Remplissez votre fichier avec le code commenté suivant:

```								
provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-3" # Setting my region to Paris. Use your own region here
}

resource "aws_ecr_repository" "my_first_ecr_repo" {
  name = "my-first-ecr-repo" # Naming my repository
}
```							

Ensuite, dans votre terminal, saisissez:

```							
terraform init
terraform apply
```						

Vous allez obtenir l’erreur ci-dessous

```				
Error: No valid credential sources found for AWS Provider.
        Please see https://terraform.io/docs/providers/aws/index.html for more information on
        providing credentials for the AWS Provider

  on main.tf line 1, in provider "aws":
   1: provider "aws" {
```					

On apprend qu’il faut préciser préciser avec utilisateur on veut créer ses ressources ce qui est normal avant tout. Donc il faut créer un utilisateur depuis la console AWS -> IAM, obtenir ses informations de connexion (ID de clé d’accès et la Clé d’accès secrète), c’est que je viens sur la copie d’écran ci-dessous:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/1c86fdf8-1a9e-4592-a367-d2c990ee0c7b)


Maintenant nous avons les informations manquantes, ensuite il faut autoriser l’utilisateur qu’on vient de créer la possibilité de créer un référentiel ECR, toujours depuis la console IAM il faut attribuer les autorisations nécessaires à notre utilisateur. Voici un minimum d’autorisation à ajouter à un utilisateur AWS, il faut ajouter ces autorisations à l’utilisateur via la console IAM->Utilisateurs->Séléctionner l’utilisateur que vous voulez->Cliquer sur « Ajouter une stratégie » -> Choisir le format JSON et créer les scripts ci-dessous, un script par stratégie ou tout mettre dans un seul script

CloudFormation

```									
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "eksCtlCloudFormation",
            "Effect": "Allow",
            "Action": "cloudformation:*",
            "Resource": "*"
        }
    ]
}
								
```

EKS

```									
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        }
    ]
}
```							

AutoScaling

```								
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "autoscaling:CreateLaunchConfiguration",
                "autoscaling:DeleteLaunchConfiguration"
            ],
            "Resource": "arn:aws:autoscaling:*:*:launchConfiguration:*:launchConfigurationName/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:DeleteAutoScalingGroup",
                "autoscaling:CreateAutoScalingGroup"
            ],
            "Resource": "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLaunchConfigurations"
            ],
            "Resource": "*"
        }
    ]
}
								
```

IAM

```								
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetRole",
                "iam:GetInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "iam:ListInstanceProfiles",
                "iam:AddRoleToInstanceProfile",
                "iam:ListInstanceProfilesForRole",
                "iam:PassRole",
                "iam:DetachRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:GetRolePolicy"
            ],
            "Resource": [
                "arn:aws:iam:::instance-profile/eksctl-*",
                "arn:aws:iam:::role/eksctl-*"
            ]
        }
    ]
}
```							

Networking

```								
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EksInternetGateway",
            "Effect": "Allow",
            "Action": "ec2:DeleteInternetGateway",
            "Resource": "arn:aws:ec2:*:*:internet-gateway/*"
        },
        {
            "Sid": "EksNetworking",
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DeleteSubnet",
                "ec2:DeleteTags",
                "ec2:CreateNatGateway",
                "ec2:CreateVpc",
                "ec2:AttachInternetGateway",
                "ec2:DescribeVpcAttribute",
                "ec2:DeleteRouteTable",
                "ec2:AssociateRouteTable",
                "ec2:DescribeInternetGateways",
                "ec2:CreateRoute",
                "ec2:CreateInternetGateway",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:CreateSecurityGroup",
                "ec2:ModifyVpcAttribute",
                "ec2:DeleteInternetGateway",
                "ec2:DescribeRouteTables",
                "ec2:ReleaseAddress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:DescribeTags",
                "ec2:CreateTags",
                "ec2:DeleteRoute",
                "ec2:CreateRouteTable",
                "ec2:DetachInternetGateway",
                "ec2:DescribeNatGateways",
                "ec2:DisassociateRouteTable",
                "ec2:AllocateAddress",
                "ec2:DescribeSecurityGroups",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteNatGateway",
                "ec2:DeleteVpc",
                "ec2:CreateSubnet",
                "ec2:DescribeSubnets"
            ],
            "Resource": "*"
        }
    ]
}
```
								

Maintenant précisons à terraform/aws l’utilisateur avec le quel nous voulons créer nos ressources

```								
provider "aws" {
version = "~> 2.0"
region = "eu-west-3" # Setting my region to Paris. Use your own region here
access_key = "AKIA2K45FFN26A4I5LXM"
secret_key = "***************************************"
}
resource "aws_ecr_repository" "my_first_ecr_repo" {
name = "my-first-ecr-repo" # Naming my repository
}
```							

```							
terraform apply
```							

Vous verrez ensuite un plan d’exécution avec les modifications que terraform apportera sur AWS. Tapez oui :


![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/0fe5e50a-a639-4ed2-8e40-7315b9ab6247)


Nous utiliserons la commande terraform apply à plusieurs reprises tout au long de ce didacticiel pour déployer nos modifications. Si vous accédez ensuite au service AWS ECR, vous devriez voir votre référentiel nouvellement créé:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/35474f7a-cc78-4634-88d4-af8b126c4d51)

Nous pouvons maintenant pousser notre image d’application Node vers ce référentiel. Cliquez sur le référentiel et cliquez sur Afficher les commandes push. Un modal apparaîtra avec quatre commandes que vous devez exécuter localement afin d’avoir votre image poussée vers votre référentiel:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/3ef9ef14-d485-4324-a355-775948b8b06e)

									
Exemple login pour Windows:
```
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
```
Tout le reste des commandes est donné dans la petite fenêtre qui est affichée

 ```
terraform apply
```							

Une fois que vous avez exécuté ces commandes, vous devriez voir votre image poussée dans votre référentiel:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/d412227a-bf59-45a2-85f6-1906eb2a4946)



AWS ECS

Amazon Elastic Container Service (Amazon ECS) est un service d’orchestration de conteneurs entièrement géré. AWS ECS est un service fantastique pour gérer vos conteneurs. Dans ce guide, nous utiliserons ECS Fargate, car il s’agit d’un service de calcul sans serveur qui vous permet d’exécuter des conteneurs sans provisionner les serveurs. ECS se compose de trois parties: clusters, services et tâches.
Les tâches sont des fichiers JSON qui décrivent comment un conteneur doit être exécuté. Par exemple, vous devez spécifier les ports et l’emplacement de l’image pour votre application.
Un service exécute simplement un nombre spécifié de tâches, les redémarre / tue au besoin. Cela présente des similitudes avec un groupe de mise à l’échelle automatique pour EC2.
Un cluster est un regroupement logique de services et de tâches. Cela deviendra plus clair à mesure que nous construirons.
Étape 4. Créez le cluster

Accédez au service AWS ECS et cliquez sur Clusters . Vous devriez voir la page vide suivante:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/76613568-2a08-4b79-ac19-147e9a98c39a)

Ensuite, ajoutez ce code à votre fichier terraform et redéployez votre infrastructure avec terraform apply:

```				
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster" # Naming the cluster
}
```						

Vous devriez alors voir votre nouveau cluster:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/88991daa-57df-4b5e-b6e6-7a67189cb9d4)

Étape 5. Créez la première tâche

La création d’une tâche est un peu plus complexe que la création d’un cluster. Ajoutez le code commenté suivant à votre script terraform:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/dbe9e607-87d4-4eb7-983a-aa31ddcf0b8e)


Ensuite, ajoutez ce code à votre fichier terraform et redéployez votre infrastructure avec terraform apply:

```			
resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "my-first-task" # Naming our first task
  container_definitions    = DEFINITION
  [
    {
      "name": "my-first-task",
      "image": "${aws_ecr_repository.my_first_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
								
```

Remarquez comment nous spécifions l’image en référençant l’URL du référentiel de notre autre ressource terraform. Notez également comment nous fournissons le mappage de port de 3000. Nous créons également un rôle IAM afin que les tâches disposent des autorisations appropriées pour s’exécuter. Si vous cliquez sur Définitions de tâches dans AWS ECS, vous devriez voir votre nouvelle tâche:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/25ef7ddd-0a90-46a0-b0e0-2b685851c7c6)

Étape 6. Créez le premier service

Génial! Nous avons maintenant un cluster et une définition de tâche. Il est temps que nous fassions tourner quelques conteneurs de notre cluster grâce à la création d’un service qui utilisera notre nouvelle définition de tâche comme modèle. Si nous examinons la documentation dans Terraform pour un service ECS , nous constatons que nous avons besoin au minimum du code terraform suivant:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/11a21213-b206-43bb-b5f4-c4de6d71a1cb)

```
resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.my_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.my_first_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers we want deployed to 3
}
```						

Cependant, si vous essayez de déployer cela, vous obtiendrez l’erreur suivante:

									
Network Configuration must be provided when networkMode 'awsvpc' is specified
								

Comme nous utilisons Fargate, nos tâches doivent spécifier que le mode réseau est awsvpc. Par conséquent, nous devons étendre notre service pour inclure une configuration réseau. Vous ne le saviez peut-être pas encore, mais notre cluster a été automatiquement déployé dans le VPC (Virtual Private Cloud) par défaut de votre compte. Cependant, pour un service, cela doit être explicitement indiqué, même si nous souhaitons continuer à utiliser le VPC et les sous-réseaux par défaut. Tout d’abord, nous devons créer des ressources de référence pour le VPC et les sous-réseaux par défaut afin qu’ils puissent être référencés par nos autres ressources:

```						
# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "eu-west-2a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "eu-west-2b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "eu-west-2c"
}
```							

Ensuite, ajustez votre service pour référencer les sous-réseaux par défaut:

```							
resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.my_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.my_first_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers we want deployed to 3

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
  }
}
```						

Une fois déployé, cliquez sur votre cluster, et vous devriez alors voir votre service:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/e8152b40-05b0-431a-8d09-9757eb03b732)


Si vous cliquez sur votre service et l’onglet Tâches, vous devriez également voir que trois tâches / conteneurs ont été lancés:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/0036ac96-fda6-4c4c-8adc-cb6039d6c37c)

Étape 7. Créez un équilibreur de charge

La dernière étape de ce processus consiste à créer un équilibreur de charge (loadbalancer en anglais) à travers lequel nous pouvons accéder à nos conteneurs. L'idée est d’avoir une URL unique fournie par notre équilibreur de charge qui, en arrière-plan, redirigera notre trafic vers nos conteneurs sous-jacents. Ajoutez le code terraform commenté suivant:

```						
resource "aws_alb" "application_load_balancer" {
  name               = "test-lb-tf" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
```					

Si les messages d’erreurs sur les autorisations sont encodés, vous pouvez les décoder avec la commande suivante: aws sts decode-authorization-message –encoded-message encoded-message. 

Notez comment nous créons également un groupe de sécurité pour l’équilibreur de charge. Ce groupe de sécurité est utilisé pour contrôler le trafic autorisé vers et depuis l’équilibreur de charge. Si vous déployez votre code, accédez à EC2 et cliquez sur Équilibreurs de charge, vous devriez voir ce qui suit:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/f7add1ed-d9f0-4ac9-b02d-e34c8a854c94)


Notez que si vous ouvrez l’URL (flèche rose ci-dessus), vous verrez une erreur, car vous n’avez pas spécifié où le trafic doit être dirigé:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/21c6cbf1-297e-4c6d-ba77-df1b2ae3163d)


Pour diriger le trafic, nous devons créer un groupe cible et un écouteur. Chaque groupe cible est utilisé pour acheminer les demandes vers une ou plusieurs cibles enregistrées (dans notre cas, des conteneurs). Lorsque vous créez chaque règle d’écoute, vous spécifiez un groupe cible et des conditions. Le trafic est ensuite transmis au groupe cible correspondant. Créez-les avec les éléments suivants:

```						
resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" # Referencing the default VPC
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}" # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our tagrte group
  }
}
```							

Si vous affichez l’onglet Écouteurs de votre équilibreur de charge, vous devriez voir un écouteur qui transfère le trafic vers votre groupe cible:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/3a7f43ce-9427-40e7-a895-31f3b635ede5)



Si vous cliquez sur votre groupe cible puis sur la balise Targets, vous verrez un message disant: «Il n’y a pas de cibles enregistrées pour ce groupe cible»:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/d8298168-8971-461f-a5f9-811912496fac)

En effet, nous n’avons pas lié notre service ECS à notre équilibreur de charge. Nous pouvons changer cela en modifiant notre code de service pour référencer les cibles:

```				
resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.my_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.my_first_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.my_first_task.family}"
    container_port   = 3000 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
  }
}
```						

Ensuite, si vous actualisez l’onglet Cibles, vous devriez voir vos trois conteneurs:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/dcd2d5c8-4eb1-4681-90fe-a056e89155fe)

Notez comment l’état de chaque conteneur est malsain. En effet, le service ECS n’autorise pas le trafic par défaut. Nous pouvons changer cela en créant un groupe de sécurité pour le service ECS qui autorise uniquement le trafic provenant du groupe de sécurité de l’équilibreur de charge d’application:

```
resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"  # Naming our first service
  cluster         = "${aws_ecs_cluster.my_cluster.id}"# Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.my_first_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.my_first_task.family}"
    container_port   = 3000 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
}


resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
```							

Si vous vérifiez vos conteneurs cibles, ils devraient maintenant être sains:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/b9395df1-e6a2-4eb0-b8c5-b31b652300a5)

Vous devriez également pouvoir accéder à vos conteneurs via l’URL de votre équilibreur de charge:

![image](https://github.com/Diallos/aws-helm-kubernetes/assets/12511767/d7261f71-9400-4c5d-bc0b-788d3b92e402)

Conclusion

Félicitations d’avoir réussi jusqu’ici! J’espère que vous avez beaucoup appris.
Veuillez nous faire part de vos réflexions et commentaires, et bonne chance dans votre parcours AWS.
