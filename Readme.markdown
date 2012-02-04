Running logstash from .debs on Ubuntu 11.10

# Install notes

## Install RabbitMQ
aptitude install rabbitmq-server rabbitmq-stomp
rabbitmqctl add_user logstash verysecret

# Install ElasticSearch
aptitude install elasticsearch
