/* ===================================================
    SISTEMA DE GERENCIAMENTO - SUPERMERCADO VIVAMAIS
----------------------------------------------------
PROJETO: Modelagem e Implementação de Banco de Dados
AUTORA: Marinize Fonseca de Godoy Santana
CURSO: Análise e Desenvolvimento de Sistemas - EAD - UniFECAF
FERRAMENTAS: brModelo /   MySQL Workbench
DATA: 10 de Novembro de 2025
------------------------------------------------------------
DESCRIÇÃO:
Este script cria o banco de dados físico do sistema
Supermercado VivaMais, com todas as tabelas, chaves primárias,
estrangeiras, restrições e integridades referenciais.
------------------------------------------------------------
   "O conhecimento é a semente; a prática é o florescer."
==================================================== */

-- Criei o DATABASE para meu Sistema 
CREATE DATABASE db_sistema_supermercado_vivamais;

-- Habilitando o DATABASE para uso
USE db_sistema_supermercado_vivamais;

-- Mostrando todos os DATABASES criados no MySQL
SHOW DATABASES;

-- Mostrando todas as tabelas criadas no DATABASE  que foi habilitado
SHOW TABLES;

-- Criação da tabela de clientes (tabela pai)
-- Estrutura simples, objetiva e sem redundância
CREATE TABLE tbl_cliente (
  id             INT PRIMARY KEY AUTO_INCREMENT,
  tipo                    ENUM('PF', 'PJ') NOT NULL
  );

-- Criação da 1º Tabela Filha (PF) com relacionamento 1,1 (herança total) com tbl_cliente
CREATE TABLE tbl_cliente_pf (
  id_cliente              INT NOT NULL,
  cpf                     VARCHAR(11) NOT NULL,
  nome_completo           VARCHAR(100) NOT NULL,
  
  -- Construção e nomeação da FK
  CONSTRAINT PK_Cliente_PF
  PRIMARY KEY (id_cliente),
  CONSTRAINT FK_Cliente_Cliente_PF
  FOREIGN KEY (id_cliente)
  REFERENCES tbl_cliente(id)
  -- Integridade referencial da herança total: atualizações e exclusões refletem aqui
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  -- Evita CPF duplicado para o mesmo cadastro e garante o formato numérico
  UNIQUE (cpf),
  CONSTRAINT CK_Cliente_PF_FormatoCPF
  CHECK (cpf REGEXP '^[0-9]{11}$')
);


-- Criação da 2ª tabela filha (PJ) com relacionamento 1:1 (herança total) com tbl_cliente
CREATE TABLE tbl_cliente_pj (
  id_cliente              INT NOT NULL,
  cnpj                    VARCHAR(14) NOT NULL,
  razao_social            VARCHAR(65) NOT NULL,
  
  
   -- Mesma lógica de herança total aplicada à tabela filha PJ
  CONSTRAINT PK_Cliente_PJ
  PRIMARY KEY (id_cliente),
  CONSTRAINT FK_Cliente_PJ_Cliente
  FOREIGN KEY (id_cliente)
  REFERENCES tbl_cliente(id)
  
  -- Integridade referencial agindo de mesmo modo q a tabela anterior
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  
  -- Evita CNPJ duplicado e garante o formato numérico
  CONSTRAINT UN_Cliente_PJ_CPF
  UNIQUE (cnpj),
  CONSTRAINT CK_Cliente_PJ_FormatoCNPJ
  CHECK (cnpj REGEXP '^[0-9]{14}$')
);

-- Criação da tabela telefone com relacionamento direto 1,N com o cliente
CREATE TABLE tbl_telefone (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  numero                  VARCHAR(20) NOT NULL,
  id_cliente              INT NOT NULL,
  
  
  -- Construção e nomeação da FK
  CONSTRAINT FK_Telefone_Cliente
  FOREIGN KEY (id_cliente)
  REFERENCES tbl_cliente(id)
  
 -- Telefone sempre associado a um cliente; alterações no cliente refletem aqui 
  ON DELETE CASCADE
  ON UPDATE CASCADE,
   
  -- Formatação básica de telefone (apenas dígitos)
  CONSTRAINT CK_FormatoTelefone 
  CHECK (numero REGEXP '^[0-9]{10,11}$')
);

