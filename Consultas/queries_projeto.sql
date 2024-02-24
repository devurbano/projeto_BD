--01º Quais são os 10 produtos mais caros em termos de preço unitário? (VALIDADO)
CREATE VIEW view_produto_mais_caro AS
SELECT
  "Codigo",
  "Produto",
  "Preco"
FROM produtos
ORDER BY "Preco" DESC
LIMIT 10;


--02º Quais são os 10 produtos mais vendidos em termos de quantidade? (VALIDADO)
CREATE VIEW view_produtos_mais_vendidos AS(
SELECT
  p."Codigo",
  p."Produto",
  SUM(v."Qty") AS "Qtd Vendida"
FROM produtos p
JOIN vendas v 
ON p."Codigo" = v."Codigo"
GROUP BY p."Codigo", p."Produto"
ORDER BY "Qtd Vendida" DESC
LIMIT 10);


--03º Quais são os 10 produtos que mais tiveram transações canceladas e qual a quantidade cancelada de cada produto?
CREATE VIEW view_transacoes_canceladas AS(
SELECT
  v."Codigo" AS "Codigo Produto",
  p."Produto",
  v."Qty" AS "Qtd Cancelada"
FROM vendas v
JOIN (
  SELECT "Codigo", "Produto"	
  FROM produtos) p
  ON v."Codigo" = p."Codigo"
WHERE v."Courier Status" = 'Cancelled'
LIMIT 10);

--04º Qual é o total de vendas (em valor) para cada país ('ship country')? (VALIDADO)
CREATE VIEW view_total_vendas_por_pais AS(
SELECT
  v."ship country" AS Country,
  ROUND(SUM(p."Preco" * v."Qty")::numeric,2)  AS "Total de Vendas"
FROM vendas v
JOIN produtos p ON v."Codigo" = p."Codigo"
GROUP BY v."ship country"
ORDER BY "Total de Vendas" DESC);

--05º Quais são os produtos que tiveram o maior valor em vendas?
CREATE VIEW view_maior_valor_total AS(
SELECT
  p."Codigo",
  p."Produto",
  (SELECT ROUND(SUM(("Preco" * "Qty")::numeric), 2) FROM vendas WHERE "Codigo" = p."Codigo") AS "Valor Total"
FROM produtos p
ORDER BY "Valor Total" DESC
LIMIT 10);

--06º Qual é o mês com o maior valor total de vendas?
SET datestyle = "ISO, MDY";
CREATE VIEW view_maior_valor_total_vendas AS(
WITH cte_valor_total_mes AS (
  SELECT
    TO_CHAR("Date"::date, 'MM') AS "Mes",
    ROUND(SUM(("Preco" * "Qty")::numeric), 2) AS "Valor Total"
  FROM "vendas"
  JOIN "produtos" ON "vendas"."Codigo" = "produtos"."Codigo"
  GROUP BY  TO_CHAR("Date"::date, 'MM')
)
SELECT
  "Mes",
  "Valor Total"
FROM cte_valor_total_mes
ORDER BY "Valor Total" DESC
LIMIT 1);



--07º Quais são os produtos que tiveram o maior número total de transações?
CREATE VIEW view_total_transações AS(
WITH cte_total_transacoes AS (
  SELECT
    p."Codigo",
    p."Produto",
    COUNT(v."Order ID") AS "Total de Transacoes"
  FROM "produtos" p
  LEFT JOIN "vendas" v ON p."Codigo" = v."Codigo"
  GROUP BY p."Codigo", p."Produto"
)

SELECT
  "Codigo",
  "Produto",
  "Total de Transacoes"
FROM cte_total_transacoes
ORDER BY "Total de Transacoes" DESC);

--08º Qual é a quantidade média de produtos vendidos por transação?
WITH cte_media_quantidade_produtos AS (
  SELECT
    "Order ID",
    AVG("Qty")  AS "Qtd Media_Produtos"
  FROM "vendas"
  GROUP BY "Order ID"
)

SELECT ROUND(AVG("Qtd Media_Produtos"),2) AS "Media Total"
FROM cte_media_quantidade_produtos;

--09º Qual seria o ticket médio destas transações?
SELECT ROUND(AVG(("Preco" * "Qty")::numeric), 2) AS "Ticket Medio"
FROM "produtos" p
JOIN "vendas" v ON p."Codigo" = v."Codigo";

--10º Ranking das regiões que tem maior número de transações?
SELECT "ship country" AS "Regiao", COUNT(*) AS "Nº Transacoes"
FROM "vendas"
GROUP BY "ship country"
ORDER BY "Nº Transacoes" DESC
LIMIT 5;

--11º Quantas transações Canceladas?
SELECT "Courier Status" AS "Tipo da transação", COUNT(*) AS "Nº Transações"
FROM "vendas"
WHERE "Courier Status" = 'Cancelled'
GROUP BY "Courier Status"
ORDER BY "Nº Transações" DESC;

--12º Qual é o dia da semana com o maior número total de transações?
WITH cte_total_transacoes_dia_semana AS (
  SELECT
    TO_CHAR("Date"::date, 'Day') AS "Dia",
    COUNT("Order ID") AS "Total Transacoes"
  FROM "vendas"
  GROUP BY "Dia"
)

SELECT
  "Dia",
  "Total Transacoes"
FROM cte_total_transacoes_dia_semana
ORDER BY "Total Transacoes" DESC
LIMIT 1;

--13º Quais são os produtos que têm a menor média de preço por unidade vendida?
WITH cte_media_preco_por_unidade AS (
  SELECT
    p."Codigo",
    p."Produto",
    round(AVG((p."Preco" / v."Qty"))::NUMERIC,2)  AS "Preco_Medio_Unitário"
  FROM "produtos" p
  JOIN "vendas" v ON p."Codigo" = v."Codigo"
  GROUP BY p."Codigo", p."Produto"
)

SELECT
  "Codigo",
  "Produto",
  "Preco_Medio_Unitário"
FROM cte_media_preco_por_unidade
ORDER BY "Preco_Medio_Unitário" ASC
LIMIT 10;

--14º Quais são os dias da semana que têm, em média, o maior número de transações?
WITH cte_media_transacoes_dia_semana AS (
  SELECT
    TO_CHAR("Date"::date, 'Day') AS "Dia",
    COUNT("Order ID") AS "Total"
  FROM
    "vendas"
  GROUP BY
    "Dia"
)

SELECT
  "Dia",
  AVG("Total") AS "Media"
FROM
  cte_media_transacoes_dia_semana
GROUP BY "Dia"
ORDER BY "Media" DESC
LIMIT 10;

--15º Quantas transações foram canceladas em cada país?
WITH cte_transacoes_canceladas_pais AS (
  SELECT
    "ship country" AS "Pais",
    COUNT("Order ID") AS "Transacoes Canceladas"
  FROM "vendas"
  WHERE "Courier Status" = 'Cancelled'
  GROUP BY "Pais"
)

SELECT
  "Pais",
  "Transacoes Canceladas"
FROM cte_transacoes_canceladas_pais;
