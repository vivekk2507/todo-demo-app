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
                dir('') {  // Adjust directory path as per your Jenkins workspace structure
                    withAWS(credentials: 'awsdemo') {
                        sh 'terraform init'  // Terraform initialization command
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('') {  // Adjust directory path as per your Jenkins workspace structure
                    withAWS(credentials: 'awsdemo') {
                        sh "terraform plan -var='region=${AWS_REGION}' -var='instance_type=${AWS_INSTANCE_TYPE}' -var='jenkins_ip=${JENKINS_IP}' -out=tfplan"
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('') {  // Adjust directory path as per your Jenkins workspace structure
                    withAWS(credentials: 'awsdemo') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
        
        stage('Copy Key Pair') {
            steps {
                script {
                    withAWS(credentials: 'awsdemo') {
                        // Create and save the key pair locally on Jenkins server
                        sh "aws ec2 create-key-pair --key-name ${KEYPAIR_NAME} --query 'KeyMaterial' --output text > ${KEYPAIR_NAME}.pem"
                        sh "chmod 400 ${KEYPAIR_NAME}.pem"
                        sh "ssh-keygen -y -f ${KEYPAIR_NAME}.pem > ${KEYPAIR_NAME}.pub"
                        sh "puttygen ${KEYPAIR_NAME}.pem -o ${KEYPAIR_NAME}.ppk"
                        
                        // Copy the .ppk file to the local Windows machine using SCP
                        bat "scp -o StrictHostKeyChecking=no ${KEYPAIR_NAME}.ppk ${LOCAL_MACHINE_USERNAME}@${LOCAL_MACHINE_IP}:${LOCAL_PPK_PATH}\\${KEYPAIR_NAME}.ppk"
                    }
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

