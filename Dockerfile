# Etapa 1: Preparação e Compilação (Build)
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Imagem final de execução (mais leve)
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Cria o usuário comum para não rodar como root (Requisito Crítico CP1)
RUN addgroup -S grupocp && adduser -S usuariocp -G grupocp

# Copia o arquivo .jar gerado na Etapa 1 e já passa a posse para o usuário seguro
COPY --from=build --chown=usuariocp:grupocp /app/target/*.jar app.jar

# Diz ao container para usar esse novo usuário
USER usuariocp

# Comando que liga a aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]
