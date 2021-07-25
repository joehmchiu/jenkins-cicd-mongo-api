pipeline {
  environment {
    // create a backup workspace
    WS = '/opt/projects/mongo-api'
    TC = 50
    crudxml = "reports/crud-test.xml"
    loadxml = "reports/load-test.xml"
    tmpfile = '/tmp/test-tmp-file'
    testfile = '/tmp/test-results'
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
          if [ -e ${WS} ]; then
            if [ -e "${WS}/main.tf" ]; then
              echo "0. Destroy VM"
              cd ${WS}
              sudo pwd
              sudo ls -lRthr
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
          sudo cp -rf . ${WS}/.
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
                sudo ansible-playbook -i hosts -e "WS=${WS}" -T 300 mongo-api.yml 
              '''
            }
          }
        }
      }
    }
    stage('API CRUD Test') {
      steps {
        catchError {
          sh '''#!/bin/bash
            echo "5. Create test"
            sh test/create.sh | tee ${tmpfile}
            echo "{\\"Create\\":$(cat ${tmpfile} | jq '.status')}" > ${testfile}
            sleep 1

            echo "6. Read test"
            sh test/read.sh | tee ${tmpfile}
            echo "{\\"Read\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
            sleep 1

            echo "7. Update test"
            sh test/update.sh | tee ${tmpfile}
            echo "{\\"Update\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
            # echo "{\\"Update\\":\\"skip\\"}" >> ${testfile}
            sleep 1

            echo "8. Delete test"
            sh test/delete.sh | tee ${tmpfile}
            echo "{\\"Delete\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
          '''
        }
      }
    }
    stage('CRUD Test Report') {
      steps {
        catchError {
          sh "pytest -v -p no:warnings test --junitxml=${crudxml}"
        }
      }
    }
    stage('API Load Testing') {
      steps {
        catchError {
          sh '''#!/bin/bash
            rm -f ${testfile}
            for i in `seq 1 ${TC}`
            do
              echo -e ''$_{1..72}'\b-'
              echo "Test # $i"
              eho -e ''$_{1..72}'\b-'
              sh test/create.sh | tee ${tmpfile}
              if [ $(( ( RANDOM % 10 )  + 1 )) -lt 5 ]; then
                echo "{\\"Create\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
              else
                echo "{\\"Create\\":\\"skip\\"}" >> ${testfile}
              fi
              sh test/read.sh | tee ${tmpfile}
              if [ $(( ( RANDOM % 10 )  + 1 )) -lt 5 ]; then
                echo "{\\"Read\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
              else
                echo "{\\"Read\\":\\"skip\\"}" >> ${testfile}
              fi
              sh test/update.sh | tee ${tmpfile}
              if [ $(( ( RANDOM % 10 )  + 1 )) -lt 5 ]; then
                echo "{\\"Update\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
              else
                echo "{\\"Update\\":\\"skip\\"}" >> ${testfile}
              fi
              sh test/delete.sh | tee ${tmpfile}
              if [ $(( ( RANDOM % 10 )  + 1 )) -lt 5 ]; then
                echo "{\\"Delete\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
              else
                echo "{\\"Delete\\":\\"skip\\"}" >> ${testfile}
              fi
            done
          '''
        }
      }
    }
    stage('Load Test Report') {
      steps {
        catchError {
          sh "pytest -v -p no:warnings test --junitxml=${loadxml}"
        }
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
          cd ${WS}
          echo "Close the change request if opened"
          echo "12. Done!"
        '''
      }
    }
  }
  post {
    always {
      junit allowEmptyResults: true, testResults: '**/reports/*.xml'
    }
  }
}
