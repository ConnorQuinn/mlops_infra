# mlops_infra
# Usage
- `az login`
- `az account set --subscription "MLOps_subscription"`
- `terraform apply -var-file=dev.tfvars`
- `terraform destroy -var-file=dev.tfvars`
- `export TF_VAR_mlops_..`



- Which region?
- Hub and spoke?



- One subscription containing three environments.
- Environments in separate VNets
- Metastore
- Vnet injected workspaces
- Terraform will not use CI/CD. We will just deploy the infra direct. But then we will use CI/CD for code deployments. 