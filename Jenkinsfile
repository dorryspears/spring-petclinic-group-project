pipeline {
    agent any
    
    stages {
        stage('Prepare') {
            steps {
                echo "Starting deployment process"
                sh 'ansible --version'
            }
        }
        
        stage('Deploy to VM') {
            steps {
                script {
                    try {
                        sh '''
                            cd ${WORKSPACE}
                            ansible-playbook -vv deploy.yml -i inventory.yml
                        '''
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error "Deployment failed: ${e.message}"
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    try {
                        sh '''
                            # Wait for application to be ready
                            sleep 10
                            curl -f http://192.168.64.3:8080
                        '''
                        echo "Deployment verification successful"
                    } catch (Exception e) {
                        echo "Verification failed: ${e.message}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "Deployment process completed with result: ${currentBuild.result}"
        }
    }
} 