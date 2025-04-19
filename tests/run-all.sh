#!/bin/sh
set -e
lune run tests/messaging-service-v1.lune.luau
lune run tests/publish-place.lune.luau
