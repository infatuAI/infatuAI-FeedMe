#!/bin/bash
#set -e
mix local.hex --force
mix local.rebar --force
mix phx.gen.cert

# Install deps
mix deps.get

# Install npm deps
cd assets && npm install
cd ..

echo PGPASSWORD=${POSTGRES_PASS} psql -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -c '\q'
PGPASSWORD=${POSTGRES_PASS} psql -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -c '\q'

# Waiting for postgis
until PGPASSWORD=${POSTGRES_PASS} psql -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is loading..."
  sleep 1
done

echo "\nPostgres is up."

# Create and migrate db if needed
mix ecto.create
mix ecto.migrate

echo "\nTest the installation..."
MIX_ENV=test mix test

echo "\nLaunching Phoenix webserver..."
mix phx.server
