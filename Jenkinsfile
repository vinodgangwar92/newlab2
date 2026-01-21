pipeline {
    agent any

    environment {
        IMAGE_NAME = "shivsoftapp/admin-dashboard"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/vinodgangwar92/newlab2.git', branch: 'main'
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

        stage('Update k8s Deployment') {
            steps {
                powershell """
                $image = "$env:IMAGE_NAME`:$env:IMAGE_TAG"
                (Get-Content k8s\\deployment.yaml) -replace "IMAGE_NAME_PLACEHOLDER", $image |
                  Set-Content k8s\\deployment.yaml
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    bat """
                    set KUBECONFIG=%KUBECONFIG%
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
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
