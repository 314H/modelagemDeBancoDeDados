/*Tabela de cliente
    - A chave primaria � um n�mero para melhorar a efici�ncia das buscas 
    - CK_NATUREZA garante que o cliente sempre ser� f�sico ou jur�dico*/
CREATE TABLE CLIENTE (
    CODIGO NUMBER(10) NOT NULL,
    NATUREZA VARCHAR2(8) NOT NULL,
    EMAIL VARCHAR2(30),
    TELEFONE NUMBER(11), 
    
    CONSTRAINT PK_CLIENTE PRIMARY KEY(CODIGO),
    CONSTRAINT CK_NATUREZA CHECK(UPPER(NATUREZA) IN ('FISICO', 'JURIDICO'))   
);

/*Tabela de cliente f�sico
    - O CPF deve ficar no formato real (com pontos e tra�o) ao inv�s de somente n�meros*/
CREATE TABLE CLIENTE_FISICO (
    NOME VARCHAR2(50) NOT NULL,
    CPF CHAR(14) NOT NULL,
    CODIGO NUMBER(10) NOT NULL,
    
    CONSTRAINT PK_CLIENTE_FISICO PRIMARY KEY(CPF),
    CONSTRAINT UN_CLIENTE_FISICO UNIQUE(CODIGO),
    CONSTRAINT CK_CPF_CLIENTE_FISICO CHECK(REGEXP_LIKE(CPF, '[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9]{2}')),
    CONSTRAINT FK_CLIENTE_FISICO FOREIGN KEY(CODIGO) 
        REFERENCES CLIENTE(CODIGO) ON DELETE CASCADE
);

/*Tabela de representante do cliente jur�dico
    - O CPF deve ficar no formato real (com pontos e tra�o) ao inv�s de somente n�meros */
CREATE TABLE REPRESENTANTE (
    CPF CHAR(14) NOT NULL, 
    NOME VARCHAR2(50) NOT NULL,
    
    CONSTRAINT CK_CPF_REPRESENTANTE CHECK(REGEXP_LIKE(CPF, '[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9]{2}')),
    CONSTRAINT PK_REPRESENTANTE PRIMARY KEY(CPF)
);

/*Tabela de cliente jur�dico*/
CREATE TABLE CLIENTE_JURIDICO (
    /*FORMATO DE CNPJ XX.XXX.XXX/YYYY-ZZ */
    CNPJ CHAR(18) NOT NULL,
    RAZAO_SOCIAL VARCHAR2(50) NOT NULL,
    NOME_FANTASIA VARCHAR2(50),
    REPRESENTANTE CHAR(14) NOT NULL,
    CODIGO NUMBER(10) NOT NULL,
    
    CONSTRAINT PK_CLIENTE_JURIDICO PRIMARY KEY(CNPJ),
    CONSTRAINT UN_CLIENTE_JURIDICO UNIQUE(CODIGO),
    CONSTRAINT CK_CNPJ_CLIENTE_JURIDICO CHECK(REGEXP_LIKE(CNPJ, '[0-9]{2}\.[0-9]{3}\.[0-9]{3}\/[0-9]{4}\-[0-9]{2}')),
    CONSTRAINT FK_CLIENTEJURIDICO_CLIENTE FOREIGN KEY(CODIGO) 
        REFERENCES CLIENTE(CODIGO) ON DELETE CASCADE, 
    CONSTRAINT FK_CLIENTEJURIDICO_REP FOREIGN KEY(REPRESENTANTE) 
        REFERENCES REPRESENTANTE(CPF) ON DELETE CASCADE
);

/*Tabela com os formandos*/
CREATE TABLE FORMANDO (
    CPF CHAR(14) NOT NULL, 
    NOME VARCHAR2(50) NOT NULL,
    
    CONSTRAINT CK_CPF_FORMANDO CHECK(REGEXP_LIKE(CPF, '[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9]{2}')),
    CONSTRAINT PK_FORMANDO PRIMARY KEY(CPF)   
);

/*Tabela dos funcionarios
    - os dados banc�rios (banco, agencia e numero) foram mantidos como tipo number para se adaptar a suas diferentes formata��es*/
