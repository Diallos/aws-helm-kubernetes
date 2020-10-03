#!/usr/bin/env groovy
pipeline {

	def Namespace = "default"
	def ImageName = "aws-helm-kubernetes"
	def ImageTag = "v.01"
	def Creds = "1960cfcf-bb7d-462d-a545-34e036069f4e"
	def GitURL = "https://github.com/Diallos/aws-helm-kubernetes.git"

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