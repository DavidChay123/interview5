#!/bin/bash
git fetch origin main
CHANGED_FILES=$(git diff --name-only origin/main)
CHANGED_SERVICES=$(echo "$CHANGED_FILES" | grep '/' | cut -d/ -f1 | sort | uniq)
echo "${CHANGED_SERVICES[@]}"
