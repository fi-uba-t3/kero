FROM python:3

RUN apt-get update && apt-get install -y apt-transport-https && \
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
apt-get update && \
apt-get install -y kubectl gettext libsasl2-dev libldap2-dev libssl-dev

RUN pip install flask python-ldap kubernetes gunicorn

WORKDIR /app
ADD static /app/static
ADD templates /app/templates
ADD *.py /app/

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "dashboard:app"]
