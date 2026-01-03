pipeline {
    agent any
    tools {
        maven 'maven-3.9' 
    }
    environment {
        // UPDATE THIS , comments will be removed after completion and v3
        DOCKER_HUB_USER = "yashrajmonani" 
        APP_NAME = "java-spring-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        // Make sure you added this ID in Jenkins Credentials
        KUBE_CONFIG_ID = "my-k8s-config" 
        DOCKER_CREDS_ID = "docker-hub-creds"
    }

    stages {
        stage('Build Maven') {
            steps {
                // If you don't have maven installed on the jenkins agent, 
                // use the 'tools' section or run inside a docker container
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                // This connects to the tool we set up in Step 2.4
                SCANNER_HOME = tool 'sonar-scanner'
            }
            steps {
                withSonarQubeEnv('sonar-server') {
                    // Run the scan
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectKey=java-spring-app \
                    -Dsonar.projectName="Java Spring App" \
                    -Dsonar.java.binaries=target/classes \
                    -Dsonar.sources=src/main/java
                    '''
                }
            }
        }

        // STAGE 1: Build locally (No push yet)
        stage('Build Docker Image') {
            steps {
                script {
                    // Just build. No registry login needed yet.
                    sh "docker build -t ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        // STAGE 2: Scan the local image
        stage('Trivy Security Scan') {
            steps {
                script {
                    // Scan the image we just built
                    // --exit-code 1 means: "Stop the pipeline if you find critical bugs"
                    sh "trivy image --severity CRITICAL --exit-code 1 --no-progress ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}"
                }
            }
        }

        // STAGE 3: Push to DockerHub (Only if scan passed)
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDS_ID) {
                        // 1. Push the specific version (e.g., :25)
                        sh "docker push ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}"
                        
                        // 2. NEW FIX: Create the 'latest' tag from the current image
                        sh "docker tag ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${APP_NAME}:latest"
                        
                        // 3. Push the 'latest' tag
                        sh "docker push ${DOCKER_HUB_USER}/${APP_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy to DEV') {
            steps {
                script {
                    deployToK8s('dev')
                }
            }
        }

        stage('Deploy to UAT') {
            steps {
                script {
                    deployToK8s('uat')
                }
            }
        }

        stage('Deploy to PROD') {
            input {
                message "Approve deployment to Production?"
                ok "Deploy"
            }
            steps {
                script {
                    deployToK8s('prod')
                }
            }
        }
    }

    post {
        always {
            script {
                echo 'Cleaning up Docker images to save disk space...'
                // Remove the specific image built in this run
                sh "docker rmi ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG} || true"
                sh "docker rmi ${DOCKER_HUB_USER}/${APP_NAME}:latest || true"
                // aggressive cleanup to keep 8GB disk alive
                sh "docker system prune -f" 
            }
        }
    }
}

// Helper function to keep code clean
def deployToK8s(envName) {
    // 1. Create a dynamic version of the manifests
    sh "cp k8s/deployment.yaml k8s/deployment-${envName}.yaml"
    sh "cp k8s/service.yaml k8s/service-${envName}.yaml"

    // 2. Replace Placeholders (Image and Namespace)
    sh "sed -i 's|REPLACE_ME_IMAGE_TAG|${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}|g' k8s/deployment-${envName}.yaml"
    sh "sed -i 's|namespace: default|namespace: ${envName}|g' k8s/deployment-${envName}.yaml"
    sh "sed -i 's|namespace: default|namespace: ${envName}|g' k8s/service-${envName}.yaml"

    // 3. Apply to Kubernetes
    withKubeConfig([credentialsId: KUBE_CONFIG_ID]) {
        sh "kubectl apply -f k8s/deployment-${envName}.yaml"
        sh "kubectl apply -f k8s/service-${envName}.yaml"
    }
}