CREATE TABLE FUNCIONARIO (
    CPF CHAR(14) NOT NULL, 
    NOME VARCHAR2(50) NOT NULL,
    EMAIL VARCHAR2(30),
    TELEFONE NUMBER(11),
    SALARIO NUMBER(10 , 2),
    BANCO NUMBER(3),
    AGENCIA NUMBER(8),  
    NUMERO NUMBER(10),
    ENDERECO VARCHAR2(70),
    CARGO VARCHAR2(10),
    
    CONSTRAINT PK_FUNCIONARIO PRIMARY KEY(CPF), 
    CONSTRAINT CK_CPF_FUNCIONARIO CHECK(REGEXP_LIKE(CPF, '[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9]{2}'))    
);

/*Tabela com os funcion�tios do tipo Supervisor*/
CREATE TABLE SUPERVISOR (
    CPF CHAR(14) NOT NULL,
    
    CONSTRAINT PK_SUPERVISOR PRIMARY KEY(CPF), 
    CONSTRAINT FK_SUPERVISOR FOREIGN KEY(CPF) 
        REFERENCES FUNCIONARIO(CPF) ON DELETE CASCADE
);

/*Tabela com os funcion�rios do tipo Vendedor*/
CREATE TABLE VENDEDOR (
    CPF CHAR(14) NOT NULL,
    
    CONSTRAINT PK_VENDEDOR PRIMARY KEY(CPF), 
    CONSTRAINT FK_VENDEDOR FOREIGN KEY(CPF) 
        REFERENCES FUNCIONARIO(CPF) ON DELETE CASCADE
);

/*Tabela com os locais de festa
    - Consideramos que CEP + n�mero  do local servem como chave prim�ria
    - O CEP � armazenado no formato XXXXX-XXX*/
CREATE TABLE LOCAL (
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER(5) NOT NULL,
    NOME VARCHAR2(50),
    CAPACIDADE NUMBER(5),
    EMAIL VARCHAR2(30),
    TELEFONE NUMBER(11),
    
    CONSTRAINT PK_LOCAL PRIMARY KEY(CEP, NUMERO),
    CONSTRAINT CK_CEP_LOCAL CHECK(REGEXP_LIKE(CEP, '[0-9]{5}\-[0-9]{3}'))
);

/*Tabela comas fotos dos locais
    - Foi decidido armazenar somente o caminho das fotos ao inv�s de utilizar blobs, assim garantindo maior efici�ncia ao banco, pois os blobs ocupariam muito espa�o*/
CREATE TABLE FOTO (
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER(5) NOT NULL,
    FOTO VARCHAR2(1000) NOT NULL,
    ID NUMBER(3) NOT NULL,
    
    CONSTRAINT PK_FOTO PRIMARY KEY(CEP, NUMERO, ID),
    CONSTRAINT FK_FOTO FOREIGN KEY(CEP, NUMERO) 
        REFERENCES LOCAL(CEP, NUMERO) ON DELETE CASCADE   
);

/*Tabela com as festas
    - Foi decidido criar um codigo num�rico para cada festa para garantir efici�ncia ao banco
    - A nota fiscal do local tamb�m � identificadora da festa
    - CEP + N�mero do local + data e hora da festa tamb�m identificam uma festa
    - Dura��o est� como number pois armazena os minutos*/
CREATE TABLE FESTA(
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER(5) NOT NULL,
    DATA_HORA DATE NOT NULL,
    TIPO VARCHAR2(11),
    NRO_CONVIDADOS NUMBER(5),
    DURACAO NUMBER(4),
    /* PORCENTAGEM DE LUCRO QUE A ASSESSORIA OBTÉM DE UMA DETERMINADA FESTA */
    LUCRO NUMBER(5, 2),
    NF_LOCAL VARCHAR2(30) NOT NULL,
    PRECO_LOCAL NUMBER(15, 2),
    CODIGO NUMBER(10) NOT NULL,
    
    CONSTRAINT PK_FESTA PRIMARY KEY(CODIGO),
    CONSTRAINT UN_FESTA2 UNIQUE(CEP, NUMERO, DATA_HORA),
    CONSTRAINT UN_FESTA3 UNIQUE(NF_LOCAL),
    CONSTRAINT FK_FESTA FOREIGN KEY(CEP, NUMERO) 
        REFERENCES LOCAL(CEP, NUMERO) ON DELETE CASCADE 
);

