pipeline {
    agent any
    
    environment {
        AWS_REGION = 'ap-south-1'
        AWS_INSTANCE_TYPE = 't3.medium'
        JENKINS_IP = '43.204.143.128/32'  // Replace with your actual Jenkins IP address in CIDR notation
        KEYPAIR_NAME = 'example-key'
        LOCAL_PPK_PATH = 'C:\\Users\\abina\\Downloads\\devops\\keys'  // Adjust this path on your local Windows machine
        LOCAL_MACHINE_USERNAME = 'abinash'  // Replace with your Windows username
        LOCAL_MACHINE_IP = '110.224.88.81'  // Replace with your Windows machine IP
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
                        sh "terraform plan -var='region=${AWS_REGION}' -var='instance_type=${AWS_INSTANCE_TYPE}' -var='jenkins_ip=${JENKINS_IP}' -out=tfplan"
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
