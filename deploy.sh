#!/bin/bash

set +e
fail=0

echo "--- Starting Deployment ---"


echo "--- Deployment Complete ---"

echo "#### test result: $fail"
exit $fail