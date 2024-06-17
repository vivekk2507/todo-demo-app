pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhu'
        SONARQUBE_ENV = 'SonarQube'
        GITHUB_CREDENTIALS = 'github-pat'
        GITHUB_REPO = 'https://github.com/vivekk2507/todo-demo-app'
        DOCKER_IMAGE = 'my-docker-image:latest'
        POSTGRESQL_IMAGE = 'postgresql-image:latest'
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
                }
            }
        }
        
         //stage('Code Quality Check with SonarQube') {
          //  steps {
           //  withSonarQubeEnv(SONARQUBE_ENV) {
             //  sh 'mvn sonar:sonar'
             //  }
         // }
     // }
        
        stage('Build Docker Image') {
            steps {

                
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }
        
        stage('Create Container Image for PostgreSQL') {
            steps {
                sh "docker build -t ${POSTGRESQL_IMAGE} -f path/to/your/postgresql/Dockerfile ."
            }
        }
        
        stage('Push Docker Images to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                        sh "docker push ${DOCKER_IMAGE}"
                        sh "docker push ${POSTGRESQL_IMAGE}"
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
        
        stage('Apply Prometheus and Grafana using Terraform or Helm') {
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
    }
}
