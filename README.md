## fullstack-app_v3

Version 3 of fullstack-app

> Uses v2 as template.
> Created to try & test ci/cd workflows without worrying about build issues, as its already stable in v2.
>
#Branch Specific :
>
-> This branch is build for the following deployment apparoch : 
  Code -> Git -> GitHub -> IaC -> Terraform -> GitHub Actions -> workflow yaml -> build -> checkout -> AWS infra -> Dockerhub -> Docker deploy -> server.  

#update :
1. Added code for destroy pipeline as well

> Destroy apparoch : 
> App on Server -> manual activation -> Github Actions -> workflow yaml -> destroy -> tear down infra -> cleanup.

2. Added saving infra state in S3 bucket, which is build on creation if it doesn't already exist in deploy workflow.
   > Its refrenced for checking and comparing current state of infra with the template, when rebuild is needed.
   > This prevents rebuilding everytime over changes in app code, only done when change/break in infra itself.
   > The bucket persisits even after destuction of infra, as its untouched by destroy workflow.

3. Added a validation check to test the app & infra running on successful exection of deploy workflow.
