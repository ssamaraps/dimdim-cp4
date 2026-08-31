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

### 1. Criação da Infraestrutura Básica

```bash
# Criar o Resource Group
az group create --name 559072-rg --location brazilsouth

# Criar o Azure Container Registry (ACR)
az acr create --resource-group 559072-rg --name acr559072dimdim --sku Basic --admin-enabled true

# Criar Conta de Armazenamento e File Share para persistência do banco
az storage account create --resource-group 559072-rg --name st559072dimdim --location brazilsouth --sku Standard_LRS
az storage share create --name db-share --account-name st559072dimdim

# Guardar a chave de acesso do Storage (usada no passo 5)
az storage account keys list --resource-group 559072-rg --account-name st559072dimdim --query "[0].value" -o tsv

# Login no ACR (necessário antes do docker push)
az acr login --name acr559072dimdim
```

### 2. Build e Push da Imagem do App

```bash
docker build -t acr559072dimdim.azurecr.io/559072-app:latest .
docker push acr559072dimdim.azurecr.io/559072-app:latest
```

### 3. Build e Push da Imagem do Banco

A imagem do banco é construída a partir do `banco-de-dados/Dockerfile`, que embute o `init.sql` (DDL da tabela `TDS_TB_mercado`) diretamente na imagem — garantindo que o banco também seja conteinerizado com uma imagem própria registrada no ACR, e não a imagem pública do Docker Hub.

```bash
docker build -t acr559072dimdim.azurecr.io/559072-db:latest ./banco-de-dados
docker push acr559072dimdim.azurecr.io/559072-db:latest
```

### 4. Teste local (antes do deploy)

```bash
docker network create rede-mercado

docker run -d --name db-local --network rede-mercado \
  -e POSTGRES_DB=mercado -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=admin \
  -p 5432:5432 acr559072dimdim.azurecr.io/559072-db:latest

docker run -d --name app-local --network rede-mercado \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://db-local:5432/mercado \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD=admin \
  -p 8082:8082 acr559072dimdim.azurecr.io/559072-app:latest
```

Testando tudo OK localmente, seguir para o deploy em nuvem.

### 5. Deploy do Container do Banco (ACI) — a partir da imagem do ACR

Ver script completo em [`script_azure_db.txt`](./script_azure_db.txt). Resumo:

```bash
az container create \
    --resource-group 559072-rg \
    --name 559072-db-container \
    --location brazilsouth \
    --image acr559072dimdim.azurecr.io/559072-db:latest \
    --registry-login-server acr559072dimdim.azurecr.io \
    --registry-username acr559072dimdim \
    --registry-password "SUA_SENHA_DO_ACR_AQUI" \
    --dns-name-label db559072 \
    --ports 5432 \
    --ip-address public \
    --os-type Linux \
    --cpu 1 \
    --memory 1 \
    --environment-variables \
        POSTGRES_DB="mercado" \
        POSTGRES_USER="postgres" \
    --secure-environment-variables \
        POSTGRES_PASSWORD="SUA_SENHA_DO_BANCO_AQUI" \
    --azure-file-volume-account-name st559072dimdim \
    --azure-file-volume-account-key "COLE_A_CHAVE_DO_STORAGE_AQUI" \
    --azure-file-volume-share-name db-share \
    --azure-file-volume-mount-path /var/lib/postgresql/data
```

> ⚠️ Todas as credenciais (senha do ACR e senha do banco) vão em `--secure-environment-variables`, nunca em `--environment-variables`, para não ficarem expostas em `az container show` / portal.

### 6. Deploy do Container do App (ACI) — a partir da imagem do ACR

Ver script completo em [`script_azure_app.txt`](./script_azure_app.txt). Resumo:

```bash
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
        SPRING_DATASOURCE_USERNAME="postgres" \
        SPRING_DATASOURCE_DRIVER_CLASS_NAME="org.postgresql.Driver" \
        SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT="org.hibernate.dialect.PostgreSQLDialect" \
    --secure-environment-variables \
        SPRING_DATASOURCE_PASSWORD="SUA_SENHA_DO_BANCO_AQUI"
```

### 7. Testes em nuvem

Usar a coleção `Mercado Express.postman_collection.json` (GET, POST, PUT, DELETE) apontando para a URL pública do app, e validar a persistência com `SELECT * FROM "TDS_TB_mercado";` diretamente no banco após cada operação.
