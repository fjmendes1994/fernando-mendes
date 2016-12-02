CREATE TABLE "PESSOA"
(
'ID_PESSOA' integer NOT NULL,
'NOME character' varying,
'LOGIN' character varying,
'SENHA' character varying,
CONSTRAINT 'PK_PESSOA' PRIMARY KEY ('ID_PESSOA')
);

CREATE TABLE "RECEITA"
(
'ID_RECEITA' integer NOT NULL,
'DATA_ENVIO' date,
'TITULO' character varying,
'MODO_PREPARO' character varying,
'ID_PESSOA' integer,
CONSTRAINT 'PK_RECEITA' PRIMARY KEY ('ID_RECEITA'),
CONSTRAINT 'FK_PESSOA' FOREIGN KEY ('ID_PESSOA') REFERENCES PESSOA ('ID_PESSOA')
ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE "INGREDIENTE"
(
'ID_INGREDIENTE' integer NOT NULL,
'DESCRICAO' character varying,
'MEDIDA' character varying,
CONSTRAINT 'PK_INGREDIENTE' PRIMARY KEY ('ID_INGREDIENTE')
);

CREATE TABLE "RECEITA_INGREDIENTE"
(
'ID_RECEITA' integer NOT NULL,
'ID_INGREDIENTE' integer NOT NULL,
'QUANTIDADE' double precision,
CONSTRAINT 'PK_INGREDIENTE_RECEITA' PRIMARY KEY ('ID_RECEITA', 'ID_INGREDIENTE'),
CONSTRAINT 'FK_INGREDIENTE' FOREIGN KEY ('ID_INGREDIENTE')
REFERENCES INGREDIENTE ('ID_INGREDIENTE') ON UPDATE NO ACTION ON DELETE NO ACTION,
CONSTRAINT 'FK_RECEITA' FOREIGN KEY ('ID_RECEITA')
REFERENCES RECEITA ('ID_RECEITA') ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE VOTACAO
(
'ID_VOTO' integer NOT NULL,
'NOTA' double precision,
'ID_PESSOA' integer,
'ID_RECEITA' integer,
CONSTRAINT 'PK_VOTO' PRIMARY KEY ('ID_VOTO'),
CONSTRAINT 'FK_PESSOA' FOREIGN KEY ('ID_PESSOA')
REFERENCES PESSOA ('ID_PESSOA') ON UPDATE NO ACTION ON DELETE NO ACTION,
CONSTRAINT 'FK_RECEITA' FOREIGN KEY ('ID_RECEITA')
REFERENCES RECEITA ('ID_RECEITA') ON UPDATE NO ACTION ON DELETE NO ACTION
);
--> insere uma pessoa

insert into pessoa values
  (1, 'fernando', 'fjmendes', '12345678');

--> insere 3 ingredientes

insert into ingrediente values
  (1, 'arroz', 'g'),
  (2, 'feijao', 'g'),
  (3, 'bife', 'u');


select insere_receita(1, 2009-04-04, 'receita', 'cozinhar', {'arroz', 'feijao', 'bife'}, {1.0, 2.0, 3.0});

--> função que insere uma nova receita
CREATE OR REPLACE FUNCTION insere_receita(id_pessoa_receita integer, data_envio_receita date, titulo_receita varchar, modo_preparo_receita varchar, ingredientes_receita varchar[], quantidade_receita float[]) RETURNS float AS $$
DECLARE
    numero_ingredientes integer;
    contador integer;
    receita integer;
BEGIN
    insert into receita(ID_RECEITA, DATA_ENVIO, TITULO, MODO_PREPARO, ID_PESSOA) values
      (1, data_envio_receita, titulo_receita, modo_preparo_receita, id_pessoa_receita);

    select array_length(ingredientes_receita, 1) into numero_ingredientes;

    select ID_RECEITA from receita into receita
    where DATA_ENVIO = data_envio_receita
    and TITULO = titulo_receita
    and MODO_PREPARO = modo_preparo_receita
    and ID_PESSOA = id_pessoa_receita;

    contador := 0;
    FOR i IN 1 .. array_upper(ingredientes_receita, 1)
    LOOP
      PERFORM insere_receita_ingrediente(receita, ingredientes_receita[i], quantidade_receita[i]);
    END LOOP;
    RETURN 1.0;
END;
$$ LANGUAGE plpgsql;

--> função auxiliar para inserir um ingrediente em um receita ( devera ser chamada na função acima dentro de um for)
CREATE OR REPLACE FUNCTION insere_receita_ingrediente(receita integer, ingrediente_desc varchar, medida float) RETURNS integer AS $$
DECLARE
    id_ingrediente_receita integer;
BEGIN
    select ID_INGREDIENTE from INGREDIENTE into id_ingrediente_receita
    where INGREDIENTE.DESCRICAO =  ingrediente_desc;

    insert into RECEITA_INGREDIENTE(ID_RECEITA, ID_INGREDIENTE, QUANTIDADE) values
      (receita, id_ingrediente_receita, medida);

    RETURN 1;
END;
$$ LANGUAGE plpgsql;

--> testa função criada

select insere_receita(1, current_date, 'receita', 'cozinhar', ARRAY['arroz', 'feijao', 'bife'], ARRAY[2.0, 1.0, 1.0]);
