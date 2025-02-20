#!/bin/bash
docker build --no-cache -t postgres15-postgis-anon .
docker tag postgres15-postgis-anon ghcr.io/bcgov/postgres15-postgis-anon:latest
docker push ghcr.io/bcgov/postgres15-postgis-anon:latest
