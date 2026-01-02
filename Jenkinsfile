pipeline {
    agent any
    tools {
        maven 'maven-3.9' 
    }
    environment {
        // UPDATE THIS , comments will be removed after completion and v2
        DOCKER_HUB_USER = "yashrajmonani" 
        APP_NAME = "java-spring-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        // Make sure you added this ID in Jenkins Credentials
        KUBE_CONFIG_ID = "k8s-kubeconfig" 
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

        stage('Build & Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDS_ID) {
                        def appImage = docker.build("${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}")
                        appImage.push()
                        appImage.push("latest")
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