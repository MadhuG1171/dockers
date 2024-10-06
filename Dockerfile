# FROM ubuntu
# RUN apt-get update
# RUN apt-get install -y python3 python3-pip python-venv
# RUN python3 -m venv /opt/venv
# RUN pip install flask flask-mysql
# COPY . /Users/madhug/POC-DevOps/Docker/source-code
# ENTRYPOINT FLASK_APP=/Users/madhug/POC-DevOps/Docker/source-code/app.py run
FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv
RUN python3 -m venv /opt/venv
RUN /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install flask flask-mysql
ENV PATH="/opt/venv/bin:$PATH"
COPY . /Users/madhug/POC-DevOps/Docker/source-code
EXPOSE 5000
ENV FLASK_APP=/Users/madhug/POC-DevOps/Docker/source-code/app.py
ENTRYPOINT ["flask", "run", "--host=0.0.0.0"]