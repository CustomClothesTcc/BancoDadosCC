DROP DATABASE CustomClothes;
CREATE DATABASE CustomClothes;
USE CustomClothes;

-- Tabela Funcionario
CREATE TABLE tbFuncionario(
CPF varchar(11) primary key,
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
CPF varchar(11) primary key,
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
CPFFun varchar(11), -- CPF de Funcionario
CPFCli varchar(11), -- CPF de Cliente

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
CPFCli varchar(11) not null, -- CPF cliente
CPFFun varchar(11), -- CPF Funcionario

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
CPFCli varchar(11) not null,
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
    IdCliente varchar(11) not null, 
    IdPagamento int not null, 
    
    -- Chaves estrangeiras
    foreign key (IdPedido) references tbPedido(IdPedido),
    foreign key (IdCliente) references tbCliente(CPF),
    foreign key (IdPagamento) references tbPagamento(IdPagamento)
);

-- trigger
-- restrições
-- view com iner join para nota fiscal


-- PROCEDURES DE CLIENTE
-- CADASTRAR CLIENTE
drop procedure pcd_CadastrarCliente;
DELIMITER $$
create procedure pcd_CadastrarCliente(
_CPF varchar(11),
_RG varchar(9),
_Nome varchar(50),
_DataNans date,
_Celular varchar(11),
_Sexo char(1),
_Email varchar(40),
_Senha varchar(20)
)
	begin
		start transaction;
			insert into tbCliente (CPF, RG, Nome, DataNans, Celular, Sexo, Email, Senha)
			values (_CPF, _RG, _Nome, _DataNans, _Celular, _Sexo, _Email, _Senha);
		commit;
	rollback;
end $$
-- Teste
CALL pcd_CadastrarCliente("54554512312", "256536987","Renata Teixeira", "2006-02-25",
 184596879, "M", "Natita@gmail.com", "1234578");
select * from tbCliente;

-- UPDATE CLIENTE	
drop procedure pcd_AtualizarCliente;
DELIMITER $$
create procedure pcd_AtualizarCliente(
_CPF varchar(11),
_RG varchar(9),
_Nome varchar(50),
_DataNans date,
_Celular varchar(11),
_Sexo char(1),
_Email varchar(40),
_Senha varchar(20)
)
	begin
		start transaction;
			update tbCliente set RG = _RG, Nome = _Nome, DataNans = _DataNans,
            Celular = _Celular, Sexo = _Sexo, Email = _Email, Senha = _Senha
			where CPF = _CPF;
		commit;
	rollback;
end $$
call pcd_AtualizarCliente("54554512312", "256536987",'Renata', "2006-02-25",
 184596879, "M", "Natita@gmail.com", "1234578");

-- EXCLUIR CLIENTE
DELIMITER $$
create procedure pcd_DeletarCliente(_CPF varchar(11))
begin
	delete from tbCliente where CPF = _CPF;
end $$
call pcd_DeletarCliente("54554512312");

-- LOGIN DE CLIENTE
DELIMITER $$
CREATE PROCEDURE pcd_LoginCliente(_Email varchar(40), _Senha varchar(20))
BEGIN 
	SELECT * FROM tbCliente WHERE Email = _Email AND Senha = _Senha;
END $$
CALL pcd_LoginCliente("Natita@gmail.com", "1234578");

-- OBTER CLIENTE POR CPF
DELIMITER $$
CREATE PROCEDURE pcd_ExibirCliente(_CPF varchar(11))
BEGIN 
	SELECT * FROM tbCliente WHERE CPF = _CPF;
END $$
CALL pcd_ExibirCliente("54554512312");

-- OBTER CLIENTE POR NOME
DELIMITER $$
CREATE PROCEDURE pcd_ExibirCliente_Nome(_Nome varchar(50))
BEGIN 
	SELECT * FROM tbCliente WHERE Nome = _Nome;
END $$
CALL pcd_ExibirCliente_Nome("Renata Teixeira");