/*Tabela com algumas informa��es referentes a uma festa de anivers�rio infantil, como nome do aniversariante, sua idade e o tema principal da festa*/
CREATE TABLE ANIVERSARIO(
    FESTA NUMBER(10) NOT NULL,
    NOME VARCHAR2(50),
    IDADE NUMBER(3),
    TEMA VARCHAR2(30),
    
    CONSTRAINT PK_ANIVERSARIO PRIMARY KEY(FESTA),
    CONSTRAINT FK_ANIVERSARIO FOREIGN KEY(FESTA) 
        REFERENCES FESTA(CODIGO) ON DELETE CASCADE 
);

/*Tabela com algumas informa��es referentes a uma festa de formatura, como o nome da escola, a turma que est� se formando e o pre�o unit�rio do convite*/
CREATE TABLE FORMATURA(
    FESTA NUMBER(10) NOT NULL,
    ESCOLA VARCHAR2(50),
    TURMA VARCHAR2(30),
    PRECO_CONVITE NUMBER(5, 2),
    
    CONSTRAINT PK_FORMATURA PRIMARY KEY(FESTA), 
    CONSTRAINT CK_PRECO_CONVITE CHECK(PRECO_CONVITE >= 0),
    CONSTRAINT FK_FORMATURA FOREIGN KEY(FESTA) 
        REFERENCES FESTA(CODIGO) ON DELETE CASCADE    
);

/*Tabela que associa um formando a convites que ele comprou*/
CREATE TABLE COMPRA_CONVITE(
    FORMATURA NUMBER(10) NOT NULL,
    FORMANDO CHAR(14) NOT NULL,
    QUANTIDADE NUMBER(5) NOT NULL,
    NF VARCHAR2(30) NOT NULL,
    
    CONSTRAINT PK_COMPRA_CONVITE PRIMARY KEY(NF),
    CONSTRAINT CK_QUANTIDADE CHECK(QUANTIDADE > 0),
    CONSTRAINT FK_COMPRA_CONVITE_FORMATURA FOREIGN KEY(FORMATURA) 
        REFERENCES FORMATURA(FESTA) ON DELETE CASCADE,
    CONSTRAINT FK_COMPRA_CONVITE_FORMANDO FOREIGN KEY(FORMANDO)
        REFERENCES FORMANDO(CPF) ON DELETE CASCADE
);

/*Tabela que indica o fechamento de neg�cio entre um cliente e um vendedor, estabelecendo um contrato*/
CREATE TABLE CONTRATO (
    FESTA NUMBER(10) NOT NULL,
    VENDEDOR CHAR(14) NOT NULL,
    CLIENTE NUMBER(10) NOT NULL,
    NOTA_FISCAL VARCHAR2(30) NOT NULL,
    PRECO NUMBER(10, 2) NOT NULL,
    DATA DATE NOT NULL,
    
    CONSTRAINT UN_CONTRATO UNIQUE(NOTA_FISCAL),
    CONSTRAINT PK_CONTRATO PRIMARY KEY(FESTA),
    CONSTRAINT FK_CONTRATO_VENDEDOR FOREIGN KEY(VENDEDOR) 
        REFERENCES VENDEDOR(CPF) ON DELETE CASCADE,
    CONSTRAINT FK_CONTRATO_CLIENTE FOREIGN KEY(CLIENTE) 
        REFERENCES CLIENTE(CODIGO) ON DELETE CASCADE,
    CONSTRAINT FK_CONTRATO_FESTA FOREIGN KEY(FESTA) 
        REFERENCES FESTA(CODIGO) ON DELETE CASCADE    
);

/*Tabela contendo as festas em que cada supervisor trabalha*/
CREATE TABLE SUPERVISIONA (
    SUPERVISOR CHAR(14) NOT NULL,
    FESTA NUMBER(10) NOT NULL,
    
    CONSTRAINT PK_SUPERVISIONA PRIMARY KEY(SUPERVISOR, FESTA),
    CONSTRAINT FK_SUPERVISIONA_SUPERVISOR FOREIGN KEY(SUPERVISOR) 
        REFERENCES SUPERVISOR(CPF) ON DELETE CASCADE,
    CONSTRAINT FK_SUPERVISIONA_FESTA FOREIGN KEY(FESTA) 
        REFERENCES FESTA(CODIGO) ON DELETE CASCADE
);

