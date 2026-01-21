pipeline {
    agent any

    environment {
        IMAGE_NAME = "shivsoftapp/admin-dashboard"   // update with your DockerHub repo
        IMAGE_TAG  = "${env.BUILD_NUMBER}"          // unique per build
    }

    stages {

        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/vinodgangwar92/newlab2.git', branch: 'main'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Update k8s Deployment') {
            steps {
                script {
                    // Replace placeholder in k8s deployment.yaml with the new image
                    sh "sed -i 's|IMAGE_NAME_PLACEHOLDER|${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    """
                }
            }
        }

    }

    post {
        success {
            echo "Deployed successfully!"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
