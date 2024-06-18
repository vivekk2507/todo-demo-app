pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhu'
        SONARQUBE_ENV = 'SonarQube'
        GITHUB_CREDENTIALS = 'github-pat'
        GITHUB_REPO = 'https://github.com/vivekk2507/todo-demo-app'
        DOCKER_IMAGE = 'my-docker-image:latest'
        POSTGRESQL_IMAGE = 'docker.io/library/postgres:14'
    }
    
    stages {
        stage('Generate SSH Key Pair') {
            steps {
                script {
                    sh '''
                        if [ -f my-key ]; then
                            rm my-key my-key.pub
                        fi
                        ssh-keygen -t rsa -b 2048 -f my-key -N ""
                    '''
                }
            }
        }
        
        stage('Checkout SCM') {
            steps {
                git branch: 'main', credentialsId: GITHUB_CREDENTIALS, url: GITHUB_REPO
            }
        }
        
        stage('Build with Maven') {
            steps {
                script {
                    sh 'mvn clean package -DskipTests'
                    sh 'mvn quarkus:build -Dquarkus.package.type=fast-jar'
                }
            }
        }
        
        stage('Prepare Docker Context') {
            steps {
                script {
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
                    sh '''
                        cd docker-context
                        echo "Current Directory:"
                        pwd
                        echo "Directory Contents:"
                        ls -l
                        docker build -t ${DOCKER_IMAGE} -f Dockerfile.jvm .
                    '''
                }
            }
        }

        stage('Pull PostgreSQL Docker Image') {
            steps {
                script {
                    sh "docker pull ${POSTGRESQL_IMAGE}"
                }
            }
        }
        
        stage('Run PostgreSQL Container') {
            steps {
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
        
        stage('Push Docker Images to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
        
        stage('Create Infrastructure using Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Deploy App using Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Apply Orchestration using Kubernetes') {
            steps {
                sh 'kubectl apply -f path/to/kubernetes/resources'
            }
        }
        
        stage('Apply Prometheus and Grafana using Helm') {
            steps {
                script {
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
                sh 'kubectl apply -f path/to/prometheus/alerts'
            }
        }
        
        stage('Run Quarkus Application') {
            steps {
                sh 'java -jar target/quarkus-app/quarkus-run.jar'
            }
        }
    }
}
