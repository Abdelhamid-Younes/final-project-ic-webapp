/* import shared library */
@Library('shared_library')_
pipeline {
    environment {

        IMAGE_NAME = "${PARAM_IMAGE_NAME}"                    /*ic-webapp*/
        //APP_NAME = "${PARAM_APP_NAME}"                        
        IMAGE_TAG = "${PARAM_IMAGE_TAG}"                      /*1.0*/
        APP_EXPOSED_PORT = "${PARAM_EXPOSED_PORT}"            /*8000 by default*/
        INTERNAL_PORT = "${PARAM_INTERNAL_PORT}"              /*8000 by default*/
        EXTERNAL_PORT = "${PARAM_EXPOSED_PORT}"
        CONTAINER_IMAGE = "${DOCKERHUB_USR}/${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKERHUB_USR = "${PARAM_DOCKERHUB_ID}"             /*younesabdh*/
        DOCKERHUB_PSW = credentials('dockerhub_psw')
        PRIVATE_KEY = credentials('private_key')            // SSH private key for Ansible access

    }
    agent none
    stages {

        /*stage('Cloning code') {
            steps {
                script {
                    sh '''
                         rm -rf final-project-ic-webapp || echo "Directory doesn't exists "
                         sleep 2
                         git clone https://github.com/Abdelhamid-Younes/final-project-ic-webapp.git
                     '''
                }
            }
        }*/
/*
        stage('Build image') {
            agent any
            steps {
                script {
                    sh 'docker build -t ${DOCKERHUB_USR}/$IMAGE_NAME:$IMAGE_TAG .'
                }
            }
        }

        stage('Run container based on built image'){
            agent any
            steps {
                script{
                    sh '''

                        echo "Cleaning existing container if exists"
                        docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
                        docker run --name $IMAGE_NAME -d -p $APP_EXPOSED_PORT:$INTERNAL_PORT ${DOCKERHUB_USR}/$IMAGE_NAME:$IMAGE_TAG
                        sleep 5
                    '''
                }
            }
        }

        stage('Test image') {
            agent any
            steps{
                script {
                    sh 'docker stop ${IMAGE_NAME} || true && docker rm ${IMAGE_NAME} || true'
                    sh 'docker run --name $IMAGE_NAME -d -p $APP_EXPOSED_PORT:$INTERNAL_PORT ${DOCKERHUB_USR}/$IMAGE_NAME:$IMAGE_TAG'
                    sh 'sleep 5'
                    sh 'curl -k http://172.17.0.1:$APP_EXPOSED_PORT | grep -i "IC GROUP"'
                    sh 'if [ $? -eq 0 ]; then echo "Acceptance test succeeded"; fi'
                }
            }
        }

        stage('Clean container') {
            agent any
            steps{
                script {
                    sh '''
                        docker stop $IMAGE_NAME
                        docker rm $IMAGE_NAME
                    '''
                }
            }
        }
        stage('Login and Push Image on Docker Hub') {
            when{
                expression {GIT_BRANCH == 'origin/main'}
            }
            agent any
            steps{
                script {
                    sh '''
                        echo $DOCKERHUB_PSW | docker login -u $DOCKERHUB_USR --password-stdin
                        docker push $DOCKERHUB_USR/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
*/
        stage('Provision EC2 on AWS with Terraform') {
            agent { 
                docker { 
                    image 'jenkins/jnlp-agent-terraform'  
                } 
            }
            environment {
                AWS_ACCESS_KEY = credentials('aws_access_key')
                AWS_SECRET_KEY = credentials('aws_secret_key')
                AWS_PRIVATE_KEY = credentials('aws_private_key')
            }
            steps {
                script {
                    sh '''
                        echo "Setting up AWS credentials"
                        rm -rf devops-hamid.pem ~/.aws || true
                        mkdir -p ~/.aws

                        echo "[default]" > ~/.aws/credentials
                        echo "aws_access_key_id=$AWS_ACCESS_KEY" >> ~/.aws/credentials
                        echo "aws_secret_access_key=$AWS_SECRET_KEY" >> ~/.aws/credentials
                        chmod 600 ~/.aws/credentials

                        echo "Configuring AWS private key"
                        echo "$AWS_PRIVATE_KEY" > devops-hamid.pem
                        chmod 400 devops-hamid.pem

                        cd "/var/jenkins_home/workspace/ic-webapp"
                        echo "Cleaning up old files"
                        rm -f id_rsa

                        echo "Copying SSH private key for Ansible"
                        echo $PRIVATE_KEY > id_rsa
                        chmod 600 id_rsa



                        echo "Initializing Terraform"
                        cd "./sources/terraform/dev"
                        terraform init -input=false

                        echo "Validating Terraform configuration"
                        terraform validate

                        echo "Generating Terraform plan"
                        terraform plan -out=tfplan

                        echo "Applying Terraform plan"
                        terraform apply -input=false -auto-approve tfplan

                        cat files/ec2_IP.txt

                        pwd

                        echo "Generating host_vars for EC2 servers"
                        echo "ansible_host: $(awk '{print $2}' ./files/ec2_IP.txt)" > var/jenkins_home/workspace/ic-webapp/sources/ansible/host_vars/dev-server.yml

                        cat var/jenkins_home/workspace/ic-webapp/sources/ansible/host_vars/dev-server.yml

                    '''                   
                }
            }
        }

        stage('Ping dev server') {
            agent {
                docker {
                    image 'registry.gitlab.com/robconnolly/docker-ansible:latest'
                }
            }
            steps {
                script {
                    sh '''
                        apt update -y
                        apt install sshpass -y
                        pwd

                        export ANSIBLE_CONFIG=$PWD/ansible.cfg
                        ansible -i source/ansible/inventory/hosts.yml dev -m ping --private-key devops-hamid.pem 
                    '''
                }
            }
        }

        /*stage('Deploy application') {
            steps {
                script {
                    sh '''
                        export ANSIBLE_CONFIG=$PWD/ansible.cfg
                        ansible-playbook playbooks/icwebapp.yml --private_key private_key
                    '''
                }
            }
        }*/
        
        /*stage ('Update Ansible host_vars with EC2 IP'){
            agent any 
            steps {
                script {
                    sh '''

                        echo "Cleaning up old files"
                        rm -f id_rsa

                        echo "Copying SSH private key for Ansible"
                        echo $PRIVATE_KEY > id_rsa
                        chmod 600 id_rsa

                    '''
                    timeout(time: 3, unit: "MINUTES") {
                        input message: "Confirmer vous la suppression de la dev dans AWS ?", ok: 'Yes'
                    } 
                    sh'''
                        cd "./sources/terraform/dev"
                        terraform destroy --auto-approve
                    '''  
                }
            }
        }*/

    }
  post {
    always {
      script {
        slackNotifier currentBuild.result
      }
    }  
  }
}