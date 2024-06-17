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
                // Assuming Nexus credentials are configured
                withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
                    sh 'mvn deploy -DrepositoryId=nexus -Durl=http://nexus.example.com/repository/maven-releases -Dmaven.test.skip=true'
                }
            }
        }
        
        stage('Build Docker Image from Nexus') {
            steps {
                // Assuming Docker is installed and configured
                sh 'docker build -t my-docker-image:nexus .'
            }
        }
        
        stage('Create Container Image for PostgreSQL') {
            steps {
                // Assuming Docker is installed and configured
                // Using the instructions from the README.md file to build PostgreSQL container image
                sh 'docker build -t postgresql-image:latest -f path/to/postgresql/Dockerfile .'
            }
        }
        
        stage('Push Docker Images to Docker Hub') {
            steps {
                // Assuming Docker Hub credentials are configured
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh 'docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD'
                    sh 'docker push my-docker-image:nexus'
                    sh 'docker push postgresql-image:latest'
                }
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
                // Example: sh 'terraform apply -auto-approve'
            }
        }
        
        stage('Apply Orchestration using Kubernetes') {
            steps {
                // Assuming Kubernetes resources are defined and Terraform is configured to apply them
                // Example: sh 'kubectl apply -f path/to/kubernetes/resources'
            }
        }
        
        stage('Apply Prometheus and Grafana using Terraform or Helm') {
            steps {
                // Assuming Prometheus and Grafana configurations are defined either using Terraform or Helm
                // Example: sh 'helm install prometheus stable/prometheus --namespace monitoring'
                // Example: sh 'helm install grafana stable/grafana --namespace monitoring'
            }
        }
        
        stage('Create Alerts using Prometheus') {
            steps {
                // Assuming Prometheus alert rules are defined
                // Example: sh 'kubectl apply -f path/to/prometheus/alerts'
            }
        }
    }
}

