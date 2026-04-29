
1. Build starter github actions script for infra with prod approval gate

        build a deploy script that triggers on a change to the infra folder on the main branch.  This script should execute a seperate run for each environment defined in the environments sub directory.  It should authenticate to GCP, execute a terraform plan and apply.  Include the ability to define specific environments that will require a manual approval before moving to the terraform apply.  Example - able to configure an automatic tf apply for "dev" but require an approval gate for "prod"

2. Github Actions was failing due to a permission error.  The root cause ended up being the permissions I assigned the Service Account had not yet propogated at runtime.  

            I am getting the following error running my infra deploy github action workflow.  The error is below.  Please help me identify root cause and fix.  

            Steps taken: Gave the github-actions service account "Storage Admin" as part of temporary troubleshooting

            Error: Run terraform init -input=false
            Initializing the backend...
            Initializing modules...
            - gke in ../../modules/gke
            - iam in ../../modules/iam
            ╷
            │ Error: Failed to get existing workspaces: querying Cloud Storage failed: googleapi: Error 403: *** does not have storage.objects.list access to the Google Cloud Storage bucket. Permission 'storage.objects.list' denied on resource (or it may not exist)., forbidden
            │ 
            │ 
            ╵
            Error: Terraform exited with code 1.
            Error: Process completed with exit code 1.

3. More ghost chasing
        I have validated the bucket exists.  I have granted OIDC access to the service account: Service account - github-actions
        Client library config - attribute.repository="stevenvilbert/devops-challenge"
        bucket: moonpay-playground-tfstate

4. Terraform Docs were underwhelming for limiting the disk space allocation for the default node pool
        The default node group for EKS is currently configured at 100gb by default.  Update the Terraform to enforce a max disk size of 15gb for the default node pool

5. Build cross region cloudsql read replica
        update the cloudsql terraform to also provision a read replica in the region definied by the variable: cloudsql_replication_region

6. Wire up network connectivity 
    Take the vpc and subnet I created in the networking module and ensure conectivity between the gke cluster and the cloudsql database.  Ensure connectivity is only allowed on port 5432 from the GKE cluster

7. Build Dockerfile 
    generate a dockerfile for my nextjs app.  Use the slim version of Node to keep the image lightweight.  Exclude the infra directory and any .md files

    We need to ensure pnpm db:migrate runs on startup to have database migrations run on startup

8. Build wireframe helm chart 
    Generate a wireframe helm chart to deploy this app to GKE.  The nextjs should be a deployment, and the database should be a statefulset.

9. Build github actions script and use secrets manager for secrets
    Build a github actions workflow to do the following 
        1: Build, tag, and push the docker image (image repo already created as a github actions secret)
        2: Pull all secrets from GCP secrets manager and inject them into the cluster as a k8s secret (update the helm chart accordingly)
        3: Deploy the app to the cluster.

10.  Troubleshoot corepack enable pnpm failing on node 24
    Identify the root cause of the error on the build and push docker image step 

        ERROR: failed to build: failed to solve: process "/bin/sh -c if [ -f package-lock.json ]; then     npm ci --no-audit --no-fund;   elif [ -f yarn.lock ]; then     corepack enable yarn && yarn install --frozen-lockfile --production=false;   elif [ -f pnpm-lock.yaml ]; then     corepack enable pnpm && pnpm install --frozen-lockfile;   else     echo \"No lockfile found.\" && exit 1;   fi" did not complete successfully: exit code: 1
        Error: Process completed with exit code 1.

11. Used AI here to help troubleshoot what ended up being a misformatted registry url in github action secrets
        name invalid: Missing image name. Pushes should be of the form docker push HOST-NAME/PROJECT-ID/REPOSITORY/IMAGE

12. Wire in namespace across the chart and templates 
    Update the helm chart to use the "moonpay-{env}" namespace.

13. Secrets were being applied before namespace existed which was causing an error.  Easy fix here
    It appears that the secrets are being applied before the namespace exists which is causing a deploy error.  Let's have the namespace be created before syncing the secrets 

14. The namespace being created before secrets didn't have the correct metadata for Helm to manage it.  
    Apply the missing keys to resolve this error: 

        Error: unable to continue with install: Namespace "moonpay-prod" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "moonpay"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "moonpay-prod"

15. Prisma was not being found on the pods on startup.  Even after the fix, it was still erroring due to the pullPolicy being set to IfNotPresent which a repeat prompt identified
    Prisma isn't being found on the pods.  Please identify root cause 

    svilbert98@cloudshell:~ (moonpay-playground)$ kubectl logs -n moonpay-prod moonpay-app-5465d45d45-xrzm4
        sh: 1: prisma: not found
        npm notice
        npm notice New minor version of npm available! 11.6.2 -> 11.13.0
        npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.13.0
        npm notice To update run: npm install -g npm@11.13.0
        npm notice

