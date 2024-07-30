# AKS Cookbook

## AKS Automatic lab

Azure Kubernetes Service (AKS) Automatic offers an experience that makes the most common tasks on Kubernetes fast and frictionless, while preserving the flexibility, extensibility, and consistency of Kubernetes. Azure takes care of your cluster setup, including node management, scaling, security, and preconfigured settings that follow AKS well-architected recommendations. Automatic clusters dynamically allocate compute resources based on your specific workload requirements and are tuned for running production applications.

### Prerequisites
- [Python 3.8 or later version](https://www.python.org/) installed
- [Pandas Library](https://pandas.pydata.org) installed
- [VS Code](https://code.visualstudio.com/) installed with the [Jupyter notebook extension](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter) enabled
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- [An Azure Subscription](https://azure.microsoft.com/en-us/free/) with Contributor permissions
- [Sign in to Azure with Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively)
- [kubectl](https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?tabs=azure-cli#install-the-kubernetes-cli) command line tool

### 🚀 Get started
Proceed by opening the [Jupyter notebook](aks-automatic.ipynb), and follow the steps provided.

### 🗑️ Clean up resources
When you're finished with the lab, you should remove all your deployed resources from Azure to avoid extra charges and keep your Azure subscription uncluttered.
Use the [clean-up-resources notebook](clean-up-resources.ipynb) for that.