-- Resetando o banco de dados
DROP DATABASE IF EXISTS CustomClothes;
CREATE DATABASE IF NOT EXISTS CustomClothes;
USE CustomClothes;

-- Tabela Endereco
CREATE TABLE tbEndereco (
    IdEndereco INT PRIMARY KEY AUTO_INCREMENT,
    Logradouro VARCHAR(100) NOT NULL,
    Numero VARCHAR(6) NOT NULL,
    Estado CHAR(2) NOT NULL,
    Cidade VARCHAR(50) NOT NULL,
    Bairro VARCHAR(50) NOT NULL,
    CEP CHAR(8) NOT NULL,
    Complemento VARCHAR(80)
);

-- Tabela Funcionario
CREATE TABLE tbFuncionario (
    CPF CHAR(11) PRIMARY KEY,
    RG CHAR(9) NOT NULL UNIQUE,
    Nome VARCHAR(50) NOT NULL,
    DataNans DATE NOT NULL,
    CelularTelefone VARCHAR(15) NOT NULL,
    Cargo ENUM('Administrador', 'Gerente', 'Vendedor') NOT NULL,
    Sexo CHAR(1),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Senha VARCHAR(255) NOT NULL,
    IdEndereco INT
);

-- Tabela Cliente
CREATE TABLE tbCliente (
    CPF CHAR(11) PRIMARY KEY,
    RG CHAR(9) NOT NULL UNIQUE,
    Nome VARCHAR(50) NOT NULL,
    DataNans DATE NOT NULL,
    Celular VARCHAR(15) NOT NULL,
    Sexo CHAR(1),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Senha VARCHAR(255) NOT NULL,
    IdEndereco INT
);

-- Tabela Produto
CREATE TABLE tbProduto (
    IdProduto INT PRIMARY KEY AUTO_INCREMENT,
    Descricao VARCHAR(100),
    Categoria ENUM('Calcados', 'Superior', 'Inferior', 'Acessorios', 'Outros'),
    Cor VARCHAR(20) NOT NULL,
    Valor DECIMAL(10,2) NOT NULL,
    Estampa VARCHAR(255),
    Tamanho CHAR(4) NOT NULL,
    Quantidade INT NOT NULL,
    DescImg TEXT,
    Situacao ENUM('Esgotado', 'Estoque', 'Inativo') DEFAULT 'Estoque',
    Tecido ENUM('ALGODAO', 'POLIESTER', 'SEDA', 'LINHO') NOT NULL
);

-- Tabela Pedido
CREATE TABLE tbPedido (
    IdPedido INT PRIMARY KEY AUTO_INCREMENT,
    DataPedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValorTotal DECIMAL(10,2) DEFAULT 0,
    PedidoStatus ENUM('CAMINHO', 'SEPARACAO', 'ENTREGUE', 'PROCESSO', 'CANCELADO') DEFAULT 'PROCESSO',
    Quantidade INT NOT NULL,
    DataTransito DATE,
    DataEntrega DATETIME,
    CPFCli CHAR(11) NOT NULL,
    CPFFun CHAR(11) NOT NULL
);

-- Tabela ItemPedido
CREATE TABLE tbItemPedido (
    IdItem INT PRIMARY KEY AUTO_INCREMENT,
    Quantidade INT NOT NULL,
    ValorUnit DECIMAL(10,2) NOT NULL,
    IdProduto INT NOT NULL,
    IdPedido INT NOT NULL
);

-- Tabela Pagamento
CREATE TABLE tbPagamento (
    IdPagamento INT PRIMARY KEY AUTO_INCREMENT,
    FormaPag ENUM('boleto', 'pix', 'debito', 'credito') NOT NULL,
    ValorPedido DECIMAL(10,2) NOT NULL,
    DataPag DATE NOT NULL,
    Hora TIME NOT NULL,
    CPFCli CHAR(11) NOT NULL,
    IdPedido INT NOT NULL
);

-- Tabela NotaFiscal
CREATE TABLE tbNotaFiscal (
    IdNotaFiscal INT PRIMARY KEY AUTO_INCREMENT,
    CodigoVerificacao INT NOT NULL,
    NomeEmpresa VARCHAR(50) NOT NULL,
    CNPJ CHAR(14) NOT NULL,
    ICMS DECIMAL(10,2) NOT NULL,
    ValorTotal DECIMAL(10,2) NOT NULL,
    DataNota DATE NOT NULL,
    Hora TIME NOT NULL,
    IdPedido INT NOT NULL,
    IdEndereco INT,
    IdPagamento INT NOT NULL
);

-- Definindo Foreign Keys
ALTER TABLE tbFuncionario
    ADD CONSTRAINT fk_Funcionario_Endereco FOREIGN KEY (IdEndereco) REFERENCES tbEndereco(IdEndereco);

ALTER TABLE tbCliente
    ADD CONSTRAINT fk_Cliente_Endereco FOREIGN KEY (IdEndereco) REFERENCES tbEndereco(IdEndereco);

ALTER TABLE tbPedido
    ADD CONSTRAINT fk_Pedido_Cliente FOREIGN KEY (CPFCli) REFERENCES tbCliente(CPF),
    ADD CONSTRAINT fk_Pedido_Funcionario FOREIGN KEY (CPFFun) REFERENCES tbFuncionario(CPF);

ALTER TABLE tbItemPedido
    ADD CONSTRAINT fk_ItemPedido_Produto FOREIGN KEY (IdProduto) REFERENCES tbProduto(IdProduto),
    ADD CONSTRAINT fk_ItemPedido_Pedido FOREIGN KEY (IdPedido) REFERENCES tbPedido(IdPedido);

ALTER TABLE tbPagamento
    ADD CONSTRAINT fk_Pagamento_Cliente FOREIGN KEY (CPFCli) REFERENCES tbCliente(CPF),
    ADD CONSTRAINT fk_Pagamento_Pedido FOREIGN KEY (IdPedido) REFERENCES tbPedido(IdPedido);

ALTER TABLE tbNotaFiscal
    ADD CONSTRAINT fk_NotaFiscal_Pedido FOREIGN KEY (IdPedido) REFERENCES tbPedido(IdPedido),
    ADD CONSTRAINT fk_NotaFiscal_Endereco FOREIGN KEY (IdEndereco) REFERENCES tbEndereco(IdEndereco),
    ADD CONSTRAINT fk_NotaFiscal_Pagamento FOREIGN KEY (IdPagamento) REFERENCES tbPagamento(IdPagamento);

-- Inserts
INSERT INTO tbEndereco (Logradouro, Numero, Estado, Cidade, Bairro, CEP, Complemento)
VALUES ('Av. Paulista', '1234', 'SP', 'São Paulo', 'Bela Vista', '01310900', 'Apto 101');

INSERT INTO tbFuncionario (CPF, RG, Nome, DataNans, CelularTelefone, Cargo, Sexo, Email, Senha, IdEndereco)
VALUES ('12345678901', '987654321', 'João Silva', '1990-05-15', '11987654321', 'Administrador', 'M', 'joao@email.com', SHA2('senha123', 256), 1);

INSERT INTO tbCliente (CPF, RG, Nome, DataNans, Celular, Sexo, Email, Senha, IdEndereco)
VALUES ('98765432100', '123456789', 'Maria Oliveira', '1985-08-25', '21987654321', 'F', 'maria@email.com', SHA2('senha456', 256), 1);

INSERT INTO tbProduto (Tecido, Descricao, Categoria, Cor, Quantidade, Tamanho, DescImg, Situacao, Valor)
VALUES ('ALGODAO', 'Camiseta Básica', 'Superior', 'Branco', 100, 'M', 'imagem1.png', 'Estoque', 29.99);

INSERT INTO tbPedido (DataTransito, DataEntrega, PedidoStatus, ValorTotal, CPFCli, CPFFun, Quantidade)
VALUES ('2024-11-10', '2024-11-15', 'PROCESSO', 89.99, '98765432100', '12345678901', 1);

INSERT INTO tbItemPedido (Quantidade, ValorUnit, IdProduto, IdPedido)
VALUES (3, 29.99, 1, 1);

INSERT INTO tbPagamento (DataPag, Hora, FormaPag, ValorPedido, CPFCli, IdPedido)
VALUES ('2024-11-15', '14:30:00', 'pix', 3.00, '98765432100', 1);

INSERT INTO tbNotaFiscal (CodigoVerificacao, NomeEmpresa, CNPJ, ICMS, ValorTotal, DataNota, Hora, IdPedido, IdEndereco, IdPagamento)
VALUES (987654, 'CustomClothes', '12345678000199', 7.29, 92.99, '2024-11-15', '14:45:00', 1, 1, 1);


-- Facilitar a visualização de quantidade dos produtos, nome do produto e valor do produto
CREATE VIEW vwProdutosInfo AS
SELECT 
    tbProduto.IdProduto,
    tbProduto.Descricao AS NomeProduto,
    tbProduto.Quantidade AS Quantidade,
    tbProduto.Valor AS ValorProduto
FROM 
    tbProduto;
-- Visualizar a receita total das vendas do mês atual
CREATE VIEW vwReceitaMesAtual AS
SELECT 
    SUM(tbItemPedido.Quantidade * tbItemPedido.ValorUnit) AS ReceitaTotalMesAtual
FROM 
    tbPedido
INNER JOIN 
    tbItemPedido ON tbPedido.IdPedido = tbItemPedido.IdPedido
WHERE 
    MONTH(tbPedido.DataPedido) = MONTH(CURRENT_DATE())
    AND YEAR(tbPedido.DataPedido) = YEAR(CURRENT_DATE());
-- Visualizar a receita total das vendas de cada mês
CREATE VIEW vwReceitaMensal AS
SELECT 
    MONTH(tbPedido.DataPedido) AS Mes,
    YEAR(tbPedido.DataPedido) AS Ano,
    SUM(tbItemPedido.Quantidade * tbItemPedido.ValorUnit) AS ReceitaTotal
FROM 
    tbPedido
INNER JOIN 
    tbItemPedido ON tbPedido.IdPedido = tbItemPedido.IdPedido
GROUP BY 
    YEAR(tbPedido.DataPedido), MONTH(tbPedido.DataPedido);

			
-- Tabela com ID do produto, nome do produto, cliente, data, quantia e método de pagamento
CREATE VIEW vwDetalhesPedidos AS
SELECT 
    tbProduto.IdProduto,
    tbProduto.Descricao AS NomeProduto,
    tbCliente.Nome AS NomeCliente,
    tbPedido.DataPedido,
    tbItemPedido.Quantidade AS Quantidade,
    tbPagamento.FormaPag AS MetodoPagamento
FROM 
    tbPedido
INNER JOIN 
    tbItemPedido ON tbPedido.IdPedido = tbItemPedido.IdPedido
INNER JOIN 
    tbProduto ON tbItemPedido.IdProduto = tbProduto.IdProduto
INNER JOIN 
    tbCliente ON tbPedido.CPFCli = tbCliente.CPF
INNER JOIN 
    tbPagamento ON tbPedido.IdPedido = tbPagamento.IdPedido;


-- trigger
-- restrições
-- view com iner join para nota fiscal


-- PROCEDURES DE CLIENTE
-- CADASTRAR CLIENTE
-- drop procedure pcd_CadastrarCliente;
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
CALL pcd_CadastrarCliente("5455452312", "25653687","Renata Teixeira", "2006-02-25",
 184596879, "M", "Natita@gmail.com", "1234578");

select * from tbCliente;

GRANT EXECUTE ON PROCEDURE CustomClothes.pcd_CadastrarCliente TO 'root'@'localhost';
FLUSH PRIVILEGES;

-- UPDATE CLIENTE	
 -- drop procedure pcd_AtualizarCliente;
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
call pcd_DeletarClientepcd_LoginCliente("54554512312");

-- LOGIN DE CLIENTE
DELIMITER $$
CREATE PROCEDURE pcd_LoginCliente(_Email varchar(40), _Senha varchar(20))
BEGIN 
	SELECT * FROM tbCliente WHERE Email = _Email AND Senha = _Senha;
END $$
CALL pcd_LoginCliente("Natita@gmail.com", "1234578");
GRANT EXECUTE ON PROCEDURE CustomClothes.pcd_LoginCliente TO 'root'@'localhost';
FLUSH PRIVILEGES;

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
-- Atualazando
/*select * from tbProduto;

use CustomClothes;
select * from tbCliente;*/