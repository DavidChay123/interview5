pipeline {
    agent any
    environment {
        REGISTRY = "your-docker-registry"  // שנה ל-Registry שלך
        DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1425099820204294208/YcNdFjId84r07n_Q5mcZYJA5o0U-2qLZ4_V19VO2h6DPSIpT8CYBpJPhlf2nP_ZD2URP"
    }
    stages {
        stage('Detect Changes') {
            steps {
                script {
                    // מזהה אילו שירותים השתנו מול main
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
                            def lintStages = [:]
                            for (service in CHANGED_SERVICES.split()) {
                                def svc = service
                                lintStages[svc] = {
                                    retry(2) {
                                        echo "Running Lint for ${svc}"
                                        sh "ci/lint.sh ${svc}"
                                    }
                                }
                            }
                            parallel lintStages
                        }
                    }
                }

                stage('Test') {
                    steps {
                        script {
                            def testStages = [:]
                            for (service in CHANGED_SERVICES.split()) {
                                def svc = service
                                testStages[svc] = {
                                    retry(2) {
                                        echo "Running Tests for ${svc}"
                                        sh "ci/test.sh ${svc}"
                                    }
                                }
                            }
                            parallel testStages
                        }
                    }
                }

                stage('Security Scan') {
                    steps {
                        script {
                            def scanStages = [:]
                            for (service in CHANGED_SERVICES.split()) {
                                def svc = service
                                scanStages[svc] = {
                                    echo "Running Security Scan for ${svc}"
                                    sh "ci/scan.sh ${svc}"
                                }
                            }
                            parallel scanStages
                        }
                    }
                }

                stage('Docker Build') {
                    steps {
                        script {
                            def dockerStages = [:]
                            for (service in CHANGED_SERVICES.split()) {
                                def svc = service
                                dockerStages[svc] = {
                                    echo "Building Docker image for ${svc}"
                                    sh "docker build -t ${REGISTRY}/${svc}:ci-${env.GIT_COMMIT[0..6]} ${svc}"
                                }
                            }
                            parallel dockerStages
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
            sh """
            curl -H 'Content-Type: application/json' \
            -X POST \
            -d '{\"content\":\"Pipeline succeeded for services: ${CHANGED_SERVICES}\"}' \
            $DISCORD_WEBHOOK
            """
        }
        failure {
            echo "Pipeline failed!"
            sh """
            curl -H 'Content-Type: application/json' \
            -X POST \
            -d '{\"content\":\"Pipeline failed for services: ${CHANGED_SERVICES}\"}' \
            $DISCORD_WEBHOOK
            """
        }
    }
}