-- Criação da tabela email com relacionamento 1,N com o cliente
CREATE TABLE tbl_email (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  nome_email              VARCHAR(255) NOT NULL,
  id_cliente              INT NOT NULL,
  
  CONSTRAINT FK_Email_Cliente
  FOREIGN KEY (id_cliente)
  REFERENCES tbl_cliente(id) 
  -- Email sempre vinculado a um cliente
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  
  -- Formatação básica de email
  CONSTRAINT CK_FormatoNomeEmail
  CHECK (nome_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Criação da tabela endereço que tem relacionamento direto de 1, N com o cliente
CREATE TABLE tbl_endereco (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  logradouro              VARCHAR(45) NOT NULL,
  complemento             VARCHAR(45) NULL,
  numero                  VARCHAR(45) NULL,
  cidade_uf               VARCHAR(100) NOT NULL,
  cep                     VARCHAR(8) NOT NULL,
  id_cliente              INT NOT NULL,
  
  CONSTRAINT FK_Endereco_Cliente
  FOREIGN KEY (id_cliente)
  REFERENCES tbl_cliente(id)
  -- Endereço sempre vinculado a um cliente; alterações refletem aqui
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

-- Criação da tabela vendedor
CREATE TABLE tbl_vendedor (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  cpf                     VARCHAR(11) NOT NULL,
  data_admissao           DATE NOT NULL,
  percentual_comissao     DECIMAL(5,2) NULL,
  nome_completo           VARCHAR(100) NOT NULL,
  
  -- Evita CPF duplicado e garante o formato numérico
  CONSTRAINT UN_Vendedor_CPF
  UNIQUE (cpf),
  CONSTRAINT CK_Vendedor_FormatoCPF
  CHECK (cpf REGEXP '^[0-9]{11}$'),
  CONSTRAINT ck_tbl_vendedor_percentual_comissao
  CHECK (percentual_comissao IS NULL OR (percentual_comissao >= 0 AND percentual_comissao <= 10))
  -- Percentual de comissão opcional, mas quando informado deve estar entre 0% e 10%
);


-- Criação da tabela venda com FKs de cliente e vendedor (relacionamento 1,N para ambos)
CREATE TABLE tbl_venda (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  data_hora               DATETIME NOT NULL,
  id_cliente              INT NOT NULL,
  id_vendedor             INT NOT NULL,
  
  CONSTRAINT FK_Venda_Cliente
  FOREIGN KEY (id_cliente)
  REFERENCES tbl_cliente(id)
  
   -- Mantém os dados do cliente por motivo de histórico: não permite excluir clientes já vendidos
  ON DELETE RESTRICT
  ON UPDATE CASCADE,
  
  CONSTRAINT FK_Venda_Vendedor
  FOREIGN KEY (id_vendedor)
  REFERENCES tbl_vendedor(id)
  
  -- Mesma lógica para o vendedor: preserva histórico das vendas realizadas
  ON DELETE RESTRICT
  ON UPDATE CASCADE
);

-- Criação da tabela de pagamento relacionada à venda (1,N)
CREATE TABLE tbl_pagamento (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  situacao                ENUM('Pendente', 'Pago', 'Atrasado') NOT NULL DEFAULT 'Pendente',
  valor                   DECIMAL(10,2) NOT NULL,
  data_vencimento         DATE NOT NULL,
  forma_pagamento         ENUM('Cartao', 'Pix', 'Boleto', 'Dinheiro') NOT NULL,
  numero_parcela          TINYINT UNSIGNED NOT NULL,
  id_venda                INT NOT NULL,
  
  CONSTRAINT FK_Pagamento_Venda
  FOREIGN KEY (id_venda)
  REFERENCES tbl_venda(id)
  -- Pagamento sempre vinculado a uma venda existente
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  
  -- Validação da quantidade de parcelas (entre 1 e 99)
  CONSTRAINT CK_Pagamento_Numero_Parcela
  CHECK (numero_parcela BETWEEN 1 AND 99),
  -- Valor do pagamento precisa ser positivo
  CONSTRAINT CK_ValorPositivo
  CHECK (valor > 0)
);

-- Criação da tabela categoria
-- Estrutura simples, mas sólida e sem redundância
CREATE TABLE tbl_categoria (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  nome_categoria          VARCHAR(45) NOT NULL,
  descricao               VARCHAR(100) NOT NULL,
  tipo                    ENUM('Hortifrúti', 'Mercearia', 'Limpeza', 'Carnes e Peixes', 'Frios e Laticínios', 'Bebidas', 'Congelados', 'Higiene Pessoal') NOT NULL
);

-- Criação da tabela produto, com relacionamento 1,N com categoria
CREATE TABLE tbl_produto (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  nome_produto            VARCHAR(65) NOT NULL,
  preco_venda             DECIMAL(10,2) NOT NULL,
  qtde_estoque_minimo     INT NOT NULL,
  unidade_medida          VARCHAR(10) NOT NULL,
  qtde_estoque            INT NOT NULL,
  status_produto          ENUM('Ativo', 'Inativo') NOT NULL,
  id_categoria            INT NOT NULL,
  
  CONSTRAINT FK_Produto_Categoria
  FOREIGN KEY (id_categoria)
  REFERENCES tbl_categoria(id)
  
  -- Não faz sentido cadastrar produto sem categoria
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  
  -- Garante que o preço de venda seja maior que zero
  CONSTRAINT CK_Produto_PrecoValido
  CHECK (preco_venda > 0)
);

-- Criação da tabela intermediária item_venda (tabela associativa com PK composta)
CREATE TABLE tbl_item_venda (
  preco_unitario          DECIMAL(10,2) NOT NULL,
  qtde_vendida            INT NOT NULL,
  desconto_item           DECIMAL(5,2) NULL,
  id_venda                INT NOT NULL,
  id_produto              INT NOT NULL,
  
  CONSTRAINT PK_Item_Venda
  PRIMARY KEY (id_venda, id_produto),
  CONSTRAINT FK_Item_Venda_Venda
  FOREIGN KEY (id_venda)
  REFERENCES tbl_venda(id)
  
  -- Integridade referencial usada de forma coerente dados q não fazem sentido serem guardados sozinhos
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  
  CONSTRAINT FK_Item_Venda_Produto
  FOREIGN KEY (id_produto)
  REFERENCES tbl_produto(id)
  -- Protege dados de produtos já usados em vendas, mantendo histórico
  ON DELETE RESTRICT 
  ON UPDATE CASCADE,
  
  -- Quantidade precisa ser maior que zero
  CONSTRAINT CK_Item_Venda_QtdeNNulo
  CHECK (qtde_vendida > 0),
  -- Desconto opcional, mas quando informado deve estar entre 0% e 100%
  CONSTRAINT CK_Item_Venda_Desconto_Item
  CHECK (desconto_item IS NULL OR (desconto_item >= 0 AND desconto_item <= 100))
);

-- Criação da tabela fornecedor
CREATE TABLE tbl_fornecedor (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  cnpj                    VARCHAR(14) NOT NULL,
  razao_social            VARCHAR(100) NOT NULL,
  telefone                VARCHAR(20) NOT NULL,
  email                   VARCHAR(255) NULL,
  cidade_uf               VARCHAR(65) NOT NULL,
  
  -- Evita duplicidade de CNPJ e email no mesmo cadastro
  CONSTRAINT UN_Fornecedor_CNPJ_Email
  UNIQUE (cnpj, email),
  CONSTRAINT CK_Fornecedor_FormatoCNPJ
  -- Valida formato do CNPJ e do email
  CHECK ( cnpj REGEXP '^[0-9]{14}$'),
  CONSTRAINT CK_Fornecedor_FormatoEmail
  CHECK ( email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Criação da tabela intermediária fornecedor_produto (tabela com PK composta e duas FKs)
CREATE TABLE tbl_fornecer_produto (
  preco_custo             DECIMAL(10,2) NOT NULL,
  prazo_entrega_dias      INT NOT NULL,
  id_produto              INT NOT NULL,
  id_fornecedor INT NOT NULL,
  
  CONSTRAINT PK_Fornecer_Produto
  PRIMARY KEY (id_produto, id_fornecedor),
  CONSTRAINT FK_Fornecer_Produto_Produto
  FOREIGN KEY (id_produto)
  REFERENCES tbl_produto(id)
  
  -- Não é coerente apagar produto que já foi fornecido; mantém restrito
  ON DELETE RESTRICT
  ON UPDATE CASCADE,
  
  CONSTRAINT FK_Fornecer_Produto_Fornecedor
  FOREIGN KEY (id_fornecedor)
  REFERENCES tbl_fornecedor(id)
  
  -- Também protege dados de fornecedor já usado em fornecimentos
  ON DELETE RESTRICT
  ON UPDATE CASCADE,
  
  -- Garante preço positivo e prazo de entrega não negativo
  CONSTRAINT CK_Fornecer_Produto_PrecoPositivo
  CHECK (preco_custo > 0),
  CONSTRAINT CK_Fornecer_Produto_PrazoValido
  CHECK (prazo_entrega_dias >= 0)
);