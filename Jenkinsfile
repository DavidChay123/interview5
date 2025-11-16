def CHANGED_SERVICES = ""

pipeline {
    agent any

    environment {
        REGISTRY = "your-docker-registry"
        DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1425099820204294208/YcNdFjId84r07n_Q5mcZYJA5o0U-2qLZ4_V19VO2h6DPSIpT8CYBpJPhlf2nP_ZD2URP"
    }

    stages {

        stage('Detect Changes') {
            steps {
                script {
                    // מקבל שינויים מהקומיט האחרון
                    def changedFiles = sh(
                        script: """
                            git fetch origin main
                            git diff --name-only HEAD~1 HEAD
                        """,
                        returnStdout: true
                    ).trim()

                    echo "Changed files:\n${changedFiles}"

                    def services = []
                    changedFiles.split("\n").each { file ->
                        if (file.trim()) {
                            def dir = file.split("/")[0]
                            if (dir.endsWith("-service")) {
                                services.add(dir)
                            }
                        }
                    }

                    CHANGED_SERVICES = services.join(" ")
                    echo "Changed services: ${CHANGED_SERVICES}"

                    if (!CHANGED_SERVICES) {
                        echo "No services changed — skipping CI stages"
                    }
                }
            }
        }

        stage('CI Pipeline') {
            when {
                expression { return CHANGED_SERVICES?.trim() }
            }

            parallel {

                stage('Lint') {
                    steps {
                        script {
                            CHANGED_SERVICES.split().each { service ->
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
                            CHANGED_SERVICES.split().each { service ->
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
                            CHANGED_SERVICES.split().each { service ->
                                sh "ci/scan.sh ${service}"
                            }
                        }
                    }
                }

                stage('Docker Build') {
                    steps {
                        script {
                            CHANGED_SERVICES.split().each { service ->
                                sh """
                                    docker build \
                                        -t ${REGISTRY}/${service}:ci-${env.GIT_COMMIT[0..6]} \
                                        ${service}
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Manual Approval') {
            steps {
                input message: "Ready to deploy?"
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded!"
            sh """
                curl -H "Content-Type: application/json" \
                     -X POST \
                     -d '{"content": "✅ Jenkins Pipeline Succeeded :rocket:"}' \
                     "${DISCORD_WEBHOOK}"
            """
        }

        failure {
            echo "Pipeline failed!"
            sh """
                curl -H "Content-Type: application/json" \
                     -X POST \
                     -d '{"content": "❌ Jenkins Pipeline FAILED"}' \
                     "${DISCORD_WEBHOOK}"
            """
        }
    }
}
