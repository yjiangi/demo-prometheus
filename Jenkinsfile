def COMMITID = ""
def TIMESTAMP = ""
pipeline {
    agent {
        kubernetes {
            label "jnlp-slave-${UUID.randomUUID().toString().substring(0, 8)}"
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-slave
spec:
  volumes:
    - name: docker-socket
      emptyDir: {}
    - name: workspace-volume
      emptyDir: {}      
  serviceAccount: jenkins      
  containers:
    - name: jnlp
      image: registry.cn-hangzhou.aliyuncs.com/s-ops/inbound-agent:latest
    - name: tools  
      image: registry.cn-hangzhou.aliyuncs.com/s-ops/tools:latest
      command:
        - cat
      tty: true         
    - name: docker
      image: registry.cn-hangzhou.aliyuncs.com/s-ops/docker:latest
      env:
        - name: DOCKER_CLI_EXPERIMENTAL
          value: "enabled"  
      command:
      - sleep
      args:
      - 99d
      readinessProbe:
        exec:
          command: ["ls", "-S", "/var/run/docker.sock"]      
        initialDelaySeconds: 10  
      volumeMounts:
      - name: docker-socket
        mountPath: /var/run       
    - name: docker-daemon
      image: registry.cn-hangzhou.aliyuncs.com/s-ops/docker:19.03.1-dind
      securityContext:
        privileged: true
      volumeMounts:
      - name: docker-socket
        mountPath: /var/run
      - name: workspace-volume
        mountPath: /home/jenkins/agent
        readOnly: false            
            """
        }
    }
    environment {
        DOCKER_REGISTRY = "crpi-o0ivl952pax3mypf.cn-wulanchabu.personal.cr.aliyuncs.com" 
        REGISTRY_NAMEPSACE = "cylia"
        IMAGE = "${DOCKER_REGISTRY}/${REGISTRY_NAMEPSACE}"
    }
    options {
        //保持构建15天 最大保持构建的30个 发布包保留15天
        buildDiscarder logRotator(artifactDaysToKeepStr: '15', artifactNumToKeepStr: '', daysToKeepStr: '15', numToKeepStr: '30')
        //时间模块
        timestamps()
        //超时时间
        timeout(time:60, unit:'MINUTES')
    }

    stages {
        stage('build image') {
            steps {
                container('docker') {
                    withCredentials([[$class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'docker-auth',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD']]) {
                          script {
                            sh """
                            echo "登陆仓库"
                            docker login ${DOCKER_REGISTRY} -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}

                            echo "构建/推送镜像"
                            docker build --progress=plain --no-cache -f Dockerfile -t ${IMAGE}/xsk-mall:1 .
                            docker push ${IMAGE}/xsk-mall:1
                            """
                        }
                    }    
                }
            }
        }       
    }
}
