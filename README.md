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

#update 2:
1. Added a validation script to check the live app's status and return output in a clickable dashboard with direct link to app url.
> This is a separate workflow.
> This script is auto-called by deploy workflow when it finishes its own execution, passing necessary parameters required for successful validation run.

2. Changes in destroy workflow, updated to enable destruction of the state bucket as well.
   > This is an 'optional' add-on.
   > When destroy workflow is activated, the workflow generates a prompt asking permission to whether destroy the bucket as well or not.
   > By default, its set to NO.
   > When bucket deletion is needed, manual authorization via answering prompt as YES is required.

#update 3:
1. Added package locks for both frontend and backend to code.
2. Added a new testing workflow to perform integration and unit tests before build is deployed.
   > This workflow is auto-called by deploy workflow in the very beginning as a required step to be completed before it itself runs.
   > The test workflow outputs a clean, sleek summary dashboard when its finished.
   > If all tests are green, ONLY then the deploy workflow itself is called to create infra and deploy build.
