pipeline {
    node{
		def Namespace = "default"
		def ImageName = "aws-helm-kubernetes"
		def imageTag = "v.01"
		def Creds = "1960cfcf-bb7d-462d-a545-34e036069f4e"
		def GitURL = "https://github.com/Diallos/aws-helm-kubernetes.git"
	}

    stages {

		stage('Checkout'){
			checkout([$class: 'GitSCM',
			branches: [[name: '*/master']],
			doGenerateSubmoduleConfigurations: false,
			extensions: [],
			submoduleCfg: [],
			userRemoteConfigs: [[credentialsId: "${Creds}", url: "${GitURL}"]]]
			)
		}
		
		stage('BUILD'){
			  sh "npm init --y"
			  sh "npm install express"
		}
		stage('Docker Build and Push to local registry'){
			 sh "docker build -f Dockerfile -t ${ImageName}:${imageTag} ."
		}
		stage('Deploy on K8s'){
			sh "ansible-playbook aws-helm-kubernetes.yml --connection=local"
		}	 
    }
}