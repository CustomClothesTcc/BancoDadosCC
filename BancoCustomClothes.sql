DROP DATABASE CustomClothes;
CREATE DATABASE CustomClothes;
USE CustomClothes;

-- Tabela Funcionario
CREATE TABLE tbFuncionario(
CPF int primary key,
RG char(9) not null UNIQUE,
Nome varchar(50) not null,
DataNans date not null,
Celular char(11) not null,
Cargo varchar(20), -- Prentende criar um check futuramente
Sexo char(1),
Email varchar(40) not null,
Senha varchar(20) not null
);

-- Tabela Cliente
CREATE TABLE tbCliente(
CPF int primary key,
RG varchar(9) not null UNIQUE ,
Nome varchar(50) not null,
DataNans date not null,
Celular char(11) not null,
Sexo char(1),
Email varchar(40) not null,
Senha varchar(20) not null
);

-- Tabela Endereco
CREATE TABLE tbEndereco(
IdEnd int primary key auto_increment,
Logradouro varchar(50) not null,
Numero char(6) not null,
Estado char(2) not null,
Cidade varchar(50) not null,
Bairro varchar(50) not null,
CEP char(8) not null,
Complemento varchar(80),
CPFFun int, -- CPF de Funcionario
CPFCli int, -- CPF de Cliente

-- Chaves estrangeiras
foreign key (CPFFun) references tbFuncionario(CPF),
foreign key (CPFCli) references tbCliente(CPF),

-- Restricao (Usuario só pode informar ou CPFFun ou CPFCli)
CONSTRAINT cpf_restricao CHECK (
        (CPFFun IS NOT NULL AND CPFCli IS NULL) OR
        (CPFFun IS NULL AND CPFCli IS NOT NULL)
    )
);

-- Tabela Produto
CREATE TABLE tbProduto(
IdProduto int primary key auto_increment,
Tecido varchar(20) not null,
Descricao varchar(50),
Categoria varchar(20), -- Se é calça ou blusa
Cor varchar(20) not null,
Estampa varchar(255) not null,
Quanitidade int not null, -- não numeros negativos A VER
Tamanho char(2) not null,
CHECK(Tamanho = "P" || Tamanho = "M" || Tamanho = "G" || Tamanho = "GG"),
DescImg varchar(60), -- descrição de como a imagem esta estambada
Situacao char(15), -- ESGOTADO OU NAO
CHECK(Situacao = "ESGOTADO" || Situacao = "EM ESTOQUE" || Situacao = "INATIVO"),
Valor decimal(8,2)
); 

-- PEDIDO
CREATE TABLE tbPedido(
IdPedido int primary key auto_increment,
DataPedido datetime	not null default(current_timestamp),
DataTransito date, -- QUANDO PEDIDO SAIU EM TRANSITO
DataEntrega datetime, -- QUANDO PEDIDO FOI ENTREGUE
Status char(15),
CHECK(Status = "CANCELADO" || Status = "EM TRANSITO" || Status = "ENTREGUE" || Status = "PREPARANDO" || Status = "A PAGAR"),
ValorTotal decimal(8,2) DEFAULT 0,
CPFCli int not null, -- CPF cliente
CPFFun int, -- CPF Funcionario

-- Chaves estrangeiras
foreign key (CPFFun) references tbFuncionario(CPF),
foreign key (CPFCli) references tbCliente(CPF)
);
/*CREATE TRIGGER trg_UpdateValorTotalPedido
AFTER INSERT OR UPDATE OR DELETE ON tbItemPedido
FOR EACH ROW
BEGIN
    DECLARE total decimal(8,2);
    
    -- Calcula a soma de todos os itens do pedido
    SELECT SUM(ValorTotalItem) INTO total 
    FROM tbItemPedido 
    WHERE IdPedido = NEW.IdPedido;

    -- Atualiza o ValorTotal do pedido na tabela tbPedido
    UPDATE tbPedido 
    SET ValorTotal = total 
    WHERE IdPedido = NEW.IdPedido;
END;*/

-- ITEMPEDIDO
CREATE TABLE tbItemPedido(
IdItem int primary key,
Quantidade int not null,
Valor decimal(8,2) not null,
ValorTotalItem decimal(8,2) AS (Quantidade * Valor), -- Valor total do item / no select
ValorTotalCarrinho decimal(10,2) DEFAULT 0, -- Valor total do carrinho DUVIDA
IdProduto int,
IdPedido int,

-- Chaves estrangeiras
foreign key (IdProduto) references tbProduto(IdProduto),
foreign key (IdPedido) references tbPedido(IdPedido)
);
/* CREATE TRIGGER trg_UpdateValorTotalCarrinho
AFTER INSERT OR UPDATE OR DELETE ON tbItemPedido
FOR EACH ROW
BEGIN
    DECLARE total decimal(8,2);

    SELECT SUM(ValorTotalItem) INTO total FROM tbItemPedido;

    -- Atualiza o valor total do carrinho, assumindo que há apenas um registro na tabela de total
    UPDATE tbTotalPedido SET ValorTotal = total WHERE IdPedido = 1; -- Ajuste conforme necessário
END; */
-- OU
/*
CREATE TRIGGER trg_UpdateValorTotalCarrinho
AFTER INSERT OR UPDATE ON tbItemPedido
FOR EACH ROW
BEGIN
    UPDATE tbPedido
    SET ValorTotalCarrinho = (
        SELECT SUM(Quantidade * Valor)
        FROM tbItemPedido
        WHERE IdPedido = NEW.IdPedido
    )
    WHERE IdPedido = NEW.IdPedido;
END;
*/


-- PAGAMENTO
CREATE TABLE tbPagamento(
IdPagamento int primary key,
DataPag date not null default (current_date),
Hora time not null default(current_time),
FormaPag varchar(20) not null,
ICMS decimal(8,2),
ValorPedido decimal(8,2) not null,
ValorTotal decimal(8,2) AS (ValorPedido + IFNULL(ICMS, 0)) STORED, -- caucula o valor total
CPFCli int not null,
IdPedido int, -- DUVIDA 

-- Chaves estrangeiras
foreign key (CPFCli) references tbCliente(CPF),
foreign key (IdPedido) references tbPedido(IdPedido)
);

-- NOTAFISCAL
CREATE TABLE tbNotaFiscal(
    IdNotaFiscal int primary key auto_increment, 
    CodigoVerificacao int not null,     
    -- Informações da empresa CC
    NomeEmpresa varchar(20) not null, 
    CNPJ char(14) not null, 
    Logradouro varchar(50) not null, 
    Numero char(6) not null, 
    Estado char(2) not null, 
    Cidade varchar(50) not null, 
    Bairro varchar(50) not null, 
    CEP char(8) not null,
    Complemento varchar(50), 
    -- registro da nota
    Data date not null, 
    Hora time not null, 
    ValorTotal decimal(8,2) not null, 
    IdPedido int not null, 
    IdCliente int not null, 
    IdPagamento int not null, 
    
    -- Chaves estrangeiras
    foreign key (IdPedido) references tbPedido(IdPedido),
    foreign key (IdCliente) references tbCliente(CPF),
    foreign key (IdPagamento) references tbPagamento(IdPagamento)
);

-- procidures, 
-- trigger
-- restrições
-- view com iner join para nota fiscal




-- dataCadas timestamp default current_timestamp 
-- primary key(codDentista)
-- dateAtend date not null DEFAULT (CURRENT_DATE),
-- horaAtend time not null default (current_time),


-- arrumar a nota fical, e todos os atributos que são numeros mas n precisam de ser do tipo inteiro
