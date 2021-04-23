#!/bin/bash

function cf_outputs_get {
  key="$1"
  echo $(jq -r ".[] | select(.OutputKey == \"$key\").OutputValue" ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')
}