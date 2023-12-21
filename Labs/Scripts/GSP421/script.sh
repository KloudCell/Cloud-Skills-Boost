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

export ID=$(gcloud config list --format 'value(core.project)')

# Create 2 Cloud Storage Buckets
if (gsutil mb gs://$ID
    gsutil mb gs://$ID-2)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Created 2 Buckets: Checkpoint Completed (1/3)'

# Upload Files demo-image1.png and demo-image2.png to First Bucket
    if (wget -O demo-image1.png https://cdn.qwiklabs.com/E4%2BSx10I0HBeOFPB15BFPzf9%2F%2FOK%2Btf7S0Mbn6aQ8fw%3D
        wget -O demo-image2.png https://cdn.qwiklabs.com/Hr8ohUSBSeAiMUJe1J998ydGcTu%2FrF4BUjZ2J%2BbiKps%3D
        gsutil cp demo-image1.png gs://$ID
        gsutil cp demo-image2.png gs://$ID)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Uploaded the 2 images to First Bucket: Checkpoint Completed (2/3)'

# Copy files between Cloud Storage buckets
        if (gsutil cp gs://$ID/demo-image1.png gs://$ID-2/demo-image1-copy.png)

        then 
            printf "\n\e[1;96m%s\n\n\e[m" 'Copied file to the Second Bucket: Checkpoint Completed (3/3)'

        fi
    fi
fi


printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all