pipeline {
    agent any
    environment {
        DOCKERHUB_CREDS = credentials('dockerhub')
        PRODUCTION_SERVER = '54.80.89.134'
        KUBE_CRED = credentials('kube-cred')
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ahmedhammad01/DevOps-CW2.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ahmed6922/cw2-server:1.0 .'
            }
        }
        stage('Test Container') {
            steps {
                sh '''
                    docker rm -f test-container || true
                    docker run -d --name test-container -p 8081:8080 ahmed6922/cw2-server:1.0
                    sleep 5
                    curl http://localhost:8081 | grep "DevOps Coursework 2!"
                    docker stop test-container
                    docker rm test-container
                '''
            }
        }
        stage('Push to DockerHub') {
            steps {
                sh 'echo $DOCKERHUB_CREDS_PSW | docker login -u $DOCKERHUB_CREDS_USR --password-stdin'
                sh 'docker push ahmed6922/cw2-server:1.0'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Write the private SSH key to a temporary file
                    writeFile file: '/tmp/kube_key', text: credentials('kube-cred')

                    // Set appropriate permissions for the SSH key
                    sh 'chmod 600 /tmp/kube_key'

                    // Execute the deployment script on the remote server
                    sh '''
                        ssh -i /tmp/kube_key -o StrictHostKeyChecking=no ubuntu@$PRODUCTION_SERVER << EOF
                            cd ~/DevOps-CW2
                            git pull origin main
                            kubectl apply -f cw2-server.yml
                            kubectl rollout status deployment/cw2-server-deployment
                        EOF
                    '''

                    // Clean up the temporary SSH key file
                    sh 'rm -f /tmp/kube_key'
                }
            }
        }
    }
}
