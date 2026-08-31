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

**1. Build e Push da Imagem para o ACR:**
```bash
docker build -t acr559072dimdim.azurecr.io/559072-app:latest .
docker push acr559072dimdim.azurecr.io/559072-app:latest
```

**2. Criação do Container no ACI via Azure CLI:**
```bash
# 1. Criar o Resource Group
az group create --name 559072-rg --location brazilsouth

# 2. Criar o Azure Container Registry (ACR)
az acr create --resource-group 559072-rg --name acr559072dimdim --sku Basic --admin-enabled true

# 3. Criar Conta de Armazenamento (Storage Account) e File Share para persistência
az storage account create --resource-group 559072-rg --name st559072dimdim --location brazilsouth --sku Standard_LRS

# Pegar a chave de acesso do Storage (Copie o valor gerado para usar no passo 4)
az storage account keys list --resource-group 559072-rg --account-name st559072dimdim --query "[0].value" -o tsv

# Criar o File Share
az storage share create --name db-share --account-name st559072dimdim

# 4. Criar o Container do Banco de Dados (ACI) com o Volume Persistente montado
az container create \
    --resource-group 559072-rg \
    --name 559072-db-container \
    --location brazilsouth \
    --image postgres:15-alpine \
    --dns-name-label db559072 \
    --ports 5432 \
    --ip-address public \
    --environment-variables \
        POSTGRES_DB="mercado" \
        POSTGRES_USER="postgres" \
        POSTGRES_PASSWORD="admin" \
    --azure-file-volume-account-name st559072dimdim \
    --azure-file-volume-account-key "COLE_A_CHAVE_DO_STORAGE_AQUI" \
    --azure-file-volume-share-name db-share \
    --azure-file-volume-mount-path /var/lib/postgresql/data

# 5. Criar o Container da Aplicação (ACI)
az container create \
    --resource-group 559072-rg \
    --name 559072-app-container \
    --location brazilsouth \
    --image acr559072dimdim.azurecr.io/559072-app:latest \
    --registry-login-server acr559072dimdim.azurecr.io \
    --registry-username acr559072dimdim \
    --registry-password "SUA_SENHA_DO_ACR_AQUI" \
    --ip-address public \
    --os-type Linux \
    --cpu 1 \
    --memory 1 \
    --dns-name-label app559072 \
    --ports 8082 \
    --environment-variables \
        SERVER_PORT="8082" \
        SPRING_DATASOURCE_URL="jdbc:postgresql://db559072.brazilsouth.azurecontainer.io:5432/mercado" \
        SPRING_DATASOURCE_DRIVER_CLASS_NAME="org.postgresql.Driver" \
        SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT="org.hibernate.dialect.PostgreSQLDialect" \
    --secure-environment-variables \
        SPRING_DATASOURCE_USERNAME="postgres" \
        SPRING_DATASOURCE_PASSWORD="admin"
   --secure-environment-variables \
     SPRING_DATASOURCE_USERNAME="postgres" \
     SPRING_DATASOURCE_PASSWORD="SUA_SENHA_AQUI"
```
