#!/bin/bash
# scan.sh - סריקות אבטחה בסיסיות

CHANGED_SERVICES=$1

for service in $CHANGED_SERVICES; do
  echo "Scanning $service..."
  if [ -f "$service/package.json" ]; then
    cd $service
    npm audit
    cd -
  elif [ -f "$service/requirements.txt" ]; then
    cd $service
    bandit -r .
    cd -
  fi
done
