# Instalar as bibliotecas : pandas sqlalchemy e psycopg2-binary
# pip install pandas sqlalchemy psycopg2-binary

import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

# cria uma conexão com o banco postgres
# string de conexão: postgresql://usuário:senha@localhost:5432/nomebanco
senha = 'postgres@24'
senha_codificada = quote_plus(senha)

engine = create_engine(f'postgresql://postgres:{senha_codificada}@localhost:5432/ecommerce')

for file_name in ["produtos.csv", "vendas.csv"]:
	df = pd.read_csv(file_name, sep=',')
	df = df.loc[:, ~df.columns.str.contains('^Unnamed')].copy()

	# salva o dataframe como tabela no banco conectado
	# nome_da_tabela, engine de conexão
	df.to_sql(f'{file_name.split(".")[0]}', engine, index=False)

