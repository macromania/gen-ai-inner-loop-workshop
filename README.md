# GenAI Inner Loop Workshop - Upskill your search with AI

In this repository, you can find code samples for the [Azure AI Search](https://docs.microsoft.com/azure/search/), [Prompt Flow](https://github.com/microsoft/promptflow) and building RAG patterns for search.
Repository also contains self-paced, hands-on labs for the workshop. The workshop is designed to help you understand how to use AI to improve search relevance while Prompt Flow is a tool that helps you build high-quality LLM apps - from prototyping, testing to production deployment and monitoring. The workshop also covers inner loop details regarding environment setup, minimum viable infrastructure, and best practices for building AI-powered search experiences.

## Prerequisites

Following steps will guide you through the setup of the environment and Azure resources for the code samples and the workshop.

- **Azure CLI**: Infrastructure is setup using Azure CLI. See detailed instructions on how to setup [here](https://docs.microsoft.com/cli/azure/install-azure-cli).
- **Azure Developer CLI**: Azure Developer CLI is used to deploy the infrastructure. See detailed instructions on how to setup [here](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd).
- **Python**: Code samples are written in Python. Install Python from [here](https://www.python.org/downloads/). **Examples require Python 3.9+.**. You can also open the repo using [DevContainer](https://code.visualstudio.com/docs/remote/containers) to setup the environment.

## Setup Azure resources

You need to be already logged in to Azure CLI and Azure Developer CLI in your envrionment. If not, you can login using the following commands:

```bash
az login
azd login
```

**1.Portal Access:**

Set `AZURE_PRINCIPAL_ID` environment variable to be used setting up the portal resource access:

```bash
export AZURE_PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)
```

**2. Deploy services with Azure Developer CLI:**

This deploys infrastructure defined in `infra` folder using Azure Developer CLI. This includes Azure AI Search, Azure Storage, Azure Key Vault and related services required for the workshop and code samples.

```bash
azd up
```

**3. Set environment variables for local development into `.env` file:**

This command sets up environment variables required for local development into `.env` file. Notebooks and code samples can read from this file for API Keys and other secrets. `.env` is ignored in `.gitignore` file.

```bash
azd env get-values > .env
```

**4. Setup python virtual environment:**

This command sets up a python virtual environment and installs all the required packages from `requirements.txt`.

This command also sets up `.gitattribute` and [nbstripout](https://github.com/kynan/nbstripout) for Jupyter notebooks. This avoids the notebook outputs to be committed to the repository. `nbstripout` is a tool that can remove the output from Jupyter notebooks. When you run a Jupyter notebook, the output of each cell is saved in the notebook file. This can be problematic when using version control, as the output can change each time the notebook is run, even if the code hasn't changed. This can lead to large diffs and merge conflicts.  

This installs [Prompt Flow](https://github.com/microsoft/promptflow/) to build high-quality LLM apps - from prototyping, testing to production deployment and monitoring.

```bash
make setup-local-env
```

To use the newly created virtual environment, you can activate it using the following command:

```bash
source .venv/bin/activate
```
