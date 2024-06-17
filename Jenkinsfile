pipeline {
    agent any
     environment {
        PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/snap/bin:/opt/maven/apache-maven-3.9.7/bin:$PATH"
    }
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
                script {
                    // Downloading and setting up Maven
                    sh 'sudo mkdir -p /opt/maven'
                    sh 'sudo wget -O /opt/maven/apache-maven-3.9.7.tar.gz https://downloads.apache.org/maven/maven-3/3.9.7/binaries/apache-maven-3.9.7-bin.tar.gz'
                    sh 'sudo tar -xzvf /opt/maven/apache-maven-3.9.7.tar.gz -C /opt/maven'
                    sh 'export PATH=/opt/maven/apache-maven-3.9.7/bin:$PATH'
                    
                    // Running Maven clean package without tests
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
        
        stage('Code Quality Check with SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('Push Artifact to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
                    sh 'mvn deploy -DrepositoryId=nexus -Durl=http://nexus.example.com/repository/maven-releases -Dmaven.test.skip=true'
                }
            }
        }
        
        stage('Build Docker Image from Nexus') {
            steps {
                sh 'docker build -t my-docker-image:nexus http://nexus.example.com/repository/docker-images/my-docker-image:latest'
            }
        }
        
        stage('Create Container Image for PostgreSQL') {
            steps {
                sh 'docker build -t postgresql-image:latest -f path/to/postgresql/Dockerfile .'
            }
        }
        
        stage('Push Docker Images to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh 'docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD'
                    sh 'docker push my-docker-image:nexus'
                    sh 'docker push postgresql-image:latest'
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
                sh 'terraform apply -auto-approve'
            }
        }
        
        stage('Apply Orchestration using Kubernetes') {
            steps {
                sh 'kubectl apply -f path/to/kubernetes/resources'
            }
        }
        
        stage('Apply Prometheus and Grafana using Terraform or Helm') {
            steps {
                sh 'helm install prometheus stable/prometheus --namespace monitoring'
                sh 'helm install grafana stable/grafana --namespace monitoring'
            }
        }
        
        stage('Create Alerts using Prometheus') {
            steps {
                sh 'kubectl apply -f path/to/prometheus/alerts'
            }
        }
    }
}
