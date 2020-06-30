#!/usr/bin/env bash
# exit on error
set -o errexit

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
cd assets
npm install --prefix 
npm run deploy --prefix
cd ..
mix phx.digest

# Remove the existing release directory and build the release
MIX_ENV=prod mix release --overwrite