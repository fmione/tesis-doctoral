FROM python:3.8.0-slim

ENV TZ=Europe/Berlin

RUN pip install pandas
RUN pip install numpy
RUN pip install scipy
RUN pip install matplotlib

RUN pip install --no-cache-dir --force-reinstall sqlalchemy==1.4.46
RUN pip install --no-cache-dir mysql-connector-python