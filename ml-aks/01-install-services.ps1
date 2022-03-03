# Environment variables
. "$PSScriptRoot\environment.ps1"

az account set --subscription $subscriptionid


write-host "creating resource groups..."
az group create --location $location --resource-group $aksrg --output $output
az group create --location $location --resource-group $mlrg --output $output

# provision aml workspace
# YAML schema to specify the ML Workspace in detail: https://docs.microsoft.com/en-us/azure/machine-learning/reference-yaml-workspace

write-host "Provision Azure ML Workspace"
az ml workspace create --name $aml --resource-group $mlrg --location $location --output $output

# if you want to specify existing objects, use the yaml with the resource id of each resource

# az ml workspace create --name $aml --resource-group $mlrg --file aml-test.yml --location $location --output $output


# aml-test.yml

# $schema: https://azuremlschemas.azureedge.net/latest/workspace.schema.json
# name: mlw-basicex-prod
# location: eastus
# display_name: Bring your own dependent resources-example
# description: This configuration specifies a workspace configuration with existing dependent resources
# storage_account: /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.Storage/storageAccounts/<STORAGE_ACCOUNT>
# container_registry: /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.ContainerRegistry/registries/<CONTAINER_REGISTRY>
# key_vault: /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.KeyVault/vaults/<KEY_VAULT>
# application_insights: /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.insights/components/<APP_INSIGHTS>
# tags:
#   purpose: demonstration

az aks install-cli

write-host "Provision AKS cluster..."
az aks create --resource-group $aksrg --name $aks --location $location --generate-ssh-keys --output $output

 

write-host "Register azure resources"
az provider register -n 'Microsoft.Kubernetes'

az provider register -n 'Microsoft.KubernetesConfiguration'

# wait until the aks is not only provisioned but also fully running
az aks wait --name $aks --custom  "provisioningState!='InProgress',instanceView.statuses[?code=='PowerState/running']"

# Create connected cluster (Azure Arc only)
write-host "Connect AKS cluster with Arc"
az connectedk8s connect --name $aks --resource-group $aksrg --location $location --tags Datacenter=DC1 City=Sao Paulo StateOrDistrict=SP CountryOrRegion=Brazil --output $output     

az connectedk8s enable-features --features cluster-connect --name $aks --resource-group $aksrg --output $output

# capture cluster credentials

az aks get-credentials --resource-group $aksrg --name $aks --output $output

# install azure ml extension

az k8s-extension create --name acml-extension --extension-type Microsoft.AzureML.Kubernetes --config enableTraining=True enableInference=True allowInsecureConnections=True --cluster-type managedClusters --cluster-name $aks --resource-group $aksrg --scope cluster --auto-upgrade-minor-version False --output $output

# Azure ML settings

# Attach the AKS cluster as attched compute

# az ml compute attach --workspace-name $aml --resource-group $mlrg --type "Kubernetes" --identity-type SystemAssigned --name $aks --namespace $aks_ns --resource-id "/subscriptions/$subscriptionid/resourcegroups/$aksrg/providers/Microsoft.ContainerService/managedClusters/$aks"





