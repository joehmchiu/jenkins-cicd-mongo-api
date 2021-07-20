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
              sudo cd ${WS}
              echo "0. Destroy VM"
              sudo terraform init
              sudo terraform destroy -auto-approve
            fi
          else
            echo "0. Create Backup Workspace"
            sudo mkdir -p ${WS}
          fi
        '''
      }
    }
    stage('VM Deployment') {
      steps {
        sh '''#!/bin/bash
          echo "1. Deploy VM"
          echo "terraform init"
          sudo terraform init
          echo "terraform apply -auto-approve"
          sudo terraform apply -auto-approve
          echo "2. Backup the deployment details"
          sudo cp -rf * ${WS}/.
        '''
      }
    }
    stage('VM Validation') {
      steps {
        sh '''#!/bin/bash
          echo "3. Post VM Deployment Validations"
          cd ${WS}
          sudo cp -p /opt/devops/mongo-api/vault ./group_vars/all/
          sudo ansible-playbook -i hosts vm-validation.yml 
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
            timeout(time: 5, unit: 'MINUTES') {
              sh '''#!/bin/bash
                echo "4. Deploy and Install Application"
                cd ${WS}
                sudo ansible-playbook -i hosts -e "WS=${WS}" mongo-api.yml 
                sudo rm -f ./group_vars/all/vault
              '''
            }
          }
        }
      }
    }
    stage('API CRUD Test') {
      steps {
        sh '''#!/bin/bash
          echo "5. Create test"
          sudo sh test/create.sh
          sleep 3

          echo "6. Read test"
          sudo sh test/read.sh
          sleep 3

          echo "7. Update test"
          sudo sh test/update.sh
          sleep 3

          echo "8. Delete test"
          sudo sh test/delete.sh
        '''
      }
    }
    stage('Ready for Release') {
      steps {
        sh '''#!/bin/bash
          echo "9. Tag for release ready"
          sudo cp -p /opt/devops/mongo-api/vault ./group_vars/all/
          sudo ansible-playbook release-tag.yml
          sudo rm -f ./group_vars/all/vault
          echo "10. Release tagged!"
        '''
      }
    }
    stage('Post Tasks') {
      steps {
        sh '''#!/bin/bash
          echo "11. Clean up artifects"
          cd ${WS}
          echo "Close the change request if opened"
          echo "12. Done!"
        '''
      }
    }
  }
}
