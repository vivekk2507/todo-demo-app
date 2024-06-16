pipeline {
    agent any
    
    environment {
        TF_WORKSPACE = '/var/lib/jenkins/workspace/oproj'
        AWS_REGION = 'ap-south-1'
        AWS_INSTANCE_TYPE = 't3.medium'
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                // Checkout the repository from GitHub
                git branch: 'main', credentialsId: 'github-pat', url: 'https://github.com/vivekk2507/todo-demo-app'
            }
        }
        
        stage('Setup Terraform') {
            steps {
                dir(TF_WORKSPACE + '/terraform-ec2') {
                    // Initialize Terraform
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir(TF_WORKSPACE + '/terraform-ec2') {
                    // Run Terraform plan
                    sh 'terraform plan -var="region=${AWS_REGION}" -var="instance_type=${AWS_INSTANCE_TYPE}" -out=tfplan'
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir(TF_WORKSPACE + '/terraform-ec2') {
                    // Apply Terraform changes
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        
        stage('Deploy App') {
            steps {
                // Replace with your deployment steps if applicable
                sh 'echo "Deploying application"'
                // Example: Docker build and push, Kubernetes deployment, etc.
            }
        }
    }
    
    post {
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}
