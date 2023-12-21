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

# Create Cloud Storage Bucket
if (gsutil mb gs://$ID-bucket)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Created Bucket: Checkpoint Completed (1/3)'

# Upload an image in a storage bucket (demo-image.jpg)
    if (wget -O demo-image.jpg https://cdn.qwiklabs.com/3hpf8ZMmvpav2QvPqQCY1Zl1O%2B%2F8rrass6yjAPki3Dc%3D
        gsutil cp demo-image.jpg gs://$ID-bucket)
    
    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Uploaded the image to Bucket: Checkpoint Completed (2/3)'

# Make the uploaded image publicly accessible.
        if (gsutil acl ch -u AllUsers:R gs://$ID-bucket/demo-image.jpg)
        
        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Image is now publicly accessible: Checkpoint Completed (3/3)'

        fi
    fi    
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all