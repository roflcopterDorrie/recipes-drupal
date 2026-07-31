#!/usr/bin/env bash
echo "🚀 Starting incremental backup via Borgmatic..."

# 4. Run borgmatic pointing directly to your local config file
borgmatic create -c ./borgmatic.yaml --verbosity 2

echo "✅ Backup sequence completed successfully!"