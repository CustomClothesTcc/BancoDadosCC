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

INSERT INTO tbProduto (Tecido, Descricao, Categoria, Cor, Quantidade, Tamanho, DescImg, Situacao, Valor, Estampa)
VALUES ('ALGODAO', 'Camiseta Básica', 'Superior', 'Branco', 100, 'M', 'imagem1.png', 'Estoque', 29.99, "teste");

INSERT INTO tbPedido (DataTransito, DataEntrega, PedidoStatus, ValorTotal, CPFCli, CPFFun, Quantidade)
VALUES ('2024-11-10', '2024-11-15', 'PROCESSO', 89.99, '98765432100', '12345678901', 1);

INSERT INTO tbItemPedido (Quantidade, ValorUnit, IdProduto, IdPedido)
VALUES (3, 29.99, 1, 1);

INSERT INTO tbPagamento (DataPag, Hora, FormaPag, ValorPedido, CPFCli, IdPedido)
VALUES ('2024-11-15', '14:30:00', 'pix', 3.00, '98765432100', 1);

INSERT INTO tbNotaFiscal (CodigoVerificacao, NomeEmpresa, CNPJ, ICMS, ValorTotal, DataNota, Hora, IdPedido, IdEndereco, IdPagamento)
VALUES (987654, 'CustomClothes', '12345678000199', 7.29, 92.99, '2024-11-15', '14:45:00', 1, 1, 1);

-- PROCEDURES DE CLIENTE
DELIMITER $$
CREATE PROCEDURE pcd_CadastrarCliente(
    _CPF VARCHAR(11),
    _RG VARCHAR(9),
    _Nome VARCHAR(50),
    _DataNans DATE,
    _Celular VARCHAR(11),
    _Sexo CHAR(1),
    _Email VARCHAR(40),
    _Senha VARCHAR(20)
)
BEGIN
    START TRANSACTION;
    INSERT INTO tbCliente (CPF, RG, Nome, DataNans, Celular, Sexo, Email, Senha)
    VALUES (_CPF, _RG, _Nome, _DataNans, _Celular, _Sexo, _Email, _Senha);
    COMMIT;
END $$
DELIMITER ;

GRANT EXECUTE ON PROCEDURE CustomClothes.pcd_CadastrarCliente TO 'root'@'localhost';
FLUSH PRIVILEGES;

-- Atualizar Cliente
DELIMITER $$
CREATE PROCEDURE pcd_AtualizarCliente(
    _CPF VARCHAR(11),
    _RG VARCHAR(9),
    _Nome VARCHAR(50),
    _DataNans DATE,
    _Celular VARCHAR(11),
    _Sexo CHAR(1),
    _Email VARCHAR(40),
    _Senha VARCHAR(20)
)
BEGIN
    START TRANSACTION;
    UPDATE tbCliente 
    SET RG = _RG, Nome = _Nome, DataNans = _DataNans, Celular = _Celular, Sexo = _Sexo, Email = _Email, Senha = _Senha
    WHERE CPF = _CPF;
    COMMIT;
END $$
DELIMITER ;

-- Excluir Cliente
DELIMITER $$
CREATE PROCEDURE pcd_ExcluirCliente(_CPF VARCHAR(11))
BEGIN
    START TRANSACTION;
    DELETE FROM tbCliente WHERE CPF = _CPF;
    COMMIT;
END $$
DELIMITER ;

-- LOGIN DE CLIENTE
DELIMITER $$
CREATE PROCEDURE pcd_LoginCliente(_Email VARCHAR(40), _Senha VARCHAR(20))
BEGIN 
	SELECT * 
	FROM tbCliente 
	WHERE Email = _Email AND Senha = SHA2(_Senha, 256); -- Segurança aplicada na senha
END $$
DELIMITER ;

-- Chamada da procedure de login
CALL pcd_LoginCliente("Natita@gmail.com", "1234578");

-- Permissão para executar a procedure
GRANT EXECUTE ON PROCEDURE CustomClothes.pcd_LoginCliente TO 'root'@'localhost';
FLUSH PRIVILEGES;

-- OBTER CLIENTE POR CPF
DELIMITER $$
CREATE PROCEDURE pcd_ExibirCliente(_CPF VARCHAR(11))
BEGIN 
	SELECT * 
	FROM tbCliente 
	WHERE CPF = _CPF;
END $$
DELIMITER ;

-- Chamada da procedure para obter cliente por CPF
CALL pcd_ExibirCliente("54554512312");

-- OBTER CLIENTE POR NOME
DELIMITER $$
CREATE PROCEDURE pcd_ExibirCliente_Nome(_Nome VARCHAR(50))
BEGIN 
	SELECT * 
	FROM tbCliente 
	WHERE Nome = _Nome;
END $$
DELIMITER ;

-- Chamada da procedure para obter cliente por Nome
CALL pcd_ExibirCliente_Nome("Renata Teixeira");
