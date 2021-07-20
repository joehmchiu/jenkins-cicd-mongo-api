# Azure DevOps Pipeline for MongoDB API CI / CD

A lite CI / CD sample by using Azure DevOps to deploy an instance in AWS, deploy the MongoDB API microservice application and CRUD tests. 

## Tools
* Azure DevOps: https://dev.azure.com/[account]
* Terraform: 1.0.2 
* Ansible: 2.11.1
* Python: 3.6.9
* Azure DevOps Agent: dockerized container (not included)

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


