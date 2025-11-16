#!/bin/bash
# lint.sh - מריץ בדיקות קוד לכל שירות שהשתנה

CHANGED_SERVICES=$1  # רשימת תיקיות שהשתנו

for service in $CHANGED_SERVICES; do
  echo "Linting $service..."
  if [ -f "$service/package.json" ]; then
    cd $service
    npm install
    npm run lint
    cd -
  elif [ -f "$service/requirements.txt" ]; then
    cd $service
    pip install -r requirements.txt
    flake8 .
    cd -
  elif [ -f "$service/go.mod" ]; then
    cd $service
    golangci-lint run
    cd -
  fi
done
