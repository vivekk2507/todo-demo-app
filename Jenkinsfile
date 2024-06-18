pipeline {
    agent any
    
    environment {
          DOCKERHUB_CREDENTIALS = 'dockerhu'
        GITHUB_CREDENTIALS = 'github-pat'
        GITHUB_REPO = 'https://github.com/vivekk2507/todo-demo-app'
        DOCKER_IMAGE = 'vivekloggedin/my-docker-image:latest'
        POSTGRESQL_IMAGE = 'docker.io/library/postgres:14'
        AWS_CREDENTIALS = credentials('awsc') // Replace with your AWS credentials ID in Jenkins
    }
    
    stages {
        stage('Generate SSH Key Pair') {
            steps {
                script {
                    sh '''
                        mkdir -p terraform
                        ssh-keygen -t rsa -b 2048 -f terraform/my-key -N "" -y
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
                        docker build -t ${DOCKER_IMAGE} -f Dockerfile.jvm .
                    '''
                }
            }
        }

        stage('Pull PostgreSQL Docker Image') {
            steps {
                script {
                    docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                        sh "docker pull ${POSTGRESQL_IMAGE}"
                    }
                }
            }
        }
        
        stage('Run PostgreSQL Container') {
            steps {
                script {
                    sh '''
                        CONTAINER_ID=$(docker ps -a -q -f name=postgres-quarkus-rest-http-crud)
                        if [ ! -z "$CONTAINER_ID" ]; then
                            docker stop $CONTAINER_ID || true
                            docker rm $CONTAINER_ID || true
                        fi
                    '''
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
                    docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
        
        stage('Create Infrastructure using Terraform') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awsc']]) {
                    dir('terraform') {
                        script {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                            // Capture the public IP from Terraform output
                            def remoteHost = sh (returnStdout: true, script: 'terraform output -json public_ip') // Adjust the output name as per your Terraform output
                            // Assign to environment variable
                            env.REMOTE_HOST = remoteHost.trim()
                        }
                    }
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                script {
                    // SSH into remote host and deploy application as Docker container
                    sshagent(credentials: ['<jenkins_ssh_key_id>']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@${REMOTE_HOST} \
                                'sudo docker pull ${DOCKER_IMAGE} && \
                                sudo docker stop my-app-container || true && \
                                sudo docker rm my-app-container || true && \
                                sudo docker run -d --name my-app-container -p 8080:8080 ${DOCKER_IMAGE}'
                        """
                    }
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

