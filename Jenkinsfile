pipeline {
    agent any
    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    checkout([$class: 'GitSCM',
                              branches: [[name: '*/main']],
                              userRemoteConfigs: [[url: 'https://github.com/vivekk2507/todo-demo-app', credentialsId: 'github-pat']]
                    ])
                }
            }
        }
        stage('Clone repository') {
            steps {
                git branch: 'main', credentialsId: 'github-pat', url: 'https://github.com/vivekk2507/todo-demo-app'
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