/*Tabela contendo todos os fornecedores e o tipo a que pertencem*/
CREATE TABLE TIPO_FORNECEDOR(
    CNPJ CHAR(18) NOT NULL,
    TIPO_FORNECEDOR VARCHAR2(9) NOT NULL,

    CONSTRAINT PK_TIPO_FORNECEDOR PRIMARY KEY(CNPJ),
    CONSTRAINT CK_CNPJ_TIPOFORNECEDOR CHECK(REGEXP_LIKE(CNPJ, '[0-9]{2}\.[0-9]{3}\.[0-9]{3}\/[0-9]{4}\-[0-9]{2}')),   
    CONSTRAINT CK_TIPO_FORNECEDOR CHECK(UPPER(TIPO_FORNECEDOR) IN ('GERAL', 'FORMATURA', 'INFANTIL'))   
);

/*In�cio dos fornecedores gerais*/
/*Tabela com as empresas que podem fornecer seus produtos ou servi�os a diversos tipos de festa*/
CREATE TABLE FORNECEDOR_GERAL(
    CNPJ CHAR(18) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    EMAIL VARCHAR2(30),
    TELEFONE NUMBER(11),
    DESCRICAO VARCHAR2(500),
    TIPO_GERAL VARCHAR2(20),
    
    CONSTRAINT PK_FORNECEDOR_GERAL PRIMARY KEY(CNPJ),
    CONSTRAINT FK_FORNECEDOR_GERAL FOREIGN KEY(CNPJ)
        REFERENCES TIPO_FORNECEDOR(CNPJ) ON DELETE CASCADE
);

/*Tabela com os fornecedores de decora��o*/
CREATE TABLE DECORACAO(
    CNPJ CHAR(18) NOT NULL,
    
    CONSTRAINT PK_DECORACAO PRIMARY KEY(CNPJ),
    CONSTRAINT FK_DECORACAO FOREIGN KEY(CNPJ)
        REFERENCES FORNECEDOR_GERAL(CNPJ) ON DELETE CASCADE
);

/*Tabela com os temas de decora��o que uma empresa fornece*/
CREATE TABLE TEMA(
    CNPJ CHAR(18) NOT NULL,
    TEMA VARCHAR2(20) NOT NULL,
    
    CONSTRAINT PK_TEMA PRIMARY KEY(CNPJ, TEMA),
    CONSTRAINT FK_TEMA FOREIGN KEY(CNPJ)
        REFERENCES DECORACAO(CNPJ) ON DELETE CASCADE
);

/*Tabela com as empresas que oferecem servi�o de buffet*/
CREATE TABLE BUFFET(
    CNPJ CHAR(18) NOT NULL,
    
    CONSTRAINT PK_BUFFET PRIMARY KEY(CNPJ),
    CONSTRAINT FK_BUFFET FOREIGN KEY(CNPJ)
        REFERENCES FORNECEDOR_GERAL(CNPJ) ON DELETE CASCADE
);

/*Tabela com os pratos fornecidos por um buffet*/
CREATE TABLE COMIDA(
    CNPJ CHAR(18) NOT NULL,
    PRATO VARCHAR2(20) NOT NULL,
    
    CONSTRAINT PK_COMIDA PRIMARY KEY(CNPJ, PRATO),
    CONSTRAINT FK_COMIDA FOREIGN KEY(CNPJ)
        REFERENCES BUFFET(CNPJ) ON DELETE CASCADE
);

/*Tabela com as bebidas fornecidas por um buffet*/
CREATE TABLE BEBIDA(
    CNPJ CHAR(18) NOT NULL,
    BEBIDA VARCHAR2(20) NOT NULL,
    
    CONSTRAINT PK_BEBIDA PRIMARY KEY(CNPJ, BEBIDA),
    CONSTRAINT FK_BEBIDA FOREIGN KEY(CNPJ)
        REFERENCES BUFFET(CNPJ) ON DELETE CASCADE
);

/*Fim dos fornecedores gerais*/

