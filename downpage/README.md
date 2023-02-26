
[![img](https://img.shields.io/badge/Lifecycle-Stable-97ca00)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

---
description: BC Registries and Online Services emergency downpage ui
ignore: true
---

## About

Downpage ui is an application that can prevent users from accessing the BC Registries and Online Services application during an emergency or maintenance period.

## Usage

### Turn on Downpage UI
oc get route bc-registry-search-dev

oc patch route bc-registry-search-dev -p '{"spec": {"to": {"name": "downpage-dev"}, "port": {"targetPort": "downpage-dev-tcp"}}}'

### Turn off Downpage UI
oc get route bc-registry-search-dev

oc patch route bc-registry-search-dev -p '{"spec": {"to": {"name": "search-web-dev"}, "port": {"targetPort": "search-web-dev-tcp"}}}'


### firebase
firebase emulators:start

