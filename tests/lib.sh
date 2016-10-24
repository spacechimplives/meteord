#!/bin/sh

doalarm () { perl -e 'alarm shift; exec @ARGV' "$@"; }

watch_token="=====METEORD_TEST====="

add_binary_dependency () {
  meteor add npm-bcrypt
  meteor npm install bcrypt --save
  cat <<EOM >> ${1:-"server/main.js"}
    require('meteor/meteor').Meteor.startup(() => {
      console.log('bcrypt', require('bcrypt').hashSync("asdf", 10));
    });
EOM
}

add_watch_token () {
  cat <<EOM >> ${1:-"server/main.js"}
    require('meteor/meteor').Meteor.startup(() => console.log('$watch_token'));
EOM
}

docker_logs_has () {
  docker logs "$1" | grep "$2"
}

watch_docker_logs_for () {
  docker logs -f "$1" | grep --line-buffered -m1 "$2"
}

watch_docker_logs_for_app_ready () {
  watch_docker_logs_for "$1" "=> Starting meteor app on port"
}

watch_docker_logs_for_token () {
  watch_docker_logs_for "$1" "${watch_token}"
}

check_server_for () {
  curl -s "http://localhost:$1" | grep "${2}" 2>&1 > /dev/null
}
