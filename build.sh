#!/bin/bash

docker build \
  --no-cache \
  --platform linux/arm/v7 \
  -f docker/8.4/Dockerfile \
  -t plasmasoftuk/speedtest-tracker:armv7 \
  .
