#!/usr/bin/env bash

directories="reflutter reflutter_generator reflutter_test"
parent_directory=$PWD

mkdir -p .pub-cache

cat <<EOF > ~/.pub-cache/credentials.json
{
  "accessToken":"$accessToken",
  "refreshToken":"$refreshToken",
  "tokenEndpoint":"$tokenEndpoint",
  "scopes":["$scopes"],
  "expiration":$expiration
}
EOF

for directory in $directories; do
  echo
  echo "*** Publishing $directory..."
  echo
  cd "$parent_directory/$directory"

  pub publish -f
done
