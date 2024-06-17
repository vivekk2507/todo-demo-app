pipeline {
    agent any
    
    environment {
        AWS_REGION = 'ap-south-1'
        AWS_INSTANCE_TYPE = 't3.medium'
        JENKINS_IP = '43.204.143.128/32'  // Replace with your actual Jenkins IP address in CIDR notation
        KEYPAIR_NAME = '/var/lib/jenkins/workspace/my-key.pub'  // Updated key pair name
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', credentialsId: 'github-pat', url: 'https://github.com/vivekk2507/todo-demo-app'
            }
        }
        
        stage('Setup Terraform') {
            steps {
                dir('') {
                    withAWS(credentials: 'awsdemo') {
                        sh 'terraform init'
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('') {
                    withAWS(credentials: 'awsdemo') {
                        sh "terraform plan -var='region=${AWS_REGION}' -var='instance_type=${AWS_INSTANCE_TYPE}' -var='jenkins_ip=${JENKINS_IP}' -var='keypair_name=${KEYPAIR_NAME}' -out=tfplan"
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('') {
                    withAWS(credentials: 'awsdemo') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
        
        stage('Deploy App') {
            steps {
                echo "Deploying application"
                // Add deployment steps if needed
            }
        }
    }
    
    post {
        always {
            // Clean up Jenkins workspace
            cleanWs()
        }
    }
}
