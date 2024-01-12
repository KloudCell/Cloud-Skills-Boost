# **To be done using Cloud Shell & Jupyter lab**

- Run below cmd in Cloud Shell and click on the generated link to navigate to the Jupyter Lab

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

echo "https://$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")/lab"
```

- Open terminal in Jupyter Lab and run below cmds

```
cd generative-ai/language/prompts

wget -O intro_prompt_design.ipynb https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP1151/intro_prompt_design.ipynb 2> /dev/null

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

echo -e "Link 1: \e[34mhttps://$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")/lab/tree/generative-ai/language/prompts/intro_prompt_design.ipynb\e[0m\n"


echo -e "Link 2: \e[34mhttps://$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")/lab/tree/generative-ai/language/prompts/examples/question_answering.ipynb\e[0m"
```

- Open Link 1, Link 2 & run all the cells present in `intro_prompt_design.ipynb` & `question_answering.ipynb` file.

## Lab Completed🎉