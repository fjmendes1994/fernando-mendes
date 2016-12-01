-- cria tabela
DROP TABLE "funcionario" CASCADE;
DROP TABLE "falta";

CREATE TABLE "funcionario"
(
  "nome" varchar(60) NOT NULL,
  "email" varchar(60) NOT NULL,
  "sexo" varchar(10) NOT NULL,
  "ddd" numeric(2),
  "salario" money,
  "telefone" varchar(8),
  "ativo" varchar(1),
  "endereco" varchar(70) NOT NULL,
  "cpf" varchar(11) NOT NULL,
  "cidade" varchar(20) NOT NULL,
  "estado" varchar(2) NOT NULL,
  "bairro" varchar(20) NOT NULL,
  "pais" varchar(20) NOT NULL,
  "login" varchar(12) NOT NULL,
  "senha" varchar(12) NOT NULL,
  "news" varchar(8),
  "id" serial,
  UNIQUE ("id")
);
-- insere

INSERT INTO funcionario(nome, email, sexo, ddd, salario, telefone, ativo, endereco, cpf, cidade, estado, bairro, pais, login, senha, news) VALUES
('Fernando Mendes', 'fjmendes1994@hotmail.com', 'M', 21, '1300.00', '39607653', 'S', 'casa', '11314237713', 'rio de janeiro', 'RJ', 'sao cristovao', 'brasil', 'fjmendes', '1234', 'vazio');


-- função AumentarSalario
CREATE OR REPLACE FUNCTION aumenta_salario(cpf_funcionario varchar(11), porcentagem integer) RETURNS float AS $$
DECLARE
    coeficiente float DEFAULT 0;
    salario_antigo money;
    salario_novo money;

BEGIN
    coeficiente := (porcentagem/100.0)+1;

    select salario into salario_antigo
    from "funcionario" as funcionario
    where funcionario.cpf = cpf_funcionario;

    salario_novo = salario_antigo * coeficiente;

    update "funcionario"
    set salario = salario_novo
    where funcionario.cpf = cpf_funcionario;

    RETURN coeficiente;
END;
$$ LANGUAGE plpgsql;

--> chama a função
select aumenta_salario('11314237713', 50);

--> checa se aumentou
select salario
from funcionario
where funcionario.cpf = '11314237713';

--> cria table de faltas

CREATE TABLE "falta"(
  "data" date,
  "justificativa" varchar(255),
  "funcionario_fk" int references funcionario(id)
);
-->
  insert into falta(data, justificativa, funcionario_fk) values
    ('2004-05-05', 'N', '1'),
    ('2004-05-06', 'N', '1'),
    ('2004-05-07', 'N', '1');

--> dropa a funçao

DROP FUNCTION checa_falta();

--> função que checa o numero de faltas

CREATE OR REPLACE FUNCTION checa_falta() RETURNS TRIGGER AS $$
DECLARE
  numero_faltas integer;
  falta_atual record;
BEGIN
  falta_atual := NEW;

  select count (*) into numero_faltas
  from "falta"
  where "falta".justificativa = 'N'
  and funcionario_fk = falta_atual.funcionario_fk;

  IF (numero_faltas > 4) THEN
    update "funcionario"
    set ativo = 'N'
    where "funcionario".id = falta_atual.funcionario_fk;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

--> cria trigger par aa função acima

CREATE TRIGGER demite_falta AFTER INSERT ON falta
    FOR EACH ROW EXECUTE PROCEDURE checa_falta();

--> insere mais 3 faltas

insert into falta(data, justificativa, funcionario_fk) values
    ('2004-05-08', 'N', '1');
insert into falta(data, justificativa, funcionario_fk) values
    ('2004-05-09', 'N', '1');

--> teste

SELECT * FROM funcionario;
-->SELECT * FROM falta;
