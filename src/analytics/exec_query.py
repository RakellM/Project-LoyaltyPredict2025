# %%
## LIBRARY
import pandas as pd
import sqlalchemy
import os
import datetime
from tqdm import tqdm
import argparse

# %%
## PATH
# Project Directory
project_dir = os.path.join(os.path.expanduser("~"), "OneDrive", "Project_Code", "Project-LoyaltyPredict_2025")

# Data path
data_path = os.path.join(project_dir, "data")
os.makedirs(data_path, exist_ok=True)

# %%
## FUCNTION
# Function to import SQL query from a .sql file
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

## FUNCTION
# Function to create a date range list
def date_range(start, stop, monthly=False):
    dates = []
    while start <= stop:
        dates.append(start)
        dt_start = datetime.datetime.strptime(start, '%Y-%m-%d') + datetime.timedelta(days=1)
        start = datetime.datetime.strftime(dt_start, '%Y-%m-%d')

    if monthly:
        return [i for i in dates if i.endswith("01")]
    
    return dates


# Create SQLAlchemy engine
def exec_query(table, database_origin, database_target, dt_start, dt_stop, monthly):
    engine_app = sqlalchemy.create_engine(f'sqlite:///{data_path}/{database_origin}/database.db')
    engine_analytical =  sqlalchemy.create_engine(f'sqlite:///{data_path}/{database_target}/database.db')

    query = import_query(f"{project_dir}/src/analytics/{table}.sql")
    # print(query)

    dates = date_range(dt_start, dt_stop, monthly)

    for i in tqdm(dates):

        try:
            with engine_analytical.connect() as conn:
                query_delete = f"DELETE FROM {table} WHERE DtRef = DATE('{i}', '-1 day')"
                # print(query_delete)
                conn.execute(sqlalchemy.text(query_delete))
                conn.commit()
        except Exception as err:
            print(f"An error occurred: {err}")

        query_format = query.format(date=i)
        df = pd.read_sql_query(query_format, engine_app)
        df.to_sql(table, engine_analytical, index=False, if_exists='append' )

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("--db_origin", choices=['loyalty_system', 'education-platform', 'analytics'], default='loyalty-system')
    parser.add_argument("--db_target", choices=['analytics'], default='analytics')
    parser.add_argument("--table", type=str, help="Table that will be processed with same name as file.")
        
    now = datetime.datetime.now().strftime("%Y-%m-%d")
    parser.add_argument("--start", type=str, default=now)
    parser.add_argument("--stop", type=str, default=now)
    parser.add_argument("--monthly", action='store_true')
    args = parser.parse_args()

    exec_query(args.table, args.db_origin, args.db_target, args.start, args.stop, args.monthly)


if __name__ == "__main__":
    main()
