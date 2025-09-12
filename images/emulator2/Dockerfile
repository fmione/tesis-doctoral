FROM python:3.8.0-slim

ENV TZ=Europe/Berlin

RUN pip install pandas==2.0.3
RUN pip install numpy==1.24.4
RUN pip install scipy==1.10.1
RUN pip install matplotlib==3.7.5

RUN pip install --no-cache-dir --force-reinstall sqlalchemy==1.4.46
RUN pip install --no-cache-dir mysql-connector-python==9.0.0