/*In�cio dos fornecedores de anivers�rio infantil*/
/*Tabela com os fornecedores espec�ficos para festas infantis*/
CREATE TABLE FORNECEDOR_INFANTIL(
    CNPJ CHAR(18) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    EMAIL VARCHAR2(30),
    TELEFONE NUMBER(11),
    DESCRICAO VARCHAR2(500),
    TIPO_INFANTIL VARCHAR2(21),
    
    CONSTRAINT PK_FORNECEDOR_INFANTIL PRIMARY KEY(CNPJ),
    CONSTRAINT FK_FORNECEDOR_INFANTIL FOREIGN KEY(CNPJ)
        REFERENCES TIPO_FORNECEDOR(CNPJ) ON DELETE CASCADE    
);

/*Tabela com os fornecedores de brinquedos*/
CREATE TABLE FORNECEDOR_BRINQUEDOS(
    CNPJ CHAR(18) NOT NULL,
    
    CONSTRAINT PK_FORNECEDOR_BRINQUEDOS PRIMARY KEY(CNPJ),
    CONSTRAINT FK_FORNECEDOR_BRINQUEDOS FOREIGN KEY(CNPJ)
        REFERENCES FORNECEDOR_INFANTIL(CNPJ) ON DELETE CASCADE
);

/*Tabela com os brinquedos oferecidos por um fornecedor com a idade recomendada m�nima*/
CREATE TABLE BRINQUEDO(
    CNPJ CHAR(18) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    IDADE_RECOMENDADA NUMBER(3),
    
    CONSTRAINT PK_BRINQUEDO PRIMARY KEY(CNPJ, NOME),
    CONSTRAINT FK_BRINQUEDO FOREIGN KEY(CNPJ)
        REFERENCES FORNECEDOR_BRINQUEDOS(CNPJ) ON DELETE CASCADE
);

/*Tabela com os caminhos para fotos de um brinquedo*/
CREATE TABLE FOTO_BRINQUEDO(
    CNPJ CHAR(18) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    FOTO VARCHAR2(1000) NOT NULL,
    ID NUMBER(3) NOT NULL,
    
    CONSTRAINT PK_FOTO_BRINQUEDO PRIMARY KEY(CNPJ, NOME, ID),
    CONSTRAINT FK_FOTO_BRINQUEDO FOREIGN KEY(CNPJ, NOME)
        REFERENCES BRINQUEDO(CNPJ, NOME) ON DELETE CASCADE   
);

/*Tabela com as docerias para as festas infantis*/
CREATE TABLE DOCERIA(
    CNPJ CHAR(18) NOT NULL,
    
    CONSTRAINT PK_DOCERIA PRIMARY KEY(CNPJ),
    CONSTRAINT FK_DOCERIA FOREIGN KEY(CNPJ)
        REFERENCES FORNECEDOR_INFANTIL(CNPJ) ON DELETE CASCADE
);

/*Tabela com os bolos oferecidos por uma doceria*/
CREATE TABLE BOLOS(
    CNPJ CHAR(18) NOT NULL,
    SABOR VARCHAR2(50) NOT NULL,
    
    CONSTRAINT PK_BOLOS PRIMARY KEY(CNPJ, SABOR),
    CONSTRAINT FK_BOLOS FOREIGN KEY(CNPJ)
        REFERENCES DOCERIA(CNPJ) ON DELETE CASCADE
);

/*Tabela com os doces oferecidos por uma doceria*/
CREATE TABLE DOCES(
    CNPJ CHAR(18) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    
    CONSTRAINT PK_DOCES PRIMARY KEY(CNPJ, NOME),
    CONSTRAINT FK_DOCES FOREIGN KEY(CNPJ)
        REFERENCES DOCERIA(CNPJ) ON DELETE CASCADE
);

/*Fim dos fornecedores infantis*/

/*Inicio dos fornecedores de formatura*/
/*Tabela com os fornecedores espec�ficos de formaturas*/
CREATE TABLE FORNECEDOR_FORMATURA(
    CNPJ CHAR(18) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    EMAIL VARCHAR2(30),
    TELEFONE NUMBER(11),
    DESCRICAO VARCHAR2(500),
    TIPO_FORMATURA VARCHAR2(16),
    
    CONSTRAINT PK_FORNECEDOR_FORMATURA PRIMARY KEY(CNPJ),
    CONSTRAINT FK_FORNECEDOR_FORMATURA FOREIGN KEY(CNPJ)
        REFERENCES TIPO_FORNECEDOR(CNPJ) ON DELETE CASCADE    
);