16. The primsa module cannot be found 

node:internal/modules/cjs/loader:1424
  throw err;
  ^

Error: Cannot find module '@prisma/engines'
Require stack:
- /app/node_modules/prisma/build/index.js
    at Module._resolveFilename (node:internal/modules/cjs/loader:1421:15)
    at defaultResolveImpl (node:internal/modules/cjs/loader:1059:19)
    at resolveForCJSWithHooks (node:internal/modules/cjs/loader:1064:22)
    at Module._load (node:internal/modules/cjs/loader:1227:37)
    at TracingChannel.traceSync (node:diagnostics_channel:328:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:245:24)
    at Module.require (node:internal/modules/cjs/loader:1504:12)
    at require (node:internal/modules/helpers:152:16)
    at Object.<anonymous> (/app/node_modules/prisma/build/index.js:163:33275)
    at Module._compile (node:internal/modules/cjs/loader:1761:14) {
  code: 'MODULE_NOT_FOUND',
  requireStack: [ '/app/node_modules/prisma/build/index.js' ]
}

17. Start building out load balancer, dns, and ssl 
    Goal: service is routable from the public internet

        Steps: 
        1.  Build a public load balancer to route traffic to the service. 
        2. DNS records and ssl certs are created via terraform to be accessible on moonpay.svilbert.app
        3.  Only port 443 is open on the load balancer, and port 80 redirects to 443

18. GKE Nodepool keeps being marked for replacement on new plans.  Build lifecycle rule 
    the GKE nodepool always wants to be replaced on a terraform apply.  Build a lifecycle rule so it stops recreating on every terraform apply

19. Terraform apply was still targeting the old "default-pool" causing a failure
        Getting this error on a terraform apply.  The default pool get's deleted on create.  Identify root cause

        Error: googleapi: Error 400: Node pool "default-pool" not found on update.
        │ Details:
        │ [
        │   {
        │     "@type": "type.googleapis.com/google.rpc.RequestInfo",
        │     "requestId": "0xdef6014c22f5ae37"
        │   }
        │ ]
        │ , badRequest
        │ 
        │   with module.gke.google_container_cluster.primary,
        │   on ../../modules/gke/main.tf line 1, in resource "google_container_cluster" "primary":
        │    1: resource "google_container_cluster" "primary" {

20.  Reqesting network audit to ensure accessiblity from public internet 
        while I wait for my ssl cert to finish provisioning, I'm trying to hit the load balancer ip directly and getting the error "ERR_CONNECTION_CLOSED".  Audit the networking config to make sure all is correct for accessing my app from the public internet

21. Enforce Modern SSL Standards 
    The current load balancer created by the gke ingress supports TLS 1.0 and 1.1.  Update the helm chart to enforce modern ssl policy standards

22. Moving db from statefulset to cloudsql, error on deploy
        I am getting the following error even though the db-statefulset.yaml is commented out.  Please identify root cause 

        Run helm upgrade --install moonpay ./helm \
        
        Error: UPGRADE FAILED: moonpay-devops-challenge/templates/db-statefulset.yaml:4:20
        executing "moonpay-devops-challenge/templates/db-statefulset.yaml" at <.Values.database.name>:
            nil pointer evaluating interface {}.name
        Error: Process completed with exit code 1.

23. Build cluster in DR region without nodegroups 
        Build a second GKE Cluster for our DR environment in us-east1.  Create a flag in the prod module for "is_dr" that will prevent the nodegroups from being created unless the flag is flipped.  The is_dr flag should also update the database dns record to point to the read replica ip address.  Ensure all firewalls are appropriately handeled in the DR region as well.
24. DR Cluster Target 
    In a DR event, a deploy to the DR cluster should be able to be kicked off from the github actions UI.  Create an optional "target cluster" for manual runs

25.  The GKE Cluster is failing to create because we exceed our 250 gb ssd quota.  Apply resource restrictions on the default nodegroups

26.  DR issue identified where certs are managed via ingress.  Move cert to terraform as fix 
    In the case of a DR scenario, certs should not be created by the helm charts, rather they should use a cert created via terraform.  This way during a DR event, we don't have to wait for a new cert to be provisioned, or worry about cert conflicts.  

        Steps: 
        Create cert in terraform
        Update helm chart to use that cert so regardless of which cluster it's deployed to, the cert will function

27.  The change in the helm chart caused the load balancer to not be created.  
        There are no load balancers after this change.  The load balancers should still be created by the helm chart, just use an external cert.

28. HPA Template 
    build an HPA template for the autoscaling I attached to the moonpay helm chart
