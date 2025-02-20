FROM postgis/postgis:15-master

RUN apt-get update && apt-get install -y curl lsb-release && echo deb http://apt.dalibo.org/labs $(lsb_release -cs)-dalibo main > /etc/apt/sources.list.d/dalibo-labs.list \
&& curl -fsSL -o /etc/apt/trusted.gpg.d/dalibo-labs.gpg https://apt.dalibo.org/labs/debian-dalibo.gpg && apt update

RUN apt install -y postgresql_anonymizer_15

CMD ["postgres"]
