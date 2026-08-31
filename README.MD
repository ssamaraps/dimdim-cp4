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
az container create \
   --resource-group 559072-rg \
   --name 559072-app-container \
   --location brazilsouth \
   --image acr559072dimdim.azurecr.io/559072-app:latest \
   --registry-login-server acr559072dimdim.azurecr.io \
   --registry-username acr559072dimdim \
   --registry-password "SUA_SENHA_AQUI" \
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
     SPRING_DATASOURCE_PASSWORD="SUA_SENHA_AQUI"
```
