#!/usr/bin/env bash

set +e
set -o pipefail
fail=0

echo "--- Starting Deployment ---"


echo "--- Deployment Complete ---"

echo "#### deployment result: $fail"
exit $fail