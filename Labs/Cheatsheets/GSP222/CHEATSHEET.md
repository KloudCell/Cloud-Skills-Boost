# **To be execute in Google Cloud Shell**

**1. Enable the Text-to-Speech API**

**2. Create a service account**

```
export ID=$(gcloud config list --format 'value(core.project)')
gcloud services enable texttospeech.googleapis.com
gcloud iam service-accounts create tts-qwiklab
gcloud iam service-accounts keys create tts-qwiklab.json --iam-account tts-qwiklab@$ID.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS=tts-qwiklab.json
```

## Lab Completed🎉