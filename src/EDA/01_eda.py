# %%
# LIBRARY
import os
import pandas as pd
from sqlalchemy import create_engine

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


# %%
# Create SQLAlchemy engine
db_path = os.path.join(data_ls_path, "database.db")
engine = create_engine(f'sqlite:///{db_path}')

# Read SQL from file and execute query
with open(os.path.join(data_srcA_path, "dau.sql"), 'r') as file:
    sql_query = file.read()

df_dau = pd.read_sql_query(sql_query, engine)

# Close the connection
engine.dispose()

# %%
df_dau.head()

# %%
# Chart DAU
plt.figure(figsize=(12, 6))
plt.plot(df_dau['DtDay'], df_dau['DAU'], marker='o')
plt.title('Daily Active Users (DAU) Over Time')
plt.xlabel('Date')
plt.ylabel('DAU')
plt.grid(True, alpha=0.3)

# Show every nth label
n = 7
plt.xticks(ticks=df_dau['DtDay'][::n], labels=df_dau['DtDay'][::n], rotation=90, size=8)
plt.tight_layout()

# Save figure before showing
plt.savefig(os.path.join(data_img_path, 'dau_over_time.png'), dpi=300, bbox_inches='tight')

plt.show()

# %%
# Read SQL from file and execute query
with open(os.path.join(data_srcA_path, "mau.sql"), 'r') as file:
    sql_query = file.read()

df_mau = pd.read_sql_query(sql_query, engine)

# Close the connection
engine.dispose()

# %%
# Chart MAU
plt.figure(figsize=(10, 6))
plt.plot(df_mau['DtMonth'], df_mau['MAU'], marker='o')
plt.title('Monthly Active Users (MAU) Over Time')
plt.xlabel('YearMonth')
plt.ylabel('MAU')
plt.grid(True, alpha=0.3)
plt.xticks(rotation=90, size=10)
plt.tight_layout()

# Save figure before showing
plt.savefig(os.path.join(data_img_path, 'mau_over_time.png'), dpi=300, bbox_inches='tight')

plt.show()

# %%
# Read SQL from file and execute query
with open(os.path.join(data_srcA_path, "mau_28days.sql"), 'r') as file:
    sql_query = file.read()

df_mau28 = pd.read_sql_query(sql_query, engine)

# Close the connection
engine.dispose()

# %%
# Chart MAU
plt.figure(figsize=(12, 6))
plt.plot(df_mau28['DtRef'], df_mau28['MAU'], marker='o')
plt.title('Active Users (MAU 28 days) Over Time')
plt.xlabel('Date')
plt.ylabel('MAU')
plt.grid(True, alpha=0.3)
# Show every nth label
n = 7
plt.xticks(ticks=df_dau['DtDay'][::n], labels=df_dau['DtDay'][::n], rotation=90, size=8)
plt.tight_layout()

# Save figure before showing
plt.savefig(os.path.join(data_img_path, 'mau28_over_time.png'), dpi=300, bbox_inches='tight')

plt.show()

# %%
