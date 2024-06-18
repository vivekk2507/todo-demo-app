pipeline {
    agent any
    
    environment {
        DOCKERHUB_USERNAME = credentials('dockerhub-username') // Jenkins credential ID for Docker Hub username
        DOCKERHUB_PASSWORD = credentials('dockerhub-password') // Jenkins credential ID for Docker Hub password
        DOCKER_IMAGE = 'vivekloggedin/my-docker-image:latest' // Adjust repository name accordingly
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
                git branch: 'main', credentialsId: 'github-pat', url: 'https://github.com/vivekk2507/todo-demo-app'
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
        
        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_USERNAME, DOCKERHUB_PASSWORD) {
                            sh "docker push ${DOCKER_IMAGE}"
                        }
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
