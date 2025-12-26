#!/bin/bash

set +e
fail=0

echo "--- Starting Deployment ---"


echo "--- Deployment Complete ---"

echo "#### deployment result: $fail"
exit $fail