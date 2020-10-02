pipeline {
    node{
		def Namespace = "default"
		def ImageName = "Demo/K8s"
		def Creds = "3dhf6hhd-a300-78ee-kjg5-7j3dfhjg7764"
	}

    stages {
	
		try{
		
			stage('Checkout'){
			  git 'CI/CD-K8s.git
			  sh "git rev-parse --short HEAD > .git/commit-id"
			  imageTag= readFile('.git/commit-id').trim()
			}
			
			stage('RUN Unit Tests'){
				  sh "npm install"
				  sh "npm test"
			}
			stage('Docker Build, Push'){
				withDockerRegistry([credentialsId: "${Creds}", url: 'https://index.docker.io/v1/']) {
				  sh "docker build -t ${ImageName}:${imageTag} ."
				  sh "docker push ${ImageName}"
				}
			}
			stage('Deploy on K8s'){
				sh "ansible-playbook /var/lib/jenkins/ansible/Demo-deploy/deploy.yml  --user=jenkins --extra-vars ImageName=${ImageName} --extra-vars imageTag=${imageTag} --extra-vars Namespace=${Namespace}"
			}
			 
		}catch (err) {
			  currentBuild.result = 'FAILURE'
			}
		}
    }
}