#!/usr/bin/env bash
set -e

# 1. Force the script to run relative to its own location
cd "$(dirname "$0")"

# 2. Check if .env actually exists before trying to read it
if [ ! -f .env ]; then
  echo "❌ Error: .env file missing in $(pwd)" >&2
  exit 1
fi

# 3. Load the environment variables safely
echo "📝 Loading environment variables..."
while IFS= read -r line || [ -n "$line" ]; do
  # Skip comments and empty lines
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line//[[:space:]]/}" ]] && continue
  
  # Export the variable
  export "$line"
done < .env

echo "🚀 Starting incremental backup via Borgmatic..."

# 4. Run borgmatic pointing directly to your local config file
borgmatic create -c ./borgmatic.yaml --verbosity 1

echo "✅ Backup sequence completed successfully!"