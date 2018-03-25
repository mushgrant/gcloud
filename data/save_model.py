tf.saved_model.simple_save(
    session,
    #export_dir
    inputs,
    outputs,
    legacy_init_op=None
    )

#in many cases saving models for serving is as simple as

simple_save(session,
    export_dir,
    inputs={"x":x, "y":y},
    outputs={"z":z})
