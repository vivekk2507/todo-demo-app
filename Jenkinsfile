pipeline {
    agent any
    
    environment {
        AWS_REGION = 'ap-south-1'
        AWS_INSTANCE_TYPE = 't3.medium'
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', credentialsId: 'github-pat', url: 'https://github.com/vivekk2507/todo-demo-app'
            }
        }
        
        stage('Setup Terraform') {
            steps {
                dir('/var/lib/jenkins/workspace/oproj_ws-cleanup_1718575156214') {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('/var/lib/jenkins/workspace/oproj_ws-cleanup_1718575156214') {
                    sh 'terraform plan -var="region=${AWS_REGION}" -var="instance_type=${AWS_INSTANCE_TYPE}" -out=tfplan'
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                 dir('/var/lib/jenkins/workspace/oproj_ws-cleanup_1718575156214') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        
        stage('Deploy App') {
            steps {
                sh 'echo "Deploying application"'
                // Add deployment steps if needed
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
