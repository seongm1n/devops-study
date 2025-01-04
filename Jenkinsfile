pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_USERNAME = 'seongm1n'
        APP_NAME = 'escape-room'
        TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh '''
                    chmod +x gradlew
                    ./gradlew clean build -x test    # 테스트 제외
                '''
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKER_USERNAME}/${APP_NAME}:${TAG} .
                        docker tag ${DOCKER_USERNAME}/${APP_NAME}:${TAG} ${DOCKER_USERNAME}/${APP_NAME}:latest
                    """
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                            docker push ${DOCKER_USERNAME}/${APP_NAME}:${TAG}
                            docker push ${DOCKER_USERNAME}/${APP_NAME}:latest
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout'
            sh """
                docker rmi ${DOCKER_USERNAME}/${APP_NAME}:${TAG} || true
                docker rmi ${DOCKER_USERNAME}/${APP_NAME}:latest || true
            """
        }
        success {
            echo '파이프라인 실행 성공!'
        }
        failure {
            echo '파이프라인 실행 실패!'
        }
    }
}