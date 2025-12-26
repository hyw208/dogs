#!/bin/bash

# if you want any test failure to fail all, use set -e, otherwise we will collect all failures using +e
set +e
fail=0

echo "--- Starting E2E Testing ---"

curl -f http://localhost:8000/api/health || fail=1
curl -f http://localhost:8000/api/health || fail=1
curl -f http://localhost:8000/api/health || fail=1

# python test_e2e_2.py || fail=1

echo "--- E2E Testing Complete ---"

echo "#### test result: $fail"
exit $fail