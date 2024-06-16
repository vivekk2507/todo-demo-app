pipeline {
    agent any
    
    environment {
        AWS_REGION = 'ap-south-1'
        AWS_INSTANCE_TYPE = 't3.medium'
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                // Checkout the GitHub repository containing Terraform files
                git branch: 'main', credentialsId: 'github-pat', url: 'https://github.com/vivekk2507/todo-demo-app'
            }
        }
        
        stage('Setup Terraform') {
            steps {
                dir('') { // No directory specified to run commands in the root of the repository
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('') { // No directory specified to run commands in the root of the repository
                    sh "terraform plan -var='region=${AWS_REGION}' -var='instance_type=${AWS_INSTANCE_TYPE}' -out=tfplan"
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('') { // No directory specified to run commands in the root of the repository
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
