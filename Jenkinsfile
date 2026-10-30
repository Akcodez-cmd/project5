
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    environment {
        DOCKER_IMAGE = 'ajith7550/habit-tracker'
        GITOPS_REPO = 'https://github.com/Akcodez-cmd/project5-gitops.git'
        SONAR_SERVER = 'SonarQube'
    }

    stages {

        stage('Checkout Application') {
            steps {
                checkout scm

                script {
                    env.GIT_SHORT = sh(
                        script: 'git rev-parse --short=7 HEAD',
                        returnStdout: true
                    ).trim()

                    env.IMAGE_TAG = "${BUILD_NUMBER}-${env.GIT_SHORT}"
                }
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                    java -version
                    docker --version
                    trivy --version
                    git --version
                '''
            }
        }

        stage('Maven Build and Test') {
            steps {
                sh '''
                    chmod +x mvnw
                    ./mvnw -B clean verify
                '''
            }

            post {
                always {
                    junit allowEmptyResults: false,
                          testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONAR_SERVER}") {
                    sh '''
                        ./mvnw -B sonar:sonar
                    '''
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qualityGate = waitForQualityGate()

                        if (qualityGate.status != 'OK') {
                            error "SonarQube Quality Gate failed: ${qualityGate.status}"
                        }
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                      -t ${DOCKER_IMAGE}:${IMAGE_TAG} \
                      -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                    trivy image \
                      --format json \
                      --output trivy-report.json \
                      ${DOCKER_IMAGE}:${IMAGE_TAG}

                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      ${DOCKER_IMAGE}:${IMAGE_TAG}
                '''
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-project5',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | \
                          docker login -u "$DOCKER_USER" --password-stdin

                        docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                        docker push ${DOCKER_IMAGE}:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Update GitOps Repository') {
            steps {
                dir('gitops') {
                    git branch: 'main',
                        credentialsId: 'gitops-repo-token',
                        url: "${GITOPS_REPO}"

                    sh '''
                        sed -i \
                          "s/^  tag:.*/  tag: \\"${IMAGE_TAG}\\"/" \
                          habit-tracker/values.yaml

                        git config user.name "Jenkins CI"
                        git config user.email "jenkins@example.com"

                        git add habit-tracker/values.yaml
                        git commit -m "Deploy Habit Tracker image ${IMAGE_TAG}"
                    '''

                    withCredentials([
                        gitUsernamePassword(
                            credentialsId: 'gitops-repo-token',
                            gitToolName: 'Default'
                        )
                    ]) {
                        sh 'git push origin HEAD:main'
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts(
                artifacts: 'target/*.jar,trivy-report.json',
                allowEmptyArchive: true
            )
        }

        success {
            echo "CI completed successfully. Image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
            echo "Argo CD will reconcile the GitOps repository."
        }

        failure {
            echo 'CI pipeline failed. Check the failed stage and console output.'
        }
    }
}
