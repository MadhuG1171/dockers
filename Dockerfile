FROM ubuntu
RUN apt-get update
RUN apt-get install python
RUN pip install flask
RUN pip install flask-mysql
COPY . /Users/madhug/POC-DevOps/Docker/source-code
ENTRYPOINT FLASK_APP=/Users/madhug/POC-DevOps/Docker/source-code/app.py run