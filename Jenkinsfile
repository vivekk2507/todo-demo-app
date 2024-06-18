pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhu'
        SONARQUBE_ENV = 'SonarQube'
        GITHUB_CREDENTIALS = 'github-pat'
        GITHUB_REPO = 'https://github.com/vivekk2507/todo-demo-app'
        DOCKER_IMAGE = 'vivekloggedin/my-docker-image:latest'
        POSTGRESQL_IMAGE = 'docker.io/library/postgres:14'
    }
    
    stages {
        stage('Generate SSH Key Pair') {
            steps {
                script {
                    // Generate SSH key pair if not already present
                    sh '''
                        if [ ! -f my-key ]; then
                            ssh-keygen -t rsa -b 2048 -f my-key -N ""
                        fi
                    '''
                }
            }
        }
        
        stage('Checkout SCM') {
            steps {
                // Checkout code from GitHub repository
                git branch: 'main', credentialsId: GITHUB_CREDENTIALS, url: GITHUB_REPO
            }
        }
        
        stage('Build with Maven') {
            steps {
                script {
                    // Build the Quarkus application with Maven
                    sh 'mvn clean package -DskipTests'
                    sh 'mvn quarkus:build -Dquarkus.package.type=fast-jar'
                }
            }
        }
        
        stage('Prepare Docker Context') {
            steps {
                script {
                    // Prepare Docker context for building Docker image
                    sh '''
                        mkdir -p docker-context/target/quarkus-app
                        cp -r target/quarkus-app/app target/quarkus-app/lib target/quarkus-app/quarkus target/quarkus-app/quarkus-app-dependencies.txt target/quarkus-app/quarkus-run.jar docker-context/target/quarkus-app/
                        cp src/main/docker/Dockerfile.jvm docker-context/
                    '''
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using Dockerfile.jvm
                    sh '''
                        cd docker-context
                        docker build -t ${DOCKER_IMAGE} -f Dockerfile.jvm .
                    '''
                }
            }
        }

        stage('Pull PostgreSQL Docker Image') {
            steps {
                script {
                    // Pull PostgreSQL Docker image from Docker Hub
                    docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                        sh "docker pull ${POSTGRESQL_IMAGE}"
                    }
                }
            }
        }
        
        stage('Run PostgreSQL Container') {
            steps {
                script {
                    // Stop and remove any existing container with the same name
                    sh '''
                        CONTAINER_ID=$(docker ps -a -q -f name=postgres-quarkus-rest-http-crud)
                        if [ ! -z "$CONTAINER_ID" ]; then
                            docker stop $CONTAINER_ID || true
                            docker rm $CONTAINER_ID || true
                        fi
                    '''
                    // Run PostgreSQL container
                    sh '''
                        docker run --ulimit memlock=-1:-1 -d --rm=true \
                            --name postgres-quarkus-rest-http-crud \
                            -e POSTGRES_USER=restcrud \
                            -e POSTGRES_PASSWORD=restcrud \
                            -e POSTGRES_DB=rest-crud \
                            -p 5433:5432 ${POSTGRESQL_IMAGE}
                    '''
                }
            }
        }
        
        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Push Docker image to Docker Hub
                    docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
        
        stage('Setup Terraform Configuration') {
            steps {
                script {
                    // Ensure Terraform configuration files are in place
                    dir('terraform') {
                        git branch: 'main', credentialsId: GITHUB_CREDENTIALS, url: 'https://github.com/vivekk2507/todo-demo-app'
                    }
                }
            }
        }
        
        stage('Create Infrastructure using Terraform') {
            steps {
                dir('terraform') {
                    // Initialize Terraform and apply infrastructure changes
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Deploy App using Terraform') {
            steps {
                dir('terraform') {
                    // Deploy application using Terraform
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Apply Orchestration using Kubernetes') {
            steps {
                // Apply Kubernetes resources
                sh 'kubectl apply -f path/to/kubernetes/resources'
            }
        }
        
        stage('Apply Prometheus and Grafana using Helm') {
            steps {
                script {
                    // Add Helm repositories and install Prometheus and Grafana
                    sh 'helm repo add prometheus-community https://prometheus-community.github.io/helm-charts'
                    sh 'helm repo add grafana https://grafana.github.io/helm-charts'
                    sh 'helm repo update'
                    sh 'helm install prometheus prometheus-community/prometheus --namespace monitoring'
                    sh 'helm install grafana grafana/grafana --namespace monitoring'
                }
            }
        }
        
        stage('Create Alerts using Prometheus') {
            steps {
                // Apply Prometheus alerts
                sh 'kubectl apply -f path/to/prometheus/alerts'
            }
        }
        
        stage('Run Quarkus Application') {
            steps {
                // Run Quarkus application
                sh 'java -jar target/quarkus-app/quarkus-run.jar'
            }
        }
    }
}
