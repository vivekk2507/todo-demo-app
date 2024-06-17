pipeline {
    agent any
    
    stages {
        stage('Generate SSH Key Pair') {
            steps {
                script {
                    sh 'ssh-keygen -t rsa -b 2048 -f my-key -y'
                }
            }
        }
        
        stage('Checkout SCM') {
            steps {
                git branch: 'main', credentialsId: 'github-pat', url: 'https://github.com/vivekk2507/todo-demo-app'
            }
        }
        
        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Code Quality Check with SonarQube') {
            steps {
                // Assuming SonarQube scanner is configured globally
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('Push Artifact to Nexus') {
            steps {
                // Add the necessary steps to push the artifact to Nexus
            }
        }
        
        stage('Build Docker Image from Nexus') {
            steps {
                // Modify Dockerfile.jvm to copy and build from Nexus
                // Assuming Docker is installed and configured
                sh 'docker build -t my-docker-image:nexus .'
            }
        }
        
        stage('Create Container Image for PostgreSQL') {
            steps {
                // Add steps to build the PostgreSQL container image
                // based on the instructions in the README.md file
            }
        }
        
        stage('Push Docker Images to Docker Hub') {
            steps {
                // Push the built Docker images to Docker Hub
                sh 'docker push my-docker-image:nexus'
                // Push PostgreSQL image as well
            }
        }
        
        stage('Create Infrastructure using Terraform') {
            steps {
                // Assuming Terraform is installed and configured
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Deploy App using Terraform') {
            steps {
                // Assuming Terraform deployment steps are defined
            }
        }
        
        stage('Apply Orchestration using Kubernetes') {
            steps {
                // Assuming Kubernetes resources are defined and Terraform is configured to apply them
            }
        }
        
        stage('Apply Prometheus and Grafana using Terraform or Helm') {
            steps {
                // Assuming Prometheus and Grafana configurations are defined either using Terraform or Helm
            }
        }
        
        stage('Create Alerts using Prometheus') {
            steps {
                // Assuming Prometheus alert rules are defined
            }
        }
    }
}

