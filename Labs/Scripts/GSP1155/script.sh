#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

while true; do
    # Print the message
    echo -e "Please accept the terms by going to the following link otherwise lab will not complete: \033[0;34mhttps://console.developers.google.com/terms/cloud\033[0m"
    
    # Ask for user input
    read -p "Have you accepted the terms? (y/n) " yn
    
    # Check the user input
    case $yn in
        [Yy]* ) break;;
        * ) echo "Please accept the terms to proceed.";;
    esac
done

# Enable the Vertex AI API
if (gcloud services enable aiplatform.googleapis.com)

then
    sleep 12
    printf "\n\e[1;96m%s\n\n\e[m" 'Vertex AI API Enabled: Checkpoint Completed (1/3)'
fi

# Sample text prompts & chat prompts

MODEL_ID="text-bison"
PROJECT_ID=$ID
curl \
-X POST \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
https://us-central1-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/us-central1/publishers/google/models/${MODEL_ID}:predict -d \
$'{
  "instances": [
    { "prompt": "Provide a summary with about two sentences for the following article:
The efficient-market hypothesis (EMH) is a hypothesis in financial \
economics that states that asset prices reflect all available \
information. A direct implication is that it is impossible to \
\\"beat the market\\" consistently on a risk-adjusted basis since market \
prices should only react to new information. Because the EMH is \
formulated in terms of risk adjustment, it only makes testable \
predictions when coupled with a particular model of risk. As a \
result, research in financial economics since at least the 1990s has \
focused on market anomalies, that is, deviations from specific \
models of risk. The idea that financial market returns are difficult \
to predict goes back to Bachelier, Mandelbrot, and Samuelson, but \
is closely associated with Eugene Fama, in part due to his \
influential 1970 review of the theoretical and empirical research. \
The EMH provides the basic logic for modern risk-based theories of \
asset prices, and frameworks such as consumption-based asset pricing \
and intermediary asset pricing can be thought of as the combination \
of a model of risk with the EMH. Many decades of empirical research \
on return predictability has found mixed evidence. Research in the \
1950s and 1960s often found a lack of predictability (e.g. Ball and \
Brown 1968; Fama, Fisher, Jensen, and Roll 1969), yet the \
1980s-2000s saw an explosion of discovered return predictors (e.g. \
Rosenberg, Reid, and Lanstein 1985; Campbell and Shiller 1988; \
Jegadeesh and Titman 1993). Since the 2010s, studies have often \
found that return predictability has become more elusive, as \
predictability fails to work out-of-sample (Goyal and Welch 2008), \
or has been weakened by advances in trading technology and investor \
learning (Chordia, Subrahmanyam, and Tong 2014; McLean and Pontiff \
2016; Martineau 2021).
Summary:
"}
  ],
  "parameters": {
    "temperature": 0.2,
    "maxOutputTokens": 256,
    "topK": 40,
    "topP": 0.95
  }
}' > summarization_prompt_example.txt


MODEL_ID="text-bison"
PROJECT_ID=$ID
curl \
-X POST \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
https://us-central1-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/us-central1/publishers/google/models/${MODEL_ID}:predict -d \
$'{
  "instances": [
    { "prompt": "Give me ten interview questions for the role of program manager."}
  ],
  "parameters": {
    "temperature": 0.2,
    "maxOutputTokens": 1024,
    "topK": 40,
    "topP": 0.8
  }
}' > ideation_prompt_example.txt


MODEL_ID="chat-bison"
PROJECT_ID=$ID
curl \
-X POST \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
https://us-central1-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/us-central1/publishers/google/models/${MODEL_ID}:predict -d \
'{
  "instances": [{
      "context":  "My name is Ned. You are my personal assistant. My favorite movies are Lord of the Rings and Hobbit.",
      "examples": [ { 
          "input": {"content": "Who do you work for?"},
          "output": {"content": "I work for Ned."}
      },
      { 
          "input": {"content": "What do I like?"},
          "output": {"content": "Ned likes watching movies."}
      }],
      "messages": [
      { 
          "author": "user",
          "content": "Are my favorite movies based on a book series?",
      }],
  }],
  "parameters": {
    "temperature": 0.3,
    "maxDecodeSteps": 200,
    "topP": 0.8,
    "topK": 40
  }
}' > sample_chat_prompts.txt

if (gsutil cp *.txt gs://$ID)

then
    sleep 12
    printf "\n\e[1;96m%s\n\n\e[m" 'Sample text prompts uploaded to bucket: Checkpoint Completed (2/3)'
    sleep 3
    printf "\n\e[1;96m%s\n\n\e[m" 'Sample chat prompts uploaded to bucket: Checkpoint Completed (3/3)'
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all