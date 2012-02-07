This repo holds scripts to create .deb's for Ubuntu 11.10.

The goal is to have nice logging and metrics. Needed packages should
be installable by `apt-get` to make Puppet/Chef modules easy.

# Packaged projects

- logstash for jruby
    - grok
- logstash for ruby 1.9
    - dependent ruby gems
- fetep-statsd
    - dependent ruby gems
- syslog-shipper
    - dependent ruby gems

# External dependencies

- elasticsearch

# Requirements

- ruby1.9.1 (`apt-get install ruby-1.9.1-full`)
- fpm (`gem1.9.1 install fpm`)

# How to package

    git clone ...
    git submodule init
    git submodule update
    ./package.sh

- find the .debs in `./work`

# Notes

Ruby gems are installed to different locations, depending on the Ruby
version (1.8 or 1.9). So I package as stuff for 1.9 as
`rubygem19-...`.
