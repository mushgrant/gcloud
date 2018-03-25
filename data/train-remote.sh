#! /bin/sh

. ./config.sh

BUCKET_NAME=$REMOTE_BUCKET_NAME
TRAIN_DATA=$REMOTE_TRAIN_DATA
EVAL_DATA=$REMOTE_EVAL_DATA
OUTPUT_PATH=$REMOTE_OUTPUT_PATH
REGION=$REMOTE_REGION

if [[ $# -eq 0 ]] ; then
    echo 'Arg missing'
    echo 'Usage : train-remote.sh <training job name>'
    exit 0
fi
JOB_NAME=$1

PROJECT_ID=$(gcloud config list project --format "value(core.project)")
AUTH_TOKEN=$(gcloud auth print-access-token)
SVC_ACCOUNT=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" https://ml.googleapis.com/v1/projects/${PROJECT_ID}:getConfig | python -c "import json; import sys; response = json.load(sys.stdin); print response['serviceAccount']")
echo $SVC_ACCOUNT

gsutil -m defacl ch -u $SVC_ACCOUNT:R gs://$BUCKET_NAME
gsutil -m acl ch -u $SVC_ACCOUNT:R -r gs://$BUCKET_NAME
gsutil -m acl ch -u $SVC_ACCOUNT:W gs://$BUCKET_NAME

gcloud ml-engine jobs submit training $JOB_NAME \
--job-dir $OUTPUT_PATH \
--runtime-version 1.5 \
--module-name trainer.task \
--package-path trainer/ \
--region $REGION \
-- \
--train-files $TRAIN_DATA \
--eval-files $EVAL_DATA \
--train-steps 1000 \
--verbosity DEBUG
