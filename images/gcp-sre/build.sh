#!/bin/bash
docker build --no-cache -t gcp-sre .
docker tag gcp-sre northamerica-northeast1-docker.pkg.dev/c4hnrd-tools/cicd-repo/gcp-sre:latest
docker push northamerica-northeast1-docker.pkg.dev/c4hnrd-tools/cicd-repo/gcp-sre:latest
