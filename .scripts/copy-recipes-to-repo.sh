#!/bin/bash

rsync -av --delete --exclude='.git/' --exclude='node_modules/' web/modules/contrib/recipes/ ../recipes/

echo "✅ Copied"