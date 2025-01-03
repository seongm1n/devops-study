pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_USERNAME = 'seongm1n'
        APP_NAME = 'test-escape-room'
        TAG = "${BUILD_NUMBER}"
        EC2_HOST = 'ubuntu@ec2-3-34-35-246.ap-northeast-2.compute.amazonaws.com'
        REMOTE_DIR = '/app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test EC2 Connection') {
            steps {
                sshagent(['aws-ec2-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} 'echo "Successfully connected to EC2"'
                    """
                }
            }
        }

        stage('Build') {
            steps {
                sh './gradlew clean build'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // 도커 이미지 빌드
                    sh "docker build -t ${DOCKER_USERNAME}/${APP_NAME}:${TAG} ."
                    sh "docker tag ${DOCKER_USERNAME}/${APP_NAME}:${TAG} ${DOCKER_USERNAME}/${APP_NAME}:latest"
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    // Docker Hub 로그인 및 이미지 푸시
                    sh "echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${DOCKER_USERNAME}/${APP_NAME}:${TAG}"
                    sh "docker push ${DOCKER_USERNAME}/${APP_NAME}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['aws-ec2-key']) {
                    sh """
                        # EC2 배포 디렉토리 생성
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} '
                            mkdir -p ${REMOTE_DIR}
                        '

                        # 환경 변수 파일 생성
                        echo "DOCKER_USERNAME=${DOCKER_USERNAME}" > .env.temp
                        echo "APP_NAME=${APP_NAME}" >> .env.temp
                        echo "TAG=${TAG}" >> .env.temp

                        # 배포 파일 전송
                        scp -o StrictHostKeyChecking=no .env.temp ${EC2_HOST}:${REMOTE_DIR}/.env
                        scp -o StrictHostKeyChecking=no docker-compose.yml ${EC2_HOST}:${REMOTE_DIR}/

                        # 도커 컴포즈로 배포
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} '
                            cd ${REMOTE_DIR}
                            docker compose down
                            docker compose up -d
                        '

                        # 임시 파일 삭제
                        rm .env.temp
                    """
                }
            }
        }
    }

    post {
        always {
            // 도커 로그아웃 및 이미지 정리
            sh 'docker logout'
            sh "docker rmi ${DOCKER_USERNAME}/${APP_NAME}:${TAG} || true"
            sh "docker rmi ${DOCKER_USERNAME}/${APP_NAME}:latest || true"
        }

        success {
            echo '파이프라인 실행 성공!'
        }

        failure {
            echo '파이프라인 실행 실패!'
        }
    }
}