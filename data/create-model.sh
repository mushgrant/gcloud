#! /bin/sh

. ./config.sh

MODEL_NAME=$REMOTE_MODEL_NAME
BUCKET_NAME=$REMOTE_BUCKET_NAME
REGION=$REMOTE_REGION
OUTPUT_PATH=$REMOTE_OUTPUT_PATH

MODEL_EXISTS=$(gcloud ml-engine models list | grep $MODEL_NAME  | awk '{print $1}')
echo "Model Name : $MODEL_EXISTS"

if [ -z "$MODEL_EXISTS" ]; then
  echo "Model does not exist. Creating one"
  gcloud ml-engine models create $MODEL_NAME --regions=$REGION
fi

MODEL_BINARIES=$(gsutil ls $OUTPUT_PATH/export/Servo/ | tail -1)
echo "Model Binaries path : $MODEL_BINARIES"

MODEL_VERSION_TMP=$(gcloud ml-engine versions list --model $MODEL_NAME | tail -1 | awk '{print $1}')
if [[ $MODEL_VERSION_TMP == *"Listed"* ]]; then
  echo "No prior version of the model. Creating first version of the model"
  MODEL_VERSION_TMP = "v0"
fi

echo "Model Version tmp : $MODEL_VERSION_TMP"
MODEL_VERSION=$(echo $MODEL_VERSION_TMP | awk -F"v" '{print "v"++$2}')
echo "Model Version : $MODEL_VERSION"

gcloud ml-engine versions create $MODEL_VERSION \
--model $MODEL_NAME \
--origin $MODEL_BINARIES \
--runtime-version 1.5
