#! /bin/sh

. ./config.sh

TRAIN_DATA=$LOCAL_TRAIN_DATA
EVAL_DATA=$LOCAL_EVAL_DATA
MODEL_DIR=$LOCAL_MODEL_DIR

gcloud ml-engine local train \
--module-name trainer.task \
--package-path trainer/ \
--distributed \
-- \
--train-files $TRAIN_DATA \
--eval-files $EVAL_DATA \
--train-steps 1000 \
--job-dir $MODEL_DIR
