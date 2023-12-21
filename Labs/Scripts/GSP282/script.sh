#! /bin/bash

# Check if Python is installed
if ! command -v python3 &>/dev/null; then
    echo "Python 3 is not installed"
    echo "Installing Python 3..."
    sudo apt-get update
    sudo apt-get install -y python3
fi

cat << 'EOF' > a.py

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

print(bcolors.OKCYAN + """

.-. .-')                                     _ .-') _                      ('-.
\  ( OO )                                   ( (  OO) )                   _(  OO)
,--. ,--. ,--.      .-'),-----.  ,--. ,--.   \     .'_          .-----. (,------.,--.      ,--.
|  .'   / |  |.-') ( OO'  .-.  ' |  | |  |   ,`'--..._)        '  .--./  |  .---'|  |.-')  |  |.-')
|      /, |  | OO )/   |  | |  | |  | | .-') |  |  \  '        |  |('-.  |  |    |  | OO ) |  | OO )
|     ' _)|  |`-' |\_) |  |\|  | |  |_|( OO )|  |   ' |       /_) |OO  )(|  '--. |  |`-' | |  |`-' |
|  .   \ (|  '---.'  \ |  | |  | |  | | `-' /|  |   / :       ||  |`-'|  |  .--'(|  '---.'(|  '---.'
|  |\   \ |      |    `'  '-'  '('  '-'(_.-' |  '--'  /      (_'  '--'\  |  `---.|      |  |      |
`--' '--' `------'      `-----'   `-----'    `-------'          `-----'  `------'`------'  `------'

""" + bcolors.ENDC)

print(bcolors.OKGREEN + """
[ GitHub : https://github.com/KloudCell/Cloud-Skills-Boost ]
""" + bcolors.ENDC)

EOF

python3 a.py

# Initialization
gcloud init --skip-diagnostics

# Enable Dialogflow API
if (gcloud services enable dialogflow.googleapis.com)

then
  printf "\n\e[1;96m%s\n\n\e[m" 'Dialogflow API Enabled (1/1)'
  
  printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all
