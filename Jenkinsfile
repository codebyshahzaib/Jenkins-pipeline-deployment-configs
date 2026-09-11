pipeline {
    agent any

    parameters {
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag to deploy')
    }

    environment {
        IMAGE = "${DOCKERHUB_USERNAME}/dummy-deployment-app"
    }

    stages {
        stage('Test') {
            steps {
                sh 'python3 -m py_compile app.py'
            }
        }

        stage('Build image') {
            steps {
                sh 'docker build --tag "$IMAGE:$IMAGE_TAG" .'
            }
        }

        stage('Push image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_TOKEN')]) {
                    sh 'echo "$DOCKER_TOKEN" | docker login --username "$DOCKER_USER" --password-stdin'
                    sh 'docker push "$IMAGE:$IMAGE_TAG"'
                    sh 'docker logout'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'EC2_USER')]) {
                    sh '''
                        chmod 600 "$SSH_KEY"
                        ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$EC2_USER@$EC2_HOST" \\
                          "sudo docker pull $IMAGE:$IMAGE_TAG && \\
                           (sudo docker rm -f dummy-deployment-app || true) && \\
                           sudo docker run -d --restart unless-stopped --name dummy-deployment-app -p 80:8080 $IMAGE:$IMAGE_TAG"
                    '''
                }
            }
        }
    }
}