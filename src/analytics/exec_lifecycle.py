# %%
## LIBRARY
import pandas as pd
import sqlalchemy

import os

# %%
## PATH
# Project Directory
project_dir = os.path.join(os.path.expanduser("~"), "OneDrive", "Project_Code", "Project-LoyaltyPredict_2025")

# Data path
data_ls_path = os.path.join(project_dir, "data", "loyalty-system")
os.makedirs(data_ls_path, exist_ok=True)

data_srcA_path = os.path.join(project_dir, "src", "analytics")
os.makedirs(data_srcA_path, exist_ok=True)

data_analytics_path = os.path.join(project_dir, "data", "analytics")
os.makedirs(data_analytics_path, exist_ok=True)

# %%
## FUCNTION
# Function to import SQL query from a .sql file
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query(os.path.join(data_srcA_path, "lifecycle.sql"))
# print(query)
print(query.format(date='2025-08-31'))

# %%
# Create SQLAlchemy engine
db_path = os.path.join(data_ls_path, "database.db")
engine_app = sqlalchemy.create_engine(f'sqlite:///{db_path}')

db_analytical_path = os.path.join(data_analytics_path, "database.db")
engine_analytical = sqlalchemy.create_engine(f'sqlite:///{db_analytical_path}')

# %%

dates = [
    '2024-04-01',
    '2024-05-01',
    '2024-06-01',
    '2024-07-01',
    '2024-08-01',
    '2024-09-01',
    '2024-10-01',
    '2024-11-01',  
    '2024-12-01',
    '2025-01-01',
    '2025-02-01',
    '2025-03-01',
    '2025-04-01',
    '2025-05-01',
    '2025-06-01',
    '2025-07-01',
    '2025-08-01',
    '2025-09-01',
    '2025-10-01'
]


# %%
for i in dates:

    with engine_analytical.connect() as conn:
        conn.execute(sqlalchemy.text(f"DELETE FROM life_cycle WHERE DtRef = DATE('{i}', '-1 day')"))
        conn.commit()

    query_format = query.format(date=i)
    df = pd.read_sql_query(query_format, engine_app)
    df.to_sql("life_cycle", engine_analytical, index=False, if_exists='append' )



# %%
