pipeline {
    agent any

    stages {

        stage('Detect Changes') {
            steps {
                script {
                    sh 'git fetch origin main'
                    def changed = sh(script: "git diff --name-only HEAD~1 HEAD", returnStdout: true).trim()
                    echo "Changed files: ${changed}"

                    def services = changed.readLines()
                        .findAll { it.startsWith("services/") }
                        .collect { it.split('/')[1] }
                        .unique()

                    echo "Changed services: ${services}"

                    env.SERVICES_CHANGED = services.join(',')
                }
            }
        }

        stage('CI Pipeline') {
            when {
                expression { return env.SERVICES_CHANGED?.trim() }
            }
            parallel {
                stage('Lint') {
                    steps {
                        echo "Running lint..."
                        sh 'echo LINT DONE'
                    }
                }
                stage('Test') {
                    steps {
                        echo "Running tests..."
                        sh 'echo TEST DONE'
                    }
                }
                stage('Security Scan') {
                    steps {
                        echo "Running security scan..."
                        sh 'echo SCAN DONE'
                    }
                }
                stage('Docker Build') {
                    steps {
                        echo "Building Docker images..."
                        sh 'echo DOCKER BUILD DONE'
                    }
                }
            }
        }

    }

    post {
        always {
            echo "Pipeline finished."
        }
    }
}
