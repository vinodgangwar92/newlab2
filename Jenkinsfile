pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "docker.io/vinodgangwar92"
        IMAGE_NAME = "newlab2"
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

        stage('Deploy To Kubernetes') {
            steps {
                bat '''
                echo Deploying to Kubernetes...
                kubectl apply -f deployment.yml
                kubectl apply -f service.yml
                '''
            }
        }
    }

    post {
        success {
            echo "✔ Build, push & Kubernetes deploy succeeded!"
        }
        failure {
            echo "❌ Pipeline failed — check logs for details."
        }
    }
}
