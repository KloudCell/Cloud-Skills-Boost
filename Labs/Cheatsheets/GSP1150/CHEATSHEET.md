# **To be done using Cloud Shell & Jupyter lab**

- Run below cmd in Cloud Shell and click on the generated link to navigate to the Jupyter Lab

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

echo "https://$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")/lab"
```

- Open terminal in Jupyter Lab and run below cmds

```
cd generative-ai/language/getting-started

wget -O intro_palm_api.ipynb https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP1150/intro_palm_api.ipynb 2> /dev/null

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

echo "https://$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")/lab/tree/generative-ai/language/getting-started/intro_palm_api.ipynb"
```

- Click on the link to open `intro_palm_api.ipynb` file & Run all the cells

## Lab Completed🎉