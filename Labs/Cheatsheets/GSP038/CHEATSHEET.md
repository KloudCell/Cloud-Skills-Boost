# **To be done using Google Cloud Shell**

**1. Create an API Key**

**2. Make an Entity Analysis Request**

**3. Check the Entity Analysis response**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh
export API_KEY=$(gcloud beta services api-keys create --display-name='API key 1' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

cat > entity.sh << EOF
echo '{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"Joanne Rowling, who writes under the pen names J. K. Rowling and Robert Galbraith, is a British novelist and screenwriter who wrote the Harry Potter fantasy series."
  },
  "encodingType":"UTF8"
}' > request.json

curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json > result.json 
EOF

gcloud compute scp entity.sh --zone $ZONE linux-instance:~ -q

gcloud compute ssh --zone "$ZONE" "linux-instance" --command ". entity.sh" -q
```

## Lab Completed🎉