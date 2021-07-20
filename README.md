# Jenkins Pipeline for MongoDB API CI / CD

A lite CI / CD sample by using Jenkins CICD tool to deploy an instance in AWS, deploy the MongoDB API microservice application and CRUD tests. 

## Tools
* Jenkins: https://www.jenkins.io/download/
* Docker Jenkins: https://www.jenkins.io/solutions/docker/
* Terraform: 1.0.2 
* Ansible: 2.11.1
* Python: 3.6.9

## Requirement
* Refer https://www.digitalocean.com/community/tutorials/how-to-use-vault-to-protect-sensitive-ansible-data-on-ubuntu-16-04 to create a vault and put into /opt/devops/mongo-api/vault with the following format.
```
mongo_user: [ATlas MongoDB user]
mongo_token: [Atlas MongoDB Token]
git_user: [your github username]
git_pass: [your github password]
```

## TODO
* VM deployment tests / validations
* Validation reports


