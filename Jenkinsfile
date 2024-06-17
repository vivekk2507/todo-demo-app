pipeline {
    agent any
    
 
    
    stages {
        stage('Generate SSH Key Pair') {
            steps {
                script {
                
                    // Generate SSH key pair
                    sh 'ssh-keygen -t rsa -b 2048 -f my-key'
                }
            }
        }
        
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
                        sh "terraform plan -out=tfplan"
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
            //cleanWs()
        }
    }
}
