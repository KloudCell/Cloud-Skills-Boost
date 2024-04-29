# **To be done using VS Code Terminal**

**1. Create machine learning models**

**2. Use the model**

```bash
pip install google-cloud-logging

pip install ---upgrade protobuf

pip install --upgrade tensorflow

python --version

python -c "import tensorflow;print(tensorflow.__version__)"

cat<<'EOF'> model.py 
import logging
import tensorflow as tf
import numpy as np
import google.cloud.logging as cloud_logging
from google.cloud.logging.handlers import CloudLoggingHandler
from google.cloud.logging_v2.handlers import setup_logging

cloud_logger = logging.getLogger('cloudLogger')
cloud_logger.setLevel(logging.INFO)
cloud_logger.addHandler(CloudLoggingHandler(cloud_logging.Client()))
cloud_logger.addHandler(logging.StreamHandler())

xs = np.array([-1.0, 0.0, 1.0, 2.0, 3.0, 4.0], dtype=float)
ys = np.array([-2.0, 1.0, 4.0, 7.0, 10.0, 13.0], dtype=float)

model = tf.keras.Sequential([tf.keras.layers.Dense(units=1, input_shape=[1])])
model.compile(optimizer=tf.keras.optimizers.SGD(), loss=tf.keras.losses.MeanSquaredError())
model.fit(xs, ys, epochs=500)
cloud_logger.info(str(model.predict([10.0])))
EOF

python3 model.py
```

## Lab Completed🎉