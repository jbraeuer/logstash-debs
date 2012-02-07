#! /bin/bash

log() {
    echo "$@"
}

clean() {
    log "Clean workdir"
    rm -rf "$work"
}

get_logstash() {
    log "Get source"
    mkdir -p "$download"

    #
    # Download binary version of logstash
    #
    cd "$download"
    file="logstash-1.1.0-monolithic.jar"
    url="http://semicomplete.com/files/logstash/logstash-1.1.0-monolithic.jar"
    [ -e "$file" ] || wget --output-document "$file" "$url"
}

package_logstash() {
    log "Package logstash"

    mkdir -p "$work/logstash/usr/share/logstash/"
    cp "$download/logstash-1.1.0-monolithic.jar" "$work/logstash/usr/share/logstash/"

    cd "$work"
    fpm -s dir -t deb --name logstash --version 1.1.0 --depends 'openjdk-6-jdk' --depends "grok" -a all -C "$work/logstash" .
}

package_ruby_logstash() {
    log "Package logstash ruby"

    mkdir -p "$work"
    cp -r "$upstream/logstash" "$work/rubygem19-logstash"
    cd "$work/rubygem19-logstash"
    cp "$base/logstash/"* .
    gem build logstash.gemspec

    cd "$work"
    ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19 rubygem19-logstash/logstash-1.1.0.gem
}

package_ruby_logstash_deps() {
    log "Package logstash ruby deps"

    mkdir -p "$work/logstash-ruby-deps/"
    cd "$work/logstash-ruby-deps/"

    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ --version 0.1.7 cabin
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ bunny
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ uuidtools
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ --version 0.3.2 filewatch
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ --version 0.9.6 jls-grok
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ stomp
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ json
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ awesome_print
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ minitest
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ rack
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ sinatra
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ haml
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ sass
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ mongo
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ redis
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ gelf
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ --version 0.3.0 statsd-ruby
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ --version 0.1.3 gmetric
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ --version 0.5 xmpp4r
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ --version 0.2.0 gelfd
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ --version 0.9.0 ffi-rzmq
    gem1.9.1 install --no-ri --no-rdoc --install-dir ./tmp/ ffi

    cd "$work/"
    find "./logstash-ruby-deps/tmp/" -name '*.gem' | xargs -rn1 ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19
}

get_grok() {
    log "Get source"
    mkdir -p "$download"

    #
    # Fake a upstream tar.gz release by using git-archive on the git-checkout
    # Dependency to grok.git is handled via git submodules
    #
    version=$(cat "$base/grok/grok_version.h" | grep GROK_VERSION | awk '{ print $6 }' | tr -d '";')
    file="$download/grok_$version.orig.tar.gz"
    if [ ! -e "$file" ]; then
	cd "$upstream/grok"
	git archive --format=tar --prefix="grok-$version/" HEAD | gzip > "$file"
    fi
}

package_grok() {
    log "Package grok"
    mkdir -p "$work"

    version=$(cat "$base/grok/grok_version.h" | grep GROK_VERSION | awk '{ print $6 }' | tr -d '";')
    file="$download/grok_$version.orig.tar.gz"

    cd "$work"
    cp "$file" "$work"
    tar xfz "$file"
    cp -r $base/grok/* "$work/grok-$version/"

    cd "$work/grok-$version/"
    debuild -us -uc -F
}

package_statsd() {
    log "Package statsd"
    mkdir -p "$work"
    cd "$work"

    ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19 -v 0.12.10 eventmachine
    ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19 -v 0.9.0 amq-protocol
    ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19 -v 0.9.1 amq-client
    ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19 -v 0.9.2 amqp
    ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19 -v 0.5 petef-statsd
}

package_syslog_shipper() {
    log "Package syslog-shipper"
    mkdir -p "$work"
    cd "$work"

    ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19 -v 0.6.3 eventmachine-tail
    ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19 -v 1.16.2 trollop
    ruby1.9.1 /var/lib/gems/1.9.1/bin/fpm -s gem -t deb -S 19 -v 1.1 syslog-shipper
}

base=$(dirname $(readlink -f "$0"))
work="$base/work"
download="$base/download"
upstream="$base/upstream"

set -e
set -x

clean

get_logstash
package_logstash

package_ruby_logstash
package_ruby_logstash_deps

get_grok
package_grok

package_statsd
#package_syslog_shipper