/*Tabela com os fornecedores de bebidas*/
CREATE TABLE BEBIDA_ALCOOLICA(
    CNPJ CHAR(18) NOT NULL,
    
    CONSTRAINT PK_BEBIDA_ALCOOLICA PRIMARY KEY(CNPJ),
    CONSTRAINT FK_BEBIDA_ALCOOLICA FOREIGN KEY(CNPJ)
        REFERENCES FORNECEDOR_FORMATURA(CNPJ) ON DELETE CASCADE
);

/* Tabela com as marcas oferecidas por um fornecedor de bebidas*/
CREATE TABLE MARCAS(
    CNPJ CHAR(18) NOT NULL,
    MARCA VARCHAR2(50) NOT NULL,
    
    CONSTRAINT PK_MARCAS PRIMARY KEY(CNPJ, MARCA),
    CONSTRAINT FK_MARCAS FOREIGN KEY(CNPJ)
        REFERENCES BEBIDA_ALCOOLICA(CNPJ) ON DELETE CASCADE
);

/*Tabela com as bandas dispon�veis para formatura*/
CREATE TABLE BANDA(
    CNPJ CHAR(18) NOT NULL,
    
    CONSTRAINT PK_BANDA PRIMARY KEY(CNPJ),
    CONSTRAINT FK_BANDA FOREIGN KEY(CNPJ)
        REFERENCES FORNECEDOR_FORMATURA(CNPJ) ON DELETE CASCADE
);

/*Tabela com os g�neros de m�sica oferecidos por uma banda*/
CREATE TABLE GENEROS(
    CNPJ CHAR(18) NOT NULL,
    GENERO VARCHAR2(50) NOT NULL,
    
    CONSTRAINT PK_GENEROS PRIMARY KEY(CNPJ, GENERO),
    CONSTRAINT FK_GENEROS FOREIGN KEY(CNPJ)
        REFERENCES BANDA(CNPJ) ON DELETE CASCADE
);

/*Tabela com o compromisso de um fornecedor geral com uma festa */
CREATE TABLE FORNECE(
    FORNECEDOR_GERAL CHAR(18) NOT NULL,
    FESTA NUMBER(10) NOT NULL,
    NF VARCHAR2(30) NOT NULL,
    
    CONSTRAINT PK_FORNECE PRIMARY KEY(FORNECEDOR_GERAL, FESTA),
    CONSTRAINT UN_FORNECE UNIQUE(NF),
    CONSTRAINT FK_FORNECE FOREIGN KEY(FORNECEDOR_GERAL) 
        REFERENCES FORNECEDOR_GERAL(CNPJ) ON DELETE CASCADE,  
    CONSTRAINT FK_FORNECE_FESTA FOREIGN KEY(FESTA) 
        REFERENCES FESTA(CODIGO) ON DELETE CASCADE 
);

/*Tabela com o que est� sendo oferecido por um fornecedor geral para uma festa*/
CREATE TABLE ITEM_FORNECE(
    FORNECEDOR_GERAL CHAR(18) NOT NULL,
    FESTA NUMBER(10) NOT NULL,
    NOME VARCHAR2(30) NOT NULL,
    QUANTIDADE NUMBER(5) NOT NULL,
    PRECO NUMBER(10, 2) NOT NULL,
    
    CONSTRAINT PK_ITEM_FORNECE PRIMARY KEY(FORNECEDOR_GERAL, FESTA, NOME),
    CONSTRAINT CK_QUANTIDADE_ITEMFORNECE CHECK(QUANTIDADE > 0),
    CONSTRAINT CK_PRECO_ITEMFORNECE CHECK(PRECO >= 0),
    CONSTRAINT FK_ITEM_FORNECE FOREIGN KEY(FORNECEDOR_GERAL, FESTA) 
        REFERENCES FORNECE(FORNECEDOR_GERAL, FESTA) ON DELETE CASCADE 
);

