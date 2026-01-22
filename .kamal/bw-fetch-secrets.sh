#!/usr/bin/env bash
# Fetch secrets from Bitwarden and create shell-sourceable files for Kamal deployments
# Usage: .kamal/bw-fetch-secrets.sh [staging|production|all]

set -e

ENVIRONMENT=${1:-all}

echo "🔐 Bitwarden Secret Fetcher"
echo "============================"
echo ""

# Check if bw CLI is installed
if ! command -v bw &> /dev/null; then
    echo "❌ Error: Bitwarden CLI (bw) is not installed"
    echo "Install with: brew install bitwarden-cli"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is not installed"
    echo "Install with: brew install jq"
    exit 1
fi

# Check Bitwarden status
BW_STATUS=$(bw status | jq -r '.status')

if [ "$BW_STATUS" = "unauthenticated" ]; then
    echo "📧 Logging in to Bitwarden..."
    bw login
    BW_STATUS=$(bw status | jq -r '.status')
fi

# Unlock Bitwarden if needed
if [ "$BW_STATUS" = "locked" ]; then
    echo "🔓 Unlocking Bitwarden..."
    
    # Try to get password from macOS Keychain
    if command -v security &>/dev/null; then
        BW_PASSWORD=$(security find-generic-password -a "$USER" -s "bitwarden-master-password" -w 2>/dev/null || echo "")
        
        if [ -n "$BW_PASSWORD" ]; then
            echo "🔑 Using password from macOS Keychain..."
            export BW_SESSION=$(bw unlock "$BW_PASSWORD" --raw 2>/dev/null)
        fi
    fi
    
    # Manual unlock if Keychain didn't work
    if [ -z "$BW_SESSION" ]; then
        export BW_SESSION=$(bw unlock --raw)
    fi
fi

# Verify we're unlocked
if ! bw unlock --check &>/dev/null; then
    echo "❌ Failed to unlock Bitwarden"
    exit 1
fi

echo "✅ Bitwarden unlocked successfully"
echo ""

# Function to create common secrets file
create_common_secrets() {
    local secrets_file=".kamal/secrets-common.local"
    
    echo "📝 Creating ${secrets_file}..."
    
    cat > "$secrets_file" << EOF
# ⚠️  Auto-generated from Bitwarden - DO NOT COMMIT (gitignored)
# Generated at: $(date)
# Run .kamal/bw-fetch-secrets.sh to regenerate

# Docker Registry credentials (shared between staging and production)
EOF
    
    REGISTRY_USER=$(bw get item kw-app-production-docker-registry --session "$BW_SESSION" | jq -r '.login.username')
    REGISTRY_PASS=$(bw get item kw-app-production-docker-registry --session "$BW_SESSION" | jq -r '.login.password')
    
    echo "KAMAL_REGISTRY_USERNAME=$REGISTRY_USER" >> "$secrets_file"
    echo "KAMAL_REGISTRY_PASSWORD=$REGISTRY_PASS" >> "$secrets_file"
    
    echo "✅ Created ${secrets_file}"
}

# Function to fetch and create environment-specific secrets file
create_secrets_file() {
    local env=$1
    local secrets_file=".kamal/secrets.${env}.local"
    
    echo "📝 Creating ${secrets_file}..."
    
    # Start with header
    # Capitalize environment name
    local env_cap=$(echo "$env" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
    
    cat > "$secrets_file" << EOF
# ⚠️  Auto-generated from Bitwarden - DO NOT COMMIT (gitignored)
# Generated at: $(date)
# Run .kamal/bw-fetch-secrets.sh to regenerate

# $env_cap environment secrets
EOF
    
    RAILS_KEY=$(bw get item "kw-app-${env}-master-key" --session "$BW_SESSION" | jq -r '.notes')
    POSTGRES_PASS=$(bw get item "kw-app-${env}-database-bootstrap" --session "$BW_SESSION" | jq -r '.login.password')
    REDIS_PASS=$(bw get item "kw-app-${env}-redis-bootstrap" --session "$BW_SESSION" | jq -r '.login.password')
    
    echo "RAILS_MASTER_KEY=$RAILS_KEY" >> "$secrets_file"
    echo "POSTGRES_PASSWORD=$POSTGRES_PASS" >> "$secrets_file"
    echo "REDIS_PASSWORD=$REDIS_PASS" >> "$secrets_file"
    
    echo "✅ Created ${secrets_file}"
}

# Create common secrets file first
create_common_secrets
echo ""

# Fetch secrets based on argument
if [ "$ENVIRONMENT" = "all" ]; then
    create_secrets_file "staging"
    create_secrets_file "production"
elif [ "$ENVIRONMENT" = "staging" ] || [ "$ENVIRONMENT" = "production" ]; then
    create_secrets_file "$ENVIRONMENT"
else
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Usage: $0 [staging|production|all]"
    exit 1
fi

echo ""
echo "✅ Done! Your secrets are stored in .kamal/secrets.*.local files"
echo ""
echo "Kamal will automatically load these local files when you deploy:"
echo "  kamal deploy -d staging"
echo "  kamal deploy -d production"
echo ""
echo "⚠️  These .local files are in .gitignore - don't commit them!"