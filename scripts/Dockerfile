FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes
RUN mkdir /root/bin
RUN apt update 
RUN apt install python3 python3-pip wget curl libcurl4 -y
RUN pip3 install flask 
RUN pip3 install flask_cors
RUN pip3 install gunicorn
RUN pip3 install pymongo
RUN pip3 install dnspython
RUN wget https://downloads.mongodb.org/linux/mongodb-shell-linux-x86_64-ubuntu2004-4.4.6.tgz
RUN tar zxvf *.tgz
RUN mkdir mongo
RUN tar -xzf *.tgz -C mongo --strip-components=1
RUN export PATH=$PATH:/app/mongo/bin

WORKDIR /app
COPY api.py .
COPY start.sh .
RUN chmod 0755 api.py
RUN chmod 0755 start.sh

ENTRYPOINT ./start.sh

# CMD ["/bin/sh", "-c", "python3 api.py > /tmp/api-dump.log 2>&1"]

EXPOSE 8600
