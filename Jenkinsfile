pipeline {
  environment {
    // create a backup workspace
    WS = '/opt/projects/mongo-api'
  }

  agent any
  stages {
    stage('Pre Tasks') {
      steps {
        echo 'Raise a change request if any.'
        sh "ls -lRthr '${WORKSPACE}'"
        sh '''#!/bin/bash
          if [ -e ${WS} ]; then
            if [ -e "${WS}/main.tf" ]; then
              cd ${WS}
              echo "0. Destroy VM"
              terraform init
              terraform destroy -auto-approve
            fi
          else
            echo "0. Create Backup Workspace"
            mkdir -p ${WS}
          fi
        '''
      }
    }
    stage('VM Deployment') {
      steps {
        sh '''#!/bin/bash
          echo "1. Deploy VM"
          echo "terraform init"
          terraform init
          echo "terraform apply -auto-approve"
          terraform apply -auto-approve
          echo "2. Backup the deployment details"
          cp -rf * ${WS}/.
        '''
      }
    }
    stage('VM Validation') {
      steps {
        sh '''#!/bin/bash
          echo "3. Post VM Deployment Validations"
          ansible-playbook -i hosts vm-validation.yml -v
        '''
      }
    }
    stage('MongoDB API') {
      parallel {
        stage('API Deployment') {
          steps {
            sh "ls -lRthr '${WORKSPACE}'"
          }
        }
        stage('API Deployment') {
          steps {
            sh '''#!/bin/bash
              echo "4. Deploy and Install Application"
              cp -p /opt/devops/mongo-api/vault ./group_vars/all/
              ansible-playbook -i hosts -e "WS=${WS}" mongo-api.yml -v
              rm -f ./group_vars/all/vault
            '''
          }
        }
      }
    }
    stage('API CRUD Test') {
      steps {
        sh '''#!/bin/bash
          echo "5. Create test"
          sh test/create.sh
          sleep 3

          echo "6. Read test"
          sh test/read.sh
          sleep 3

          echo "7. Update test"
          sh test/update.sh
          sleep 3

          echo "8. Delete test"
          sh test/delete.sh
        '''
      }
    }
    stage('Ready for Release') {
      steps {
        sh '''#!/bin/bash
          echo "9. Tag for release ready"
          cp -p /opt/devops/mongo-api/vault ./group_vars/all/
          ansible-playbook release-tag.yml
          rm -f ./group_vars/all/vault
          echo "10. Done!"
        '''
      }
    }
  }
}
