pipeline {
    agent any
    environment {
        DOCKERHUB_CREDS = credentials('dockerhub-creds')
        KUBE_CRED = credentials('kube-cred')
        PRODUCTION_SERVER = '54.221.24.230'
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/ahmedhammad01/DevOps-CW2.git'
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
                sh 'echo $DOCKERHUB_CREDS_PSW | docker login -u ahmed6922 --password-stdin'
                sh 'docker push ahmed6922/cw2-server:1.0'
            }
        }
        stage('Run Setup Playbook') {
            steps {
                sshagent(credentials: ['kube-cred']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@$PRODUCTION_SERVER << 'EOF'
                            cd ~/DevOps-CW2
                            git pull origin main
                            ansible-playbook setup.yml
                        EOF
                    """
                }
            }
        }
        stage('Run Deploy Playbook') {
            steps {
                sshagent(credentials: ['kube-cred']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@$PRODUCTION_SERVER << 'EOF'
                            cd ~/DevOps-CW2
                            git pull origin main
                            ansible-playbook deploy.yml
                        EOF
                    """
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sshagent(credentials: ['kube-cred']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@$PRODUCTION_SERVER << 'EOF'
                            cd ~/DevOps-CW2
                            git pull origin main
                            kubectl apply -f cw2-server.yml
                            kubectl rollout status deployment/cw2-server-deployment
                        EOF
                    """
                }
            }
        }
    }
}
