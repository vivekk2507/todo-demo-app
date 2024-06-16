pipeline {
    agent any

    environment {
        TF_VAR_aws_region = 'ap-south-1'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/vivekk2507/todo-demo-app', branch: 'main'
            }
        }

        stage('Setup Terraform') {
            steps {
                script {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

