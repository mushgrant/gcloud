#! /bin/sh

export LOCAL_TRAIN_DATA=./data/training.csv
export LOCAL_EVAL_DATA=./data/test.csv
export LOCAL_MODEL_DIR=./output

export REMOTE_MODEL_NAME=classifier_sample
export REMOTE_BUCKET_NAME=toydatasets
export REMOTE_TRAIN_DATA=gs://$REMOTE_BUCKET_NAME/data/train.csv
export REMOTE_EVAL_DATA=gs://$REMOTE_BUCKET_NAME/data/test.csv
export REMOTE_OUTPUT_PATH=gs://$REMOTE_BUCKET_NAME/output
export REMOTE_REGION=us-central1
