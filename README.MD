# Mercado Express - CP1 Java

API RESTful para gerenciamento de produtos de mercado, desenvolvida com Spring Boot, conteinerizada com Docker (usuário non-root) e hospedada no Azure.

## 👥 Integrante
* Samara Porto Souza — RM 559072

## 🚀 Tecnologias Utilizadas
* Java 21 / Spring Boot 3
* PostgreSQL (Azure Container Instance)
* Docker & Azure Container Registry (ACR)
* Azure Container Instances (ACI)

## 🔗 URL da Aplicação (Azure)
A API está no ar e pode ser testada através da URL base abaixo:
**http://app559072.brazilsouth.azurecontainer.io:8082/mercado**

## 📌 Endpoints Disponíveis
* `GET /mercado` - Retorna a lista de todos os produtos
* `GET /mercado/{id}` - Retorna um produto específico pelo ID
* `POST /mercado` - Cria um novo produto
* `PUT /mercado/{id}` - Atualiza todos os dados de um produto
* `PATCH /mercado/{id}` - Atualiza dados parciais de um produto
* `DELETE /mercado/{id}` - Exclui um produto

## 🛠️ How To - Tutorial de Execução (Deploy na Azure)

**1. Criação da Infraestrutura Básica:**
```bash
# Criar o Resource Group
az group create --name 559072-rg --location brazilsouth

# Criar o Azure Container Registry (ACR)
az acr create --resource-group 559072-rg --name acr559072dimdim --sku Basic --admin-enabled true

# Criar Conta de Armazenamento e File Share para persistência
az storage account create --resource-group 559072-rg --name st559072dimdim --location brazilsouth --sku Standard_LRS
az storage share create --name db-share --account-name st559072dimdim
