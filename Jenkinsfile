pipeline {
    agent any
    environment {
        REGISTRY = "your-docker-registry"
    }
    stages {
        stage('Detect Changes') {
            steps {
                script {
                    CHANGED_SERVICES = sh(returnStdout: true, script: """
                        git fetch origin main
                        git diff --name-only origin/main | awk -F/ '{print \$1}' | sort -u
                    """).trim()
                    echo "Changed services: ${CHANGED_SERVICES}"
                }
            }
        }
        stage('CI Pipeline') {
            parallel {
                stage('Lint') {
                    steps {
                        script {
                            for (service in CHANGED_SERVICES.split()) {
                                retry(2) {
                                    sh "ci/lint.sh ${service}"
                                }
                            }
                        }
                    }
                }
                stage('Test') {
                    steps {
                        script {
                            for (service in CHANGED_SERVICES.split()) {
                                retry(2) {
                                    sh "ci/test.sh ${service}"
                                }
                            }
                        }
                    }
                }
                stage('Security Scan') {
                    steps {
                        script {
                            for (service in CHANGED_SERVICES.split()) {
                                sh "ci/scan.sh ${service}"
                            }
                        }
                    }
                }
                stage('Docker Build') {
                    steps {
                        script {
                            for (service in CHANGED_SERVICES.split()) {
                                sh "docker build -t ${REGISTRY}/${service}:ci-${env.GIT_COMMIT[0..6]} ${service}"
                            }
                        }
                    }
                }
            }
        }
        stage('Manual Approval') {
            steps {
                input message: "Ready to deploy? (CD not implemented yet)"
            }
        }
    }
    post {
        success {
            echo "Pipeline succeeded!"
            // אפשר להוסיף כאן webhook ל-MS Teams/Slack
        }
        failure {
            echo "Pipeline failed!"
            // אפשר לשלוח הודעת כשלון
        }
    }
}
