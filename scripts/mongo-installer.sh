
DEBIAN_FRONTEND=noninteractive
mkdir /app
sudo apt update -qq
sudo apt install python3 python3-pip wget curl libcurl4 > /dev/null
pip3 install --quiet --upgrade pip
pip3 install --quiet --upgrade pip3
pip3 install --quiet flask
pip3 install --quiet flask_cors
pip3 install --quiet pymongo
pip3 install --quiet dnspython
wget https://downloads.mongodb.org/linux/mongodb-shell-linux-x86_64-ubuntu2004-4.4.6.tgz
tar zxvf *.tgz
mkdir mongo
tar -xzf *.tgz -C mongo --strip-components=1
export PATH=$PATH:/app/mongo/bin
cd /app
mv /tmp/api.py .
chmod 0755 api.py
python3 api.py > /tmp/api-dump.log 2>&1

