# %%

## LIBRARY
import pandas as pd
import sqlalchemy
import os
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn import cluster, preprocessing


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

data_img_path = os.path.join(project_dir, "img")
os.makedirs(data_img_path, exist_ok=True)

# %%

## FUCNTION
# Function to import SQL query from a .sql file
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query(os.path.join(data_srcA_path, "frequency_value.sql"))
# print(query)

# %%
# Create SQLAlchemy engine
db_path = os.path.join(data_ls_path, "database.db")
engine_app = sqlalchemy.create_engine(f'sqlite:///{db_path}')

db_analytical_path = os.path.join(data_analytics_path, "database.db")
engine_analytical = sqlalchemy.create_engine(f'sqlite:///{db_analytical_path}')

# %%
df = pd.read_sql_query(query, engine_app)
df.head()

# Remove outlier
df = df[df['QtyPointsPositive'] < 4000]  

# %%
# Plot
plt.plot(df['Frequency'], df['QtyPointsPositive'], 'o')
plt.title('Frequency vs Qty Points Positive')
plt.xlabel('Frequency')
plt.ylabel('Qty Points Positive')
plt.grid(True)

# Save figure before showing
plt.savefig(os.path.join(data_img_path, 'Frequency_Value_noOutlier.png'), dpi=300, bbox_inches='tight')

plt.show()

# %%
# Standardize the data
MinMax = preprocessing.MinMaxScaler()

X = MinMax.fit_transform(df[['Frequency', 'QtyPointsPositive']])


# %%
# Clustering
kmeans = cluster.KMeans(n_clusters=5, random_state=21, max_iter=1000)
kmeans.fit(X)

df['Cluster'] = kmeans.labels_

# %%
df.groupby('Cluster').agg({'Frequency': 'mean', 
                           'QtyPointsPositive': 'mean', 
                           'IdCliente': 'count'})

# %%
# Plot with clusters
sns.scatterplot(data=df, x='Frequency', y='QtyPointsPositive', hue='Cluster', palette='deep')
plt.title('Frequency vs Qty Points Positive with Clusters')
plt.xlabel('Frequency')
plt.ylabel('Qty Points Positive')
plt.legend(title='Cluster', bbox_to_anchor=(1.05, 1), loc='upper left')
plt.grid(True)

# Save figure before showing
plt.savefig(os.path.join(data_img_path, 'Frequency_Value_Clusters.png'), dpi=300, bbox_inches='tight')

plt.show()

# %%


