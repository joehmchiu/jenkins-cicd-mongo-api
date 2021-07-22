pipeline {
  environment {
    // create a backup workspace
    BWS = '/opt/projects/mongo-api'
  }

  agent any
  options {
      timeout(time: 1, unit: 'HOURS') 
  }
  stages {
    stage('Pre Tasks') {
      steps {
        echo 'Raise a change request if any.'
        sh '''#!/bin/bash
          if [ -e ${BWS} ]; then
            if [ -e "${BWS}/main.tf" ]; then
              echo "0. Destroy VM in ${BWS}"
              sudo cd ${BWS}
              sudo pwd
              sudo ls -lRthr
              sudo terraform init
              sudo terraform destroy -auto-approve
            fi
          else
            echo "0. Create Backup Workspace"
            sudo mkdir -p ${BWS}
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
          sudo cp -rf * ${BWS}/.
        '''
      }
    }
    stage('VM Validation') {
      steps {
        sh '''#!/bin/bash
          echo "3. Post VM Deployment Validations"
          sudo cp -p /opt/devops/mongo-api/vault ./group_vars/all/
          sudo ansible-playbook -i hosts -T 300 vm-validation.yml 
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
                sudo ansible-playbook -i hosts -e "BWS=${BWS}" -T 300 mongo-api.yml 
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
          sudo ansible-playbook -T 120 uat-release.yml
          sudo rm -f ./group_vars/all/vault
          echo "10. Release tagged!"
        '''
      }
    }
    stage('Post Tasks') {
      steps {
        sh '''#!/bin/bash
          echo "11. Clean up artifects"
          cd ${BWS}
          echo "Close the change request if opened"
          echo "12. Done!"
        '''
      }
    }
  }
}
