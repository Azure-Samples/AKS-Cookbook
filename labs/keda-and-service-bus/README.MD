# AKS Cookbook

## Service Bus Queue scaled by KEDA

This setup will go through creating an Azure Service Bus queue and deploying this consumer with the ScaledObject to scale via KEDA. If you already have an Azure Service Bus namespace you can use your existing queues.

KEDA works alongside standard Kubernetes components like the Horizontal Pod Autoscaler and can extend functionality without overwriting or duplication.

Keda got two key roles within the cluster, **keda-operator** which scales from minimum to maximum pod counts set in the ScaledObject manifest file via Kubernetes Horizontal Pod Autoscaler and **keda-operator-metrics-apiserver** which gets the data for the scaling decision.

### Prerequisites
- [Python 3.8 or later version](https://www.python.org/) installed
- [Pandas Library](https://pandas.pydata.org) installed
- [VS Code](https://code.visualstudio.com/) installed with the [Jupyter notebook extension](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter) enabled
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- [An Azure Subscription](https://azure.microsoft.com/en-us/free/) with Contributor permissions
- [Sign in to Azure with Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively)
- [kubectl](https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?tabs=azure-cli#install-the-kubernetes-cli) command line tool
- A Kubernetes cluster created and running. You can check your cluster version with kubectl version. If you want to create a new AKS cluster, please refer to this [Jupyter notebook](new-aks-cluster.ipynb)
- An Azure Subscription to provision resources into

### 🚀 Get started
Proceed by opening the [Jupyter notebook](keda-and-service-bus.ipynb), and follow the steps provided.

### 🗑️ Clean up resources
When you're finished with the lab, you should remove all your deployed resources from Azure to avoid extra charges and keep your Azure subscription uncluttered.
Use the [clean-up-resources notebook](clean-up-resources.ipynb) for that.