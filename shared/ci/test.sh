#!/bin/bash
# test.sh - מריץ בדיקות יחידה לכל שירות שהשתנה

CHANGED_SERVICES=$1

for service in $CHANGED_SERVICES; do
  echo "Testing $service..."
  if [ -f "$service/package.json" ]; then
    cd $service
    npm test
    cd -
  elif [ -f "$service/requirements.txt" ]; then
    cd $service
    pytest
    cd -
  elif [ -f "$service/go.mod" ]; then
    cd $service
    go test ./...
    cd -
  fi
done
