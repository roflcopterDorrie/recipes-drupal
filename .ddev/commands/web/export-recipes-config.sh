#!/bin/bash



# Export all config first
drush cex -y

DEST="web/modules/contrib/recipes/config/install"

echo "✅ Exported config"

# Ensure destination exists
mkdir -p "$DEST"

# Remove existing config.
rm -f "$DEST"/*.yml

echo "✅ Deleted existing config files"

# Copy only config with enforced dependency on "recipes"
for file in config/sync/*.yml; do
  if grep -A5 "enforced:" "$file" | grep -q "recipes"; then
    cp "$file" "$DEST"
  fi
done

cp config/sync/recipes.settings.yml "$DEST"

# Clear out the config folder.
rm -f config/sync/*.yml

echo "✅ Copied config files"

# Remove uuid lines.
sed -i '/^uuid:/d' "$DEST"/*.yml

echo "✅ Removed UUID"


# Remove default_config_hash
sed -i '/default_config_hash:/d' "$DEST"/*.yml

echo "✅ Removed default_config_hash"

echo "✅ Done"
