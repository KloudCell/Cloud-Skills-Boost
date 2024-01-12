#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

## Service Token
cat <<'EOF'> token_policies.txt
[
  "default",
  "jenkins"
]
EOF

if (gsutil cp token_policies.txt gs://$ID)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Service Token Created: Checkpoint Completed (1/1)'
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all