# GitHub Repository Setup

## Quick Setup (30 seconds)

1. Go to: https://github.com/new
2. Repository name: `try-game-eng`
3. Visibility: **Public**
4. **DO NOT** check:
   - ❌ Add a README file
   - ❌ Add .gitignore
   - ❌ Choose a license
5. Click **"Create repository"**

## After creating the repository

Run this command (replace YOUR_USERNAME with your GitHub username):

```bash
git remote add origin https://github.com/YOUR_USERNAME/try-game-eng.git
git push -u origin main
```

Or use the provided script:
```bash
export GITHUB_USERNAME=YOUR_USERNAME
./create_github_repo.sh
```
