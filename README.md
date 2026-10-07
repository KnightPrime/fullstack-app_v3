# My Zero-Downtime Fullstack App 🚀

[![Production Deployment Pipeline](https://github.com/KnightPrime/fullstack-app_v3/actions/workflows/deploy.yml/badge.badge?branch=docker)](https://github.com/KnightPrime/fullstack-app_v3/actions/workflows/deploy.yml)
[![Live Application Verification](https://github.com/KnightPrime/fullstack-app_v3/actions/workflows/verify.yml/badge.svg?branch=docker)](https://github.com/KnightPrime/fullstack-app_v3/actions/workflows/verify.yml)

# fullstack-app_v3

Version 3 of fullstack-app

> Uses v2 as template.
> Created to try & test ci/cd workflows without worrying about build issues, as its already stable in v2.
>
## Branch Specific (Parent : Dockerhub):
>
-> This branch is build for the following deployment apparoch : 
  Code -> Git -> GitHub -> IaC -> Terraform -> GitHub Actions -> workflow yaml -> build -> checkout -> AWS infra -> Dockerhub -> Docker deploy -> server.  

### update :
1. Added code for destroy pipeline as well

> Destroy apparoch : 
> App on Server -> manual activation -> Github Actions -> workflow yaml -> destroy -> tear down infra -> cleanup.

2. Added saving infra state in S3 bucket, which is build on creation if it doesn't already exist in deploy workflow.
   > Its refrenced for checking and comparing current state of infra with the template, when rebuild is needed.
   > This prevents rebuilding everytime over changes in app code, only done when change/break in infra itself.
   > The bucket persisits even after destuction of infra, as its untouched by destroy workflow.

3. Added a validation check to test the app & infra running on successful exection of deploy workflow.

### update 2:
1. Added a validation script to check the live app's status and return output in a clickable dashboard with direct link to app url.
> This is a separate workflow.
> This script is auto-called by deploy workflow when it finishes its own execution, passing necessary parameters required for successful validation run.

2. Changes in destroy workflow, updated to enable destruction of the state bucket as well.
   > This is an 'optional' add-on.
   > When destroy workflow is activated, the workflow generates a prompt asking permission to whether destroy the bucket as well or not.
   > By default, its set to NO.
   > When bucket deletion is needed, manual authorization via answering prompt as YES is required.

### update 3:
1. Added package locks for both frontend and backend to code.
2. Added a new testing workflow to perform integration and unit tests before build is deployed.
   > This workflow is auto-called by deploy workflow in the very beginning as a required step to be completed before it itself runs.
   > The test workflow outputs a clean, sleek summary dashboard when its finished.
   > If all tests are green, ONLY then the deploy workflow itself is called to create infra and deploy build.

### update 4:
1. Added & completed the shift from 'infrastructure first' approach that priorities app live time but had slower initial spin time, to a hybrid 'Hot swap : Blue/Green Deployment' model approach with Docker Caching.
   > This greatly improves both initial spin-up time, as well as near instant updations to the live app. As a new docker build images spins up with updated code without distrupting the live build already running.
   > This ensures that the users will have a seamless transition from old version to new version without even knowing or experiencing downtime.
   > Such an approach is crucial under production level servers already running the live app.

2. There is also a change to check memory and resources (cpu, mainly) usage.
   > This is done in three different points :
       A. Before the creation of new build image i.e. it only has the live usage by currently running version.
       B. During the swapping of build containers, this one is most important : as both old/live build and new/update builds are present concurrently for a very short period of time. This however, can use much more memory (almost 2x) than normal.
       C. After the swap, when handshake is done. This ensures the new build going live isn't over-consuming resources.
   > As long as there is sufficient memory available, no server down or any other problems will crop up.

3. Added a live health view label markdown to README itself. (beta).

#update 5:
Changed docker build image tag policy to two tags : latest (when applicable) and sha (sha-code to uniquely identify each distinct image).

### update 6:
1. Decoupling of environments, 'production' separated from 'development'.
> By default, the pushes from this branch will now only trigger deployment to 'development' env.
>  Only when a pull request is created and merged, resulting in a push to the parent branch, will the code changes be eligible to get in 'production' env.
> That also, requires manual approval from a reviewer to authorize via manual gate.
2. The destroy workflow as changed accordingly.
> It has now options to choose which env to tear down, when activated...and its a required step.
> The default option is 'development'.
> Both envs CAN NOT be teared down in same execution of destroy workflow.
> Tearing down 'production' env, like deploying to it, requires authorization from manual gate.
