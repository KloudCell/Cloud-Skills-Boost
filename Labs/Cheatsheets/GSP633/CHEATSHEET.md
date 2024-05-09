# **To be done using Google Cloud Shell & Jupyter lab**

**1. Enable Google Cloud services**

**2. Create a Cloud Storage Bucket**

**3. Train the Model on Vertex AI**

**4. Deploy the model**

- Run below cmd in Cloud Shell and click on the generated link to navigate to the Jupyter Lab
```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

gcloud services enable \
  compute.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  notebooks.googleapis.com \
  aiplatform.googleapis.com \
  artifactregistry.googleapis.com \
  container.googleapis.com

echo 'https://'$(gcloud notebooks instances describe cloudlearningservices --location=$ZONE --format="value(proxyUri)")'/lab/tree/training-data-analyst/self-paced-labs/learning-tensorflow/convolutional-neural-networks'
```
- Open terminal in Jupyter Lab and run below cmds
```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

wget -O CLS_Vertex_AI_CNN_fmnist.ipynb https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP633/CLS_Vertex_AI_CNN_fmnist.ipynb 2> /dev/null

pip install google-cloud-aiplatform
pip install --user tensorflow-text
pip install --user tensorflow-datasets
pip install protobuf==3.20.1

cat<< 'EOF' > restart.py
import os
os._exit(00)
EOF
python restart.py

echo 'https://'$(gcloud notebooks instances describe cloudlearningservices --location=$ZONE --format="value(proxyUri)")'/lab/tree/training-data-analyst/self-paced-labs/learning-tensorflow/convolutional-neural-networks/CLS_Vertex_AI_CNN_fmnist.ipynb'
```
- Click on the link to open `CLS_Vertex_AI_CNN_fmnist.ipynb` file & Run all the cells

## Lab Completed🎉