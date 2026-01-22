pipeline {
    agent any

    environment {
        IMAGE_NAME = "vinodgangwar92/admin-dashboard"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/vinodgangwar92/newlab2.git'
            }
        }

        stage('Docker Build') {
            steps {
                bat """
                docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                """
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat """
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    docker push %IMAGE_NAME%:%IMAGE_TAG%
                    """
                }
            }
        }

        stage('Update deployment.yaml') {
            steps {
                powershell """
                $newImage = "${env:IMAGE_NAME}:${env:IMAGE_TAG}"
                (Get-Content .\\deployment.yaml) |
                  ForEach-Object { \$_ -replace 'IMAGE_NAME_PLACEHOLDER', \$newImage } |
                  Set-Content .\\deployment.yaml
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    bat """
                    set KUBECONFIG=%KUBECONFIG%
                    kubectl get nodes
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment succeeded!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
