# **To be done using Google Cloud Shell**

**1. Set up a Google Cloud Storage bucket**

**2. Upload the data files to your Cloud Storage bucket**

**3. Run a single-instance trainer in the cloud**

**4. Create a Cloud ML Engine model**

**5. Create a version v1 of your model**

```bash
ID=$(gcloud config list project --format "value(core.project)")
BUCKET_NAME=${ID}-aiplatform
REGION=us-central1
MODEL_DIR=output
MODEL_NAME=census
TEST_JSON=gs://$BUCKET_NAME/data/test.json
JOB_NAME=census_single_1
OUTPUT_PATH=gs://$BUCKET_NAME/$JOB_NAME

sudo apt-get update
sudo apt-get install virtualenv -y
python3 -m venv my_env
source my_env/bin/activate

git clone https://github.com/GoogleCloudPlatform/training-data-analyst.git

cd training-data-analyst/self-paced-labs/tensorflow-2.x/census

mkdir data
gsutil -m cp gs://cloud-samples-data/ml-engine/census/data/* data/

export TRAIN_DATA=$(pwd)/data/adult.data.csv
export EVAL_DATA=$(pwd)/data/adult.test.csv

head data/adult.data.csv

pip install -r requirements.txt

gcloud ai-platform local train \
        --module-name trainer.task \
        --package-path trainer/ \
        --job-dir $MODEL_DIR \
        -- \
        --train-files $TRAIN_DATA \
        --eval-files $EVAL_DATA \
        --train-steps 1000 \
        --eval-steps 100

cat <<'EOF'> train.py
from trainer import util
_, _, eval_x, eval_y = util.load_data()
prediction_input = eval_x.sample(5)
prediction_targets = eval_y[prediction_input.index]
print(prediction_input)
import json
with open('test.json', 'w') as json_file:
    for row in prediction_input.values.tolist():
    	json.dump(row, json_file)
    	json_file.write('\n')
EOF

python3 train.py

gcloud ai-platform local predict \
        --model-dir output/keras_export/ \
        --json-instances ./test.json

gsutil mb -l $REGION gs://$BUCKET_NAME

gsutil cp -r data gs://$BUCKET_NAME/data

TRAIN_DATA=gs://$BUCKET_NAME/data/adult.data.csv
EVAL_DATA=gs://$BUCKET_NAME/data/adult.test.csv

gsutil cp test.json gs://$BUCKET_NAME/data/test.json

gcloud ai-platform jobs submit training $JOB_NAME \
        --job-dir $OUTPUT_PATH \
        --runtime-version 2.1 \
        --python-version 3.7 \
        --module-name trainer.task \
        --package-path trainer/ \
        --region $REGION \
        -- \
        --train-files $TRAIN_DATA \
        --eval-files $EVAL_DATA \
        --train-steps 1000 \
        --eval-steps 100 \
        --verbosity DEBUG

gcloud ai-platform jobs stream-logs $JOB_NAME

gcloud ai-platform models create $MODEL_NAME --regions=$REGION

gsutil ls -r $OUTPUT_PATH/keras_export

MODEL_BINARIES=$OUTPUT_PATH/keras_export/

gcloud config set ai_platform/region global

    gcloud ai-platform versions create v1 \
        --model $MODEL_NAME \
        --origin $MODEL_BINARIES \
        --runtime-version 2.1 \
        --python-version 3.7
```
## Lab Completed🎉