/*Tabela com o compromisso de um fornecedor infantil com uma festa de anivers�rio */
CREATE TABLE ANIMA_ANIVERSARIO(
    ANIVERSARIO NUMBER(10) NOT NULL,
    ATRACAO_INFANTIL CHAR(18) NOT NULL,
    NF VARCHAR2(30) NOT NULL,
    
    CONSTRAINT PK_ANIMA_ANIVERSARIO PRIMARY KEY(ANIVERSARIO, ATRACAO_INFANTIL),
    CONSTRAINT UN_ANIMA_ANIVERSARIO UNIQUE(NF),
    CONSTRAINT FK_ANIMAANIVER_FORNINFANTIL FOREIGN KEY(ATRACAO_INFANTIL) 
        REFERENCES FORNECEDOR_INFANTIL(CNPJ) ON DELETE CASCADE,
    CONSTRAINT FK_ANIMAANIVER_ANIVERSARIO FOREIGN KEY(ANIVERSARIO) 
        REFERENCES ANIVERSARIO(FESTA) ON DELETE CASCADE   
);

/*Tabela com o que est� sendo oferecido por um fornecedor infantil para uma festa de anivers�rio*/
CREATE TABLE ITEM_ANIVERSARIO(
    ANIVERSARIO NUMBER(10) NOT NULL, 
    ATRACAO_INFANTIL CHAR(18) NOT NULL,
    NOME VARCHAR2(30) NOT NULL,
    QUANTIDADE NUMBER(5) NOT NULL,
    PRECO NUMBER(10, 2) NOT NULL,
    
    CONSTRAINT PK_ITEM_ANIVERSARIO PRIMARY KEY(ANIVERSARIO, ATRACAO_INFANTIL, NOME),
    CONSTRAINT CK_QUANTIDADE_ITEMANIVERSARIO CHECK(QUANTIDADE > 0),
    CONSTRAINT CK_PRECO_ITEMANIVERSARIO CHECK(PRECO >= 0),
    CONSTRAINT FK_ITEM_ANIVERSARIO FOREIGN KEY(ANIVERSARIO, ATRACAO_INFANTIL) 
        REFERENCES ANIMA_ANIVERSARIO(ANIVERSARIO, ATRACAO_INFANTIL) ON DELETE CASCADE 
);

/*Tabela com o compromisso de um fornecedor de formatura com uma festa de formatura */
CREATE TABLE ANIMA_FORMATURA(
    FORMATURA NUMBER(10) NOT NULL,
    ATRACAO_FORMATURA CHAR(18) NOT NULL,
    NF VARCHAR2(30) NOT NULL,
    
    CONSTRAINT PK_ANIMA_FORMATURA PRIMARY KEY(FORMATURA, ATRACAO_FORMATURA),
    CONSTRAINT UN_ANIMA_FORMATURA UNIQUE(NF),
    CONSTRAINT FK_ANIMAFORM_FORNFORMATURA FOREIGN KEY(ATRACAO_FORMATURA) 
        REFERENCES FORNECEDOR_FORMATURA(CNPJ) ON DELETE CASCADE,
    CONSTRAINT FK_ANIMAFORM_FORMATURA FOREIGN KEY(FORMATURA) 
        REFERENCES FORMATURA(FESTA) ON DELETE CASCADE 
);

/*Tabela com o que est� sendo oferecido por um fornecedor de formatura para uma festa de formatura*/
CREATE TABLE ITEM_FORMATURA(
    FORMATURA NUMBER(10) NOT NULL, 
    ATRACAO_FORMATURA CHAR(18) NOT NULL,
    NOME VARCHAR2(30) NOT NULL,
    QUANTIDADE NUMBER(5) NOT NULL,
    PRECO NUMBER(10, 2) NOT NULL,
    
    CONSTRAINT PK_ITEM_FORMATURA PRIMARY KEY(FORMATURA, ATRACAO_FORMATURA, NOME),
    CONSTRAINT CK_QUANTIDADE_ITEMFORMATURA CHECK(QUANTIDADE > 0),
    CONSTRAINT CK_PRECO_ITEMFORMATURA CHECK(PRECO >= 0),
    CONSTRAINT FK_ITEM_FORMATURA FOREIGN KEY(FORMATURA, ATRACAO_FORMATURA) 
        REFERENCES ANIMA_FORMATURA(FORMATURA, ATRACAO_FORMATURA) ON DELETE CASCADE 
);
