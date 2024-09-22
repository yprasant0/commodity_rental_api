#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rental_solution/tmp/pids/server.pid

# Wait for PostgreSQL
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
