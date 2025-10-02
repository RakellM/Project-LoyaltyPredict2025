# %%

## LIBRARY

import os
import kaggle

# %%

## PATH & OTHERS
# Project Directory
project_dir = os.path.join(os.path.expanduser("~"), "OneDrive", "Project_Code", "Project-LoyaltyPredict_2025")

# Data path
data_ls_path = os.path.join(project_dir, "data", "loyalty-system")
os.makedirs(data_ls_path, exist_ok=True)

data_ep_path = os.path.join(project_dir, "data", "education-platform")
os.makedirs(data_ep_path, exist_ok=True)

# %%
## DATA
# Download data from Kaggle
kaggle.api.authenticate()
kaggle.api.dataset_download_files('teocalvo/teomewhy-loyalty-system', 
                                  path=data_ls_path, 
                                  unzip=True)

kaggle.api.dataset_download_files('teocalvo/teomewhy-education-platform', 
                                  path=data_ep_path, 
                                  unzip=True)

# %%
