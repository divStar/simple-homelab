#!/bin/bash

# Configuration
ZITADEL_DOMAIN="zitadel.my.world"
CLIENT_ID="$(tofu output -raw client_id)"
CLIENT_SECRET="$(tofu output -raw client_secret)"
REDIRECT_URI="https://portainer.my.world/"

# Step 1: Get authorization code (you'll need to do this manually in browser)
echo "Visit this URL in your browser:"
echo "https://${ZITADEL_DOMAIN}/oauth/v2/authorize?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&response_type=code&scope=openid+email+profile+urn:zitadel:iam:org:project:id:zitadel:aud"
echo ""
echo "After logging in, copy the 'code' parameter from the redirect URL and paste it here:"
read -r AUTH_CODE

# Step 2: Exchange code for tokens
echo ""
echo "Exchanging authorization code for tokens..."
TOKEN_RESPONSE=$(curl -s -X POST "https://${ZITADEL_DOMAIN}/oauth/v2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -u "${CLIENT_ID}:${CLIENT_SECRET}" \
  -d "grant_type=authorization_code&code=${AUTH_CODE}&redirect_uri=${REDIRECT_URI}")

echo ""
echo "=== TOKEN RESPONSE ==="
echo "$TOKEN_RESPONSE" | jq '.'

# Extract tokens
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')
ID_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.id_token')

echo ""
echo "=== DECODED ID TOKEN ==="
echo "$ID_TOKEN" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq '.'

echo ""
echo "=== DECODED ACCESS TOKEN ==="
echo "$ACCESS_TOKEN" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq '.'

# Step 3: Call userinfo endpoint
echo ""
echo "=== USERINFO ENDPOINT RESPONSE ==="
curl -s -X GET "https://${ZITADEL_DOMAIN}/oidc/v1/userinfo" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" | jq '.'