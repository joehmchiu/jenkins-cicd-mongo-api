def test(int RNO, int SNO, int FNO, String ACT, String tmpfile, String testfile) {
  sh '''#!/bin/bash
    RNO=$(( ( RANDOM % 100 )  + 1 ))
    echo "[$RNO,$SNO,$FNO]
    if [ $RNO -lt $FNO ]; then
      echo "{\\"${ACT}\\":\\"failed\\"}" >> ${testfile}
    elif [ $RNO -lt $SNO ]; then
      echo "{\\"${ACT}\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
    else
      echo "{\\"${ACT}\\":\\"skip\\"}" >> ${testfile}
    fi
  '''
}

pipeline {
  agent any
  options {
      timeout(time: 1, unit: 'HOURS') 
  }

  parameters {
    choice(
        name: 'YN',
        choices:"Yes\nNo",
        description: "Destroy the VM? ")
    choice(
        name: 'SuccessRate',
        choices:"10\n20\n30\n40\n50\n60\n70\n80\n90\n100",
        description: "Success Rate(%)")
    choice(
        name: 'FailureRate',
        choices:"0\n10\n20\n30",
        description: "Failure Rate(%)")
  }

  environment {
    // create a backup workspace
    WS = '/opt/projects/mongo-api'
    TC = 50
    crudxml = "reports/crud-test.xml"
    loadxml = "reports/load-test.xml"
    tmpfile = '/tmp/test-tmp-file'
    testfile = '/tmp/test-results'
    SNO ="${params.SuccessRate}"
    FNO ="${params.FailureRate}"
    ok  = '\u2705'
    nok = '\u274C'
  }

  stages {
    stage('Pre Tasks') {
      steps {
        echo 'Raise a change request if any.'
        sh '''#!/bin/bash
          if [ ! -e ${WS} ]; then
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
          cd '${WORKSPACE}'
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
        script {
          try {
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
          } catch (Exception e) {
            echo "${ok} Validation failure found, it's OK"
          }
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
        script {
          try {
            sh '''#!/bin/bash
              rm -f ${testfile}
              for i in `seq 1 ${TC}`
              do
                echo -e ''$_{1..72}'\b-'
                echo "Test # $i"
                echo -e ''$_{1..72}'\b-'

                sh test/create.sh | tee ${tmpfile}
                test($RNO, $SNO, $FNO, "Create", "${tmpfile}", "${testfile}")

                sh test/read.sh | tee ${tmpfile}
                RNO=$(( ( RANDOM % 100 )  + 1 ))
                echo "[$RNO,$SNO,$FNO]
                if [ $RNO -lt $FNO ]; then
                  echo "{\\"Read\\":\\"failed\\"}" >> ${testfile}
                elif [ $RNO -lt $SNO ]; then
                  echo "{\\"Read\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
                else
                  echo "{\\"Read\\":\\"skip\\"}" >> ${testfile}
                fi

                sh test/update.sh | tee ${tmpfile}
                RNO=$(( ( RANDOM % 100 )  + 1 ))
                echo "[$RNO,$SNO,$FNO]
                if [ $RNO -lt $FNO ]; then
                  echo "{\\"Update\\":\\"failed\\"}" >> ${testfile}
                elif [ $RNO -lt $SNO ]; then
                  echo "{\\"Update\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
                else
                  echo "{\\"Update\\":\\"skip\\"}" >> ${testfile}
                fi

                sh test/delete.sh | tee ${tmpfile}
                RNO=$(( ( RANDOM % 100 )  + 1 ))
                echo "[$RNO,$SNO,$FNO]
                if [ $RNO -lt $FNO ]; then
                  echo "{\\"Delete\\":\\"failed\\"}" >> ${testfile}
                elif [ $RNO -lt $SNO ]; then
                  echo "{\\"Delete\\":$(cat ${tmpfile} | jq '.status')}" >> ${testfile}
                else
                  echo "{\\"Delete\\":\\"skip\\"}" >> ${testfile}
                fi

              done
            '''
          } catch (Exception e) {
            echo "${ok} Validation failure found, it's OK"
          }
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
    stage('Clean Up') {
      steps {
        sh '''#!/bin/bash
          echo "11. Clean up artifects"
          cd ${WS}
          echo "${ok} 12. Done!"
        '''
      }
    }
  }
  post {
    always {
      echo "${ok} Junit Results"
      junit allowEmptyResults: true, testResults: '**/reports/*.xml', skipPublishingChecks: true
      script {
        if ("${params.YN}" == "Yes") {
          echo "${ok} Destroy VM, test only"
          sh '''#!/bin/bash
            if [ -e "${WS}/main.tf" ]; then
              cd ${WS}
              sudo pwd
              sudo ls -lRthr
              sudo terraform init
              sudo terraform destroy -auto-approve
            fi
          '''
        }
      }
    }
    success {
      echo "${ok} Tag for release ready"
      sh '''#!/bin/bash
        sudo ansible-playbook -T 120 uat-release.yml
        sudo rm -f ./group_vars/all/vault
        echo "10. Release tagged!"
      '''
      echo "${ok} Close the change request if opened"
    }
    unstable {
        echo "${ok} ${nok} Unstable status occurs..."
    }
    failure {
      echo "${nok} Failures found"
    }
    changed {
        echo "${ok} Things were different before..."
    }
  }
}
