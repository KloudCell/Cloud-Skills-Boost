# **To be done using Google Cloud Shell**

**Service Token**

```
cat <<'EOF'> token_policies.txt
[
  "default",
  "jenkins"
]
EOF


export ID=$(gcloud config get-value project)
gsutil cp token_policies.txt gs://$ID
```

## Lab Completed🎉