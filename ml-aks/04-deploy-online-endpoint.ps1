. "$PSScriptRoot\environment.ps1"

az ml online-endpoint create --workspace-name $aml --resource-group $mlrg --name sklearn1 --file sklearn1-endpoint.yml

az ml online-deployment create --resource-group $mlrg --workspace-name $aml --file /blue-deployment.yml --all-traffic 