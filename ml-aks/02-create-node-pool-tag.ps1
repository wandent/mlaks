# creates the instance type in order to use the node-selector
kubectl apply -f mlinstance.yml


# enable kubecost
kubectl create namespace kubecost 
helm repo add kubecost https://kubecost.github.io/cost-analyzer/ 
helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken ="d2FuZGVudEBtaWNyb3NvZnQuY29txm343yadf98"
