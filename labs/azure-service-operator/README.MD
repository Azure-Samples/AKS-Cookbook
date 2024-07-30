# AKS Cookbook

## Azure Service Operator

Azure Service Operator (ASO) allows you to deploy and maintain a wide variety of Azure Resources using the Kubernetes tooling you already know and use.

Instead of deploying and managing your Azure resources separately from your Kubernetes application, ASO allows you to manage them together, automatically configuring your application as needed.
For example, ASO can set up your Redis Cache or PostgreSQL database server and then configure your Kubernetes application to use them.

### Prerequisites
- [Python 3.8 or later version](https://www.python.org/) installed
- [Pandas Library](https://pandas.pydata.org) installed
- [VS Code](https://code.visualstudio.com/) installed with the [Jupyter notebook extension](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter) enabled
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- [An Azure Subscription](https://azure.microsoft.com/en-us/free/) with Contributor permissions
- [Sign in to Azure with Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively)
- [kubectl](https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?tabs=azure-cli#install-the-kubernetes-cli) command line tool
- A Kubernetes cluster (at least version 1.16) created and running. You can check your cluster version with kubectl version. If you want to create a new AKS cluster, please refer to this [Jupyter notebook](new-aks-cluster.ipynb)
- An Azure Subscription to provision resources into
- An Azure Service Principal for the operator to use, or the Azure CLI to create one. See the **Azure Service Principal** setup in the jupyter notebook as it's easiest to get started with. Azure Workload identity is instead recommended for production-oriented environments.

### 🚀 Get started
Proceed by opening the [Jupyter notebook](azure-service-operator.ipynb), and follow the steps provided.

### 🗑️ Clean up resources
When you're finished with the lab, you should remove all your deployed resources from Azure to avoid extra charges and keep your Azure subscription uncluttered.
Use the [clean-up-resources notebook](clean-up-resources.ipynb) for that.