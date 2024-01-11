# **To be done using Cloud Shell & Jupyter lab**

- Run the below cmd and open Link 1 & 2

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

echo -e "Link 1: \e[34mhttps://$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")/lab/tree/generative-ai/language/prompts/intro_prompt_design.ipynb\e[0m\n"


echo -e "Link 2: \e[34mhttps://$(gcloud notebooks instances describe generative-ai-jupyterlab --location=$ZONE --format="value(proxyUri)")/lab/tree/generative-ai/language/prompts/examples/question_answering.ipynb\e[0m"
```

- In First Jupyter Lab remove the file `intro_prompt_design.ipynb` and replace it with the new file
- Download the new file from here: <a href="https://github.com/KloudCell/Cloud-Skills-Boost/blob/main/Labs/Cheatsheets/GSP1151/intro_prompt_design.ipynb">intro_prompt_design.ipynb</a>
- Now, run all the cells present in `intro_prompt_design.ipynb`

- In Second Jupyter Lab run all the cells present in `question_answering.ipynb`

## Lab Completed🎉