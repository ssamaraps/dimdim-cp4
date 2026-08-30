# Mercado Express - CP1 Java

API RESTful para gerenciamento de produtos de mercado, desenvolvida com Spring Boot, conteinerizada com Docker (usuário non-root) e hospedada no Azure.

## 👥 Integrante
* Samara Porto Souza — RM 559072

## 🚀 Tecnologias Utilizadas
* Java 21 / Spring Boot 3
* PostgreSQL (Azure Database)
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