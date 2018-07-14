pipeline {

  agent {
    kubernetes {
      label 'k8s-org'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: some-label-value
spec:
  containers:
  - name: alpine
    image: alpine:3.7
    command:
    - cat
    tty: true
  - name: maven
    image: maven:3.5.3-jdk-8-alpine
    command:
    - cat
    tty: true
  - name: kubectl
    image: roffe/kubectl:v1.9.6
    command:
    - cat
    tty: true
  - name: docker
    image: docker:18.05.0-ce-git
    volumeMounts:
      - mountPath: /var/run/docker.sock
        name: docker-socket
    command:
    - cat
    tty: true
  volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock

"""
    }
  }
    stages {
        stage('Setup') {
            steps {
                script {
                    scmInfo()
                    initialisePipeline('boot-static')
                }
            }
        }
        stage('Maven Build') {
            steps {
                container('maven') {
                    sh 'mvn -B clean package'
                }
            }
        }
        stage('Docker Build') {
            steps {
                container('docker') {
                    script {
                        buildDockerImage("${CI_IMAGE_NAME}", 'dockerhub')
                    }
                }
            }
        }
        stage('Deploy App for Test') {
            steps {
                container('kubectl') {
                    script {
                        kubectlLogin()
                        kubectlDeploy('src/kubernetes/spec', ["SERVICE_NAME=${CI_SERVICE_NAME}", "IMAGE_NAME=${CI_IMAGE_NAME}"])
                    }
                }
            }
        }
        stage('Promote to Demo Environment') {
            steps {
                container('kubectl') {
                    script {
                        // in case this is the first time it runs
                        kubectlDeploy('src/kubernetes/spec', ["SERVICE_NAME=${DEMO_SERVICE_NAME}", "IMAGE_NAME=${CI_IMAGE_NAME}"])
                        kubectlUpdateDeployment("${DEMO_SERVICE_NAME}", "${CI_IMAGE_NAME}")

                        // update ingress
                        kubectlDeploy('src/kubernetes/ingress', ["SERVICE_NAME=${DEMO_SERVICE_NAME}"])
                    }
                }
            }
        }
    }
    post {
        always {
            container('kubectl') {
                script {
                    kubectlDelete('src/kubernetes/spec', ["SERVICE_NAME=${CI_SERVICE_NAME}", "IMAGE_NAME=${CI_IMAGE_NAME}"])
                }
            }
        }
    }
}


