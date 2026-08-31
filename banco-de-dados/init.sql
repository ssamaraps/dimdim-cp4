CREATE TABLE TDS_TB_mercado (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    setor VARCHAR(50),
    tamanho VARCHAR(20),
    tipo VARCHAR(50)
);
