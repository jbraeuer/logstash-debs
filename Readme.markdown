Running logstash from .debs on Ubuntu 11.10

# Install notes

## Install RabbitMQ

aptitude install rabbitmq-server rabbitmq-stomp

rabbitmqctl add_user logstash verysecret
rabbitmqctl set_permissions -p / logstash ".*" ".*" ".*"

## Install ElasticSearch

aptitude install elasticsearch

# Run

Use scripts in examples/ to run shipper, indexer and web

# Integration with graphite via statsd

## nodejs

- nodejs 0.6
- sudo add-apt-repository ppa:chris-lea/node.js

## graphite

- python2.7-carbon
- edit /opt/graphite/conf/{storage-schemas,carbon}.conf
- /opt/graphite/bin/carbon-cache.py start

## statsd

- https://github.com/etsy/statsd.git
- build debian package

- run statsd:
    `/usr/bin/nodejs /usr/share/statsd/stats.js /etc/statsd/rdioConfig.js`

- ABORT

## statsd-c

- https://github.com/jbuchbinder/statsd-c.git
- graphite output not implemented

- ABORT

## ruby-statsd

- git://github.com/fetep/ruby-statsd.git
- has dependencies to eventmachine, etc

fpm -s gem -t deb -S 19 -v 0.12.10 eventmachine
fpm -s gem -t deb -S 19 -v 0.9.0 amq-protocol
fpm -s gem -t deb -S 19 -v 0.9.1 amq-client
fpm -s gem -t deb -S 19 -v 0.9.2 amqp
fpm -s gem -t deb -S 19 -v 0.5 petef-statsd

- ruby1.9.1 /var/lib/gems/1.9.1/bin/statsd -o stdout://
