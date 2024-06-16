pipeline {
    agent any
    stages {
        stage('Checkout SCM') {
            steps {
                git credentialsId: 'github-pat', url: 'https://github.com/vivekk2507/todo-demo-app'
            }
        }
        stage('Clone repository') {
            steps {
                // Ensure you're using the correct URL and credentials ID
                git credentialsId: 'github-pat', url: 'https://github.com/your-repo/todo-demo-app.git'
            }
        }
        // Other stages...
    }
    post {
        always {
            cleanWs()
        }
    }
}
