#! /bin/bash

log() {
    echo "$@"
}

clean() {
    log "Clean workdir"
    rm -rf "$work"
}

get() {
    log "Get source"
    mkdir -p "$download"

    #
    # Download binary version of logstash
    #
    cd "$download"
    file="logstash-1.1.0-monolithic.jar"
    url="http://semicomplete.com/files/logstash/logstash-1.1.0-monolithic.jar"
    [ -e "$file" ] || wget --output-document "$file" "$url"

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

package_logstash() {
    log "Package logstash"

    mkdir -p "$work/logstash/usr/share/logstash/"
    cp "$download/logstash-1.1.0-monolithic.jar" "$work/logstash/usr/share/logstash/"

    cd "$work"
    fpm -s dir -t deb --name logstash --version 1.1.0 --depends 'openjdk-6-jdk' --depends "grok" -a all -C "$work/logstash" .
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

base=$(dirname $(readlink -f "$0"))
work="$base/work"
download="$base/download"
upstream="$base/upstream"

set -e
set -x

clean
get
package_logstash
package_grok
