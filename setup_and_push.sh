#!/bin/bash
# Replace YOUR_GITHUB_USERNAME with your actual GitHub username

if [ "$1" = "" ]; then
    echo "Usage: ./setup_and_push.sh YOUR_GITHUB_USERNAME"
    echo ""
    echo "First, create the repository on GitHub:"
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: try-game-eng"
    echo "3. Visibility: Public"
    echo "4. DO NOT check README, .gitignore, or license"
    echo "5. Click 'Create repository'"
    echo ""
    echo "Then run: ./setup_and_push.sh YOUR_GITHUB_USERNAME"
    exit 1
fi

GITHUB_USERNAME=$1
REPO_URL="https://github.com/$GITHUB_USERNAME/try-game-eng.git"

echo "Setting up remote: $REPO_URL"
git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"

echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "✓ Done! Repository: https://github.com/$GITHUB_USERNAME/try-game-eng"
