#!/usr/bin/env bash
mkdir -p .pub-cache

if [ "$TRAVIS_BRANCH" == "release" ]; then
  cat <<EOF > ~/.pub-cache/credentials.json
{
  "accessToken":"$accessToken",
  "refreshToken":"$refreshToken",
  "tokenEndpoint":"$tokenEndpoint",
  "scopes":["$scopes"],
  "expiration":$expiration
}
EOF

  pub publish -f
fi