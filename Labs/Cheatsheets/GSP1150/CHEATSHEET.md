# **To be done using Cloud Shell & Jupyter lab

- Run below cmd and click on the generated link to navigate to the Jupyter Lab

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

echo 'https://'$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")'/lab/tree/generative-ai/language/getting-started/intro_palm_api.ipynb'
```
- In Jupyter Lab delete the file `intro_palm_api.ipynb`
- Download the new file from here: 
- Upload it and run all cells

## Lab Completed🎉