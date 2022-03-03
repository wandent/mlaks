# Environment variables
. "$PSScriptRoot\environment.ps1"

az ml compute attach --workspace-name $aml --resource-group $mlrg --type "Kubernetes" --identity-type SystemAssigned --name $aks --namespace $aks_ns --resource-id "/subscriptions/$subscriptionid/resourcegroups/$aksrg/providers/Microsoft.ContainerService/managedClusters/$aks"