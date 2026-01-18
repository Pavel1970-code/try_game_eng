#!/bin/bash

# Script to create GitHub repository and push code
# Replace YOUR_GITHUB_USERNAME with your actual GitHub username
# Replace YOUR_GITHUB_TOKEN with your personal access token (if using API method)

GITHUB_USERNAME="${GITHUB_USERNAME:-YOUR_GITHUB_USERNAME}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_NAME="try-game-eng"

echo "Creating GitHub repository: $REPO_NAME"

# Method 1: Try using GitHub API (requires token)
if [ -n "$GITHUB_TOKEN" ] && [ "$GITHUB_USERNAME" != "YOUR_GITHUB_USERNAME" ]; then
    echo "Attempting to create repository via GitHub API..."
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/repos \
        -d "{\"name\":\"$REPO_NAME\",\"public\":true,\"auto_init\":false}")
    
    http_code=$(echo "$response" | tail -n1)
    if [ "$http_code" = "201" ]; then
        echo "✓ Repository created successfully via API!"
        REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    else
        echo "API creation failed (HTTP $http_code). Please create manually."
        exit 1
    fi
else
    echo "GitHub token not provided. Please create the repository manually:"
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: $REPO_NAME"
    echo "3. Visibility: Public"
    echo "4. DO NOT check README, .gitignore, or license"
    echo "5. Click 'Create repository'"
    echo ""
    read -p "Press Enter after you've created the repository..."
    REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
fi

# Add remote and push
echo ""
echo "Setting up remote and pushing code..."
git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"
git branch -M main
git push -u origin main

echo ""
echo "✓ Done! Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
