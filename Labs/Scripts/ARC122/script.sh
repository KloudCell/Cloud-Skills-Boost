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

export BUCKET=$(gcloud info --format='value(config.project)')-bucket

# Create an API KEY
if (export API_KEY=$(gcloud beta services api-keys create --display-name='API key 1' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3) && sleep 30)
    
then
    sleep 30 && printf "\n\e[1;96m%s\n\n\e[m" 'API KEY Created: Checkpoint Completed (1/3)'
fi

# Get the ACL of the image
acl=$(gsutil acl get gs://$BUCKET/manif-des-sans-papiers.jpg)

# Check if the image is publicly available
if echo "$acl" | grep -q "allUsers"; then
    echo "Your image is publicly available."
else
    # Remove the image from the bucket
    gsutil rm gs://$BUCKET/manif-des-sans-papiers.jpg

    # Download the image
    wget https://github.com/KloudCell/Cloud-Skills-Boost/blob/main/Labs/Scripts/ARC122/manif-des-sans-papiers.jpg

    # Upload the image to the bucket
    gsutil cp manif-des-sans-papiers.jpg gs://$BUCKET
fi

# Create and Update the json file
echo '{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://BUCKET/manif-des-sans-papiers.jpg"
          }
        },
        "features": [
          {
            "type": "TEXT_DETECTION" ,
            "maxResults": 10
          }
        ]
      }
  ]
}' > request.json

sed -i "s/BUCKET/$BUCKET/g" request.json

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o text-response.json

if (gsutil cp text-response.json gs://$BUCKET)

then
    sleep 30 && printf "\n\e[1;96m%s\n\n\e[m" 'Updated the JSON File to use TEXT_DETECTION method: Checkpoint Completed (2/3)'
fi

# Update the json file to use the LANDMARK_DETECTION method
echo '{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://BUCKET/manif-des-sans-papiers.jpg"
          }
        },
        "features": [
          {
            "type": "LANDMARK_DETECTION" ,
            "maxResults": 10
          }
        ]
      }
  ]
}' > request.json

sed -i "s/BUCKET/$BUCKET/g" request.json

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o landmark-response.json

if (gsutil cp landmark-response.json gs://$BUCKET)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Updated the JSON File to use LANDMARK_DETECTION method: Checkpoint Completed (3/3)'
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all