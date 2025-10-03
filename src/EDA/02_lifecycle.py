# %%
# LIBRARY
import os
import pandas as pd
import sqlalchemy

import matplotlib.pyplot as plt 

# %%
## PATH & OTHERS
# Project Directory
project_dir = os.path.join(os.path.expanduser("~"), "OneDrive", "Project_Code", "Project-LoyaltyPredict_2025")

# Data path
data_ls_path = os.path.join(project_dir, "data", "loyalty-system")
os.makedirs(data_ls_path, exist_ok=True)

data_ep_path = os.path.join(project_dir, "data", "education-platform")
os.makedirs(data_ep_path, exist_ok=True)

data_srcA_path = os.path.join(project_dir, "src", "analytics")
os.makedirs(data_srcA_path, exist_ok=True)

data_srcE_path = os.path.join(project_dir, "src", "EDA")
os.makedirs(data_srcE_path, exist_ok=True)

data_img_path = os.path.join(project_dir, "img")
os.makedirs(data_img_path, exist_ok=True)

data_analytics_path = os.path.join(project_dir, "data", "analytics")
os.makedirs(data_analytics_path, exist_ok=True)

# %%

## FUCNTION
# Function to import SQL query from a .sql file
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query(os.path.join(data_srcA_path, "lifecycle_desc.sql"))


db_analytical_path = os.path.join(data_analytics_path, "database.db")
engine_analytical = sqlalchemy.create_engine(f'sqlite:///{db_analytical_path}')

# %%
df = pd.read_sql_query(query, engine_analytical)

# %%
# barchart lifecycle
df_pivot = df.pivot(index='DtRef', columns='descLifeCycle', values='QtyUsers').fillna(0)
df_pivot = df_pivot.sort_index()
df_pivot.plot(kind='bar', stacked=True, figsize=(12, 6))
plt.title('User Lifecycle Stacked Bar Chart')
plt.xlabel('Date')
plt.ylabel('Number of Users')
plt.legend(title='Lifecycle Stage', bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
# Save figure before showing
plt.savefig(os.path.join(data_img_path, 'lifecycle_stacked_bar.png'), dpi=300, bbox_inches='tight')

plt.show()

# %%

# percent bar chart lifecycle
df_percent = df_pivot.div(df_pivot.sum(axis=1), axis=0) * 100
df_percent.plot(kind='bar', stacked=True, figsize=(12, 6), colormap='tab20')
plt.title('User Lifecycle Percentage Stacked Bar Chart')
plt.xlabel('Date')
plt.ylabel('Percentage of Users (%)')
plt.legend(title='Lifecycle Stage', bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()

# Save figure before showing
plt.savefig(os.path.join(data_img_path, 'lifecycle_percentage_stacked_bar.png'), dpi=300, bbox_inches='tight')

plt.show()


# %%
