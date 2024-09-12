# AKS Cookbook

## 🧪 Flyte on AKS to build and deploy data and machine learning pipelines

![visual](visual.png)

[Flyte](https://docs.flyte.org/en/latest/introduction.html) is an open-source workflow orchestrator that unifies machine learning, data engineering, and data analytics stacks to help you build robust and reliable applications. When using Flyte as a Kubernetes-native workflow automation tool, you can focus on experimentation and providing business value without increasing your scope to infrastructure and resource management. Keep in mind that Flyte isn't officially supported by Microsoft, so use it at your own discretion.  
This lab is based on the official [AKS documentation](https://learn.microsoft.com/en-us/azure/aks/use-flyte).

### Prerequisites

- [Python 3.8 or later version](https://www.python.org/) installed.
- [VS Code](https://code.visualstudio.com/) installed with the [Jupyter notebook extension](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter) enabled.
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
- [An Azure Subscription](https://azure.microsoft.com/en-us/free/) with Contributor permissions. If you don't have an Azure subscription, create an [Azure free account](https://azure.microsoft.com/en-us/pricing/purchase-options/azure-account?icid=azurefreeaccount) before you begin.
- [Sign in to Azure with Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively) and select the Azure Subscription that you want to use in this lab.
- [Install kubectl](https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-install-cli), the Kubernetes command-line tool.
- flytekit and flytectl installed. For more information, see [Flyte installation](https://flyte-next.readthedocs.io/en/latest/introduction.html#installation).

### 🚀 Get started

Proceed by opening the [Jupyter notebook](aks-flyte.ipynb), and follow the steps provided.

### 🗑️ Clean up resources

When you're finished with the lab, you should remove all your deployed resources from Azure to avoid extra charges and keep your Azure subscription uncluttered.
Use the [clean-up-resources notebook](clean-up-resources.ipynb) for that.
