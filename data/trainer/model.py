#!/usr/bin/env python

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import tensorflow as tf


CSV_COLUMNS = ['REVIEWS', 'BOUGHT_TOGETHER', 'COMPARE_SIMILAR', 'WARRANTY', 'SPONSORED_LINKS',  'BUY']
LABEL_COLUMN = 'BUY'
DEFAULTS = [[0], [0], [0], [0], [0], [0]]





reviews = tf.feature_column.categorical_column_with_identity(key='REVIEWS', num_buckets=2, default_value=None)
bought_together = tf.feature_column.categorical_column_with_identity(key='BOUGHT_TOGETHER', num_buckets=2, default_value=None)
compare_similar = tf.feature_column.categorical_column_with_identity(key='COMPARE_SIMILAR', num_buckets=2, default_value=None)
warranty = tf.feature_column.categorical_column_with_identity(key='WARRANTY', num_buckets=2, default_value=None)
sponsored_links = tf.feature_column.categorical_column_with_identity(key='SPONSORED_LINKS', num_buckets=2, default_value=None)

INPUT_COLUMNS = [tf.feature_column.indicator_column(reviews),tf.feature_column.indicator_column(bought_together),
             tf.feature_column.indicator_column(compare_similar), tf.feature_column.indicator_column(warranty),
             tf.feature_column.indicator_column(sponsored_links)]


def build_estimator(model_dir, hidden_units):
    (rev, bgt_to, com_sim, war, sp_lnk) = INPUT_COLUMNS

    return tf.estimator.DNNClassifier(model_dir=model_dir,
        feature_columns=[rev, bgt_to, com_sim, war, sp_lnk],
        # Two hidden layers of 10 nodes each.
        hidden_units=hidden_units or [10, 10],
        # The model is classifying 2 classes
        n_classes=2)

def serving_input_fn():
    feature_placeholders = {
        column.name: tf.placeholder(tf.float32, [None]) for column in INPUT_COLUMNS
    }
    features = {
      key: tf.expand_dims(tensor, -1)
      for key, tensor in feature_placeholders.items()
    }
    return tf.estimator.export.ServingInputReceiver(
           features,
           feature_placeholders)

def generate_csv_input_fn(filename, num_epochs=None, batch_size=512, mode=tf.estimator.ModeKeys.TRAIN):
  def _input_fn():
    # could be a path to one file or a file pattern.
    input_file_names = tf.train.match_filenames_once(filename)
    #input_file_names = [filename]

    filename_queue = tf.train.string_input_producer(
        input_file_names, num_epochs=num_epochs, shuffle=True)
    reader = tf.TextLineReader()
    _, value = reader.read_up_to(filename_queue, num_records=batch_size)

    value_column = tf.expand_dims(value, -1)

    columns = tf.decode_csv(value_column, record_defaults=DEFAULTS)

    features = dict(zip(CSV_COLUMNS, columns))

    label = features.pop(LABEL_COLUMN)

    return features, label

  return _input_fn

def get_eval_metrics():
  return {
      'accuracy': tf.metrics.accuracy(name=None)
  }

