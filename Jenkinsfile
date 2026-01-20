pipeline {
    agent any

    environment {
        // Replace with your Docker Hub user
        DOCKER_REGISTRY = "docker.io/vinodgangwar92"
        IMAGE_NAME = "newlab2"
        // Jenkins stored credentials ID (username + password/token)
        CREDENTIALS_ID = "dockerhub-creds"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${CREDENTIALS_ID}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat '''
                    echo Logging into Docker Hub...
                    docker login %DOCKER_REGISTRY% -u %DOCKER_USER% -p %DOCKER_PASS%
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                echo Building Docker image...
                docker build -t %DOCKER_REGISTRY%/%IMAGE_NAME%:%BUILD_NUMBER% .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                bat '''
                echo Pushing Docker image...
                docker push %DOCKER_REGISTRY%/%IMAGE_NAME%:%BUILD_NUMBER%
                docker tag %DOCKER_REGISTRY%/%IMAGE_NAME%:%BUILD_NUMBER% %DOCKER_REGISTRY%/%IMAGE_NAME%:latest
                docker push %DOCKER_REGISTRY%/%IMAGE_NAME%:latest
                '''
            }
        }

    }

    post {
        success {
            echo "Docker build & push completed successfully!"
        }
        failure {
            echo "Build or push failed — check logs above."
        }
    }
}
