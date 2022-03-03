. "$PSScriptRoot\environment.ps1"
# provision aml workspace
write-host "deleting resource groups and previous resources..."
write-host $aksrg
Write-Host $mlrg
az group delete --name $aksrg --yes --output $output
az group delete --name $mlrg --yes --output $output
