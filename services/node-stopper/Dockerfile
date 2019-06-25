FROM python:3

## Install kubectl
RUN apt-get update && apt-get install -y apt-transport-https curl && \
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
apt-get update && \
apt-get install -y kubectl

RUN apt-get install -y jq

RUN apt-get install -y gawk

ADD stopper.sh /

CMD [ "/stopper.sh" ]
