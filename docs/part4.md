# Part 4: Building LLM Apps using Prompt Flow

[Prompt flow](https://microsoft.github.io/promptflow/index.html) is a suite of development tools designed to streamline the end-to-end development cycle of LLM-based AI applications, from ideation, prototyping, testing, evaluation to production deployment and monitoring. It makes prompt engineering much easier and enables you to build LLM apps with production quality.

This section will guide you through the basic concepts of Prompt Flow. The section also covers creating and running a simple ChatGPT application:

- Setting up Prompt Flow
- Hello world chat
- Using AI Studio

## Prompt Flow Concepts

- **Flows**: A flow in prompt flow is a DAG of functions (we call them tools). These functions/tools connected via input/output dependencies and executed based on the topology by prompt flow executor.
- **Tools**: Prompt flow provides 3 basic tools:
  - **LLM**: The LLM tool allows you to write custom prompts and leverage large language models to achieve specific goals, such as summarizing articles, generating customer support responses, and more.
  - **Python**: The Python tool enables you to write custom Python functions to perform various tasks, such as fetching web pages, processing intermediate data, calling third-party APIs, and more.
  - **Prompt**: The Prompt tool allows you to prepare a prompt as a string for more complex use cases or for use in conjunction with other prompt tools or python tools.
- **Connections**: Connections are for storing information about how to access external services like LLMs: endpoint, api keys etc.
- **Variants**: A variant refers to a specific version of a tool node that has distinct settings. Currently, variants are supported only in the LLM tool. For example, in the LLM tool, a new variant can represent either a different prompt content or different connection settings.

## 🛠️ Exercise: Build World Cup Chat Bot

In this exercise, you will build a simple chat bot that can answer questions about the World Cup. You will use the LLM tool to write custom prompts and leverage large language models to achieve specific goals.

### ✅ Step 1: Setting up Prompt Flow

Run following command to create a new chat prompt flow project:

```bash
mkdir world-cup-chat

pf flow init --flow ./world-cup-chat --type chat
```

You will see following directory structure:

```bash
.
├── .gitignore
├── .promptflow
│   └── flow.tools.json
├── README.md
├── azure_openai.yaml
├── chat.jinja2
├── flow.dag.yaml
├── openai.yaml
└── requirements.txt
```

A flow directory is a directory that contains all contents of a flow. Structure of flow folder:

- **flow.dag.yaml**: The flow definition with inputs/outputs, nodes, tools and variants for authoring purpose.
- **.promptflow/flow.tools.json**: It contains tools meta referenced in flow.dag.yaml.
- **Source code files (.py, .jinja2)**: User managed, the code scripts referenced by tools.
- **requirements.txt**: Python package dependencies for this flow.

### ✅ Step 2: Update Prompt

Open `chat.jinja2` and update the prompt with the following content:

```jinja2
system:
You are a helpful assistant that only knows about World Cup. If you don't have an answer, you can reply with "I don't know, I only know about World Cup" and DON'T generate anything else.
Answer with markdown format, use lists for squad and fixtures, and use tables for standings and results.

{% for item in chat_history %}
user:
{{item.inputs.question}}
assistant:
{{item.outputs.answer}}
{% endfor %}

user:
{{question}}
```

### ✅ Step 3: Create Connection

As we are only using Azure Open AI in this exercise, delete `openai.yaml` created by default and create a new file `azure_openai.yaml` with the following content (if doesn't exist):

```yaml
$schema: https://azuremlschemas.azureedge.net/promptflow/latest/AzureOpenAIConnection.schema.json
name: open_ai_connection
type: azure_open_ai
api_key: "<user-input>"
api_base: "<user-input>"
api_type: "azure"
```

We are going to use this `yaml` file to store the connection information for Azure Open AI in the flow. `promptflow` uses this file as a template and replaces the placeholders with the actual values. It stores the actual values in memory and does not write them to the file.

Let's export the `.env` file to the environment variables so that we can use the values in the `connect` command. This command reads the `.env` file, removes any comments (lines starting with #), and formats the remaining lines as VARNAME=value strings

```bash
export $(cat .env | sed 's/#.*//g' | xargs)
```

You can run `echo $AZURE_OPENAI_API_KEY` to verify the environment variable is set.

Let's create the connection using the following command:

```bash
pf connection create -f ./world-cup-chat/azure_openai.yaml --set api_key=$AZURE_OPENAI_API_KEY api_base=$AZURE_OPENAI_ENDPOINT
```

You will see the following output:

```bash
{
    "name": "open_ai_connection",
    "module": "promptflow.connections",
    "created_date": "2024-02-13T11:27:59.541274",
    "last_modified_date": "2024-02-22T07:52:43.743087",
    "type": "azure_open_ai",
    "api_key": "******",
    "api_base": "https://cog-lwh3iksdlsdsq.openai.azure.com/",
    "api_type": "azure",
    "api_version": "2023-07-01-preview"
}
```

### ✅ Step 4: Update Flow

We created chat deployment in [Part 2](../part2.md). We will use the same deployment for this exercise. Update the `flow.dag.yaml` with the following content:

```diff
L:22
--    deployment_name: gpt-35-turbo
++    deployment_name: chat
```

### ✅ Step 4: Run the Chat

Run the following command to start the chat in your terminal

```bash
pf flow test --flow ./world-cup-chat --interactive
```

Ask a question: `Tell me something about it`

You may get an answer like this (or similar):

```plaintext
The World Cup is an international football tournament that takes place every four years. It is organized by FIFA (Fédération Internationale de Football Association) and features national teams from countries all around the world. The first tournament was held in 1930 and it has since become one of the most popular and prestigious sporting events in the world.
```

if you ask a question that is not related to the World Cup, you will get the following response: `Why sky is blue?`

```plaintext
I don't know, I only know about World Cup.
```

Finally, ask a question to perform the required task stated in system propmt: `What are the standings for the World Cup 2002 and who was the 3rd place?`

```plaintext
| Position | Team |
| --- | --- |
| 1 | Brazil |
| 2 | Germany |
| 3 | Turkey |
| 4 | South Korea |
| Quarter-finals | England, Senegal, Spain, United States |
| Round of 16 | Belgium, Denmark, Italy, Japan, Mexico, Paraguay, Russia, Sweden |
| Group stage | Argentina, China, Costa Rica, Croatia, Ecuador, France, Nigeria, Poland, Portugal, Republic of Ireland, Saudi Arabia, Slovenia, South Africa, Tunisia, Uruguay |

Turkey finished in 3rd place after defeating South Korea in the third-place playoff match.
```

## 🏁 Milestone Check

You have successfully created a simple chat bot using Prompt Flow that only knows about the World Cup. This is a simple example to get you started with Prompt Flow. You can now explore more complex use cases and build more advanced chat bots.