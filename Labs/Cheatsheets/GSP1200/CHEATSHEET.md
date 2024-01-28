# **To be done using Google Cloud Shell & Jupyter lab**

- Run below cmd in Cloud Shell and click on the generated link to navigate to the Jupyter Lab

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

echo "https://$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")/lab"
```

- In Jupyter Lab open the terminal and run below cmds

```
pip install protobuf==3.20.*

cat<< 'EOF' > restart.py
import os
os._exit(00)
EOF

python restart.py

wget -O youtube_analysis.ipynb https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP1200/youtube_analysis.ipynb 2> /dev/null

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

echo "https://$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")/lab/tree/youtube_analysis.ipynb"
```

- Now click on the link to open `youtube_analysis.ipynb` & run all the cells

## Lab Completed🎉