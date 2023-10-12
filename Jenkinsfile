/*import shared Library*/
@Library('OlivierKouokam-shared-Library')_

pipeline {
  
  environment {
      IMAGE_NAME = "static-website"
      DOCKER0_INTERFACE = "172.17.0.1"
      APP_EXPOSED_PORT = "8080"
      APP_NAME = "jenkins-miniproject"
      IMAGE_TAG = "latest"
      STAGING = "${APP_NAME}-staging"
      PRODUCTION = "${APP_NAME}-prod"
      DOCKERHUB_ID = "olivierkkoc"
      DOCKERHUB_PASSWORD = credentials('dockerhub_olivier')
      STG_API_ENDPOINT = "ip10-0-0-3-ckk5gukt654gqaevl11g-1993.direct.docker.labs.eazytraining.fr"
      STG_APP_ENDPOINT = "ip10-0-0-3-ckk5gukt654gqaevl11g-80.direct.docker.labs.eazytraining.fr"
      PROD_API_ENDPOINT = "ip10-0-0-4-ckk5gukt654gqaevl11g-1993.direct.docker.labs.eazytraining.fr"
      PROD_APP_ENDPOINT = "ip10-0-0-4-ckk5gukt654gqaevl11g-80.direct.docker.labs.eazytraining.fr"
      INTERNAL_PORT = "80"
      EXTERNAL_PORT = "$APP_EXPOSED_PORT"
      CONTAINER_IMAGE = "${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

  agent none

  stages {
    stage('Build image') {
      agent any
      steps {
        script {
          sh 'docker build -t $DOCKERHUB_ID/$IMAGE_NAME:$IMAGE_TAG .'
        }
      }
    }

    stage('Run container based on builded image') {
      agent any
      steps {
        script {
          sh '''
            echo "Cleaning existing container if exist"
            docker ps -a | grep -i $IMAGE_NAME && docker stop $IMAGE_NAME
            docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
            docker run --name $IMAGE_NAME -d -p $APP_EXPOSED_PORT:$INTERNAL_PORT $DOCKERHUB_ID/$IMAGE_NAME:$IMAGE_TAG
            sleep 5
          '''
        }
      }
    }

    stage('Test image') {
      agent any
      steps {
        script {
          sh '''
            curl -v http://$DOCKER0_INTERFACE:$APP_EXPOSED_PORT | grep -q "Dimension"            
          '''
        }
      }
    }

    stage('Clean Container') {
      agent any
      steps {
        script {
          sh '''
            docker stop $IMAGE_NAME
            docker rm $IMAGE_NAME
          '''
        }
      }
    }

    stage ('Login and Push Image on docker hub') {
        agent any
        steps {
            script {
              sh '''
                  echo $DOCKERHUB_PASSWORD_PSW | docker login -u $DOCKERHUB_PASSWORD_USR --password-stdin
                  docker push ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG
              '''
            }
        }
    }

    stage('STAGING env - Deploy app') {
      when {
        expression { GIT_BRANCH == 'origin/master' }
      }
      agent any
      steps {
        script {
          sh """
            echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
            curl -v -X POST http://${STG_API_ENDPOINT}/staging -H 'Content-Type: application/json'  --data-binary @data.json  2>&1 | grep 200
          """
        }
      }
    }

    stage('PRODUCTION env - Deploy app') {
      when {
        expression { GIT_BRANCH == 'origin/master' }
      }
      agent any
      steps {
        script {
          sh """
            echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
            curl -v -X POST http://${PROD_API_ENDPOINT}/prod -H 'Content-Type: application/json'  --data-binary @data.json  2>&1 | grep 200
          """
        }
      }
    }
  }
  /* post {
    success {
      slackSend (color: '#00FF00', message: "SUCCESSFULL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    }
    failure {
      slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    }
  } */
  post {
    always {
      script {
        slackNotifier currentBuild.result
      }
    }
  }
}
