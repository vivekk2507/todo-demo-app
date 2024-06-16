pipeline {
    agent any

    environment {
        TF_VERSION = '0.14.7' // Replace with your Terraform version
    }

    stages {
        stage('Clone repository') {
            steps {
                git url: 'https://github.com/your-repo/todo-demo-app.git', branch: 'main'
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline execution failed!'
        }
    }
}
