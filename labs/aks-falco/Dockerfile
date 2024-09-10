FROM tensorflow/tensorflow:2.4.0

COPY falco_anomaly_model.h5 /model/

CMD ["python", "-m", "http.server", "8080"]