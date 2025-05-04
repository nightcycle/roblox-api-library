#!/bin/sh
set -e
lune run tests/assets-v1.lune.luau
lune run tests/ordered-datastores-v1.lune.luau
lune run tests/standard-datastores-v1.lune.luau
lune run tests/messaging-service-v1.lune.luau
lune run tests/publish-place-v1.lune.luau
lune run tests/luau-execution-v2.lune.luau
lune run tests/instances-v2.lune.luau