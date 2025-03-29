pipeline {
    agent any
    
    stages {
        stage('Deploy to VM') {
            steps {
                sh '''
                    cd ${WORKSPACE}
                    ansible-playbook deploy.yml -i inventory.yml
                '''
            }
        }
    }
} 