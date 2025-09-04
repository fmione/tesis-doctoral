FROM python:3.8.0-slim

RUN apt-get install -y tzdata
ENV TZ=Europe/Berlin

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir pandas==1.5.3

RUN pip install --no-cache-dir --force-reinstall sqlalchemy==1.4.46
RUN pip install --no-cache-dir mysql-connector-python==8.0.32

RUN pip install streamlit==1.25.0
RUN pip install plotly==5.13.0
RUN pip install matplotlib==3.7.0

WORKDIR /monitoring

EXPOSE 8501

ENTRYPOINT ["streamlit", "run", "app.py"]
