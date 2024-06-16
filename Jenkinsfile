pipeline {
    agent any
    
    stages {
        stage('Setup') {
            steps {
                // Checkout your Git repository where Terraform files are located
                git url: 'https://github.com/vivekk2507/todo-demo-app', branch: 'main'
            }
        }
        stage('Terraform') {
            steps {
                script {
                    // Change to Terraform project directory
                    dir('terraform-ec2') {
                        // Initialize Terraform
                        sh 'terraform init'
                        
                        // Plan Terraform deployment
                        sh 'terraform plan'
                        
                        // Apply Terraform configuration (auto-approve to avoid user prompt)
                        sh 'terraform apply -auto-approve'
                        
                        // Optionally, you can capture Terraform outputs
                        sh 'terraform output'
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace after pipeline execution
            cleanWs()
        }
    }
}
