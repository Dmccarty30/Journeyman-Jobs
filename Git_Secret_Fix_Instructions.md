# Instructions for Coding Assistant: Fix Git Secret Scanning Error

## Problem Summary
The user cannot push to GitHub due to GitHub's secret scanning detecting API keys in the `.mcp.json` file. The following secrets were detected:
- Figma Personal Access Token
- Anthropic API Key  
- OpenAI API Key

## Task for Coding Assistant
Execute the following steps in exact order to resolve this issue:

## Step 1: Locate and Examine the Problem File
```bash
# Navigate to the project directory
cd C:\Users\david\Desktop\UI

# Examine the .mcp.json file to see current structure
cat .mcp.json
```

## Step 2: Create Environment Variables Setup
```bash
# Create a .env file for storing actual secrets
touch .env

# Add the following content to .env file (replace with actual values from .mcp.json):
echo "FIGMA_TOKEN=actual_figma_token_from_mcp_json" >> .env
echo "ANTHROPIC_API_KEY=actual_anthropic_key_from_mcp_json" >> .env  
echo "OPENAI_API_KEY=actual_openai_key_from_mcp_json" >> .env
```

## Step 3: Update .gitignore
```bash
# Add .env to .gitignore to prevent future commits of secrets
echo ".env" >> .gitignore
echo "*.env" >> .gitignore
```

## Step 4: Modify .mcp.json File
Replace all actual API keys in `.mcp.json` with placeholder text:
- Replace actual Figma token with: `"YOUR_FIGMA_TOKEN_HERE"`
- Replace actual Anthropic key with: `"YOUR_ANTHROPIC_API_KEY_HERE"`
- Replace actual OpenAI key with: `"YOUR_OPENAI_API_KEY_HERE"`

## Step 5: Commit the Changes
```bash
# Add all modified files
git add .

# Commit with descriptive message
git commit --amend -m "Remove API keys and add environment variable placeholders"
```

## Step 6: Force Push to Overwrite History
```bash
# Force push to overwrite the remote history containing secrets
git push --force origin main
```

## Step 7: Verify Success
```bash
# Attempt a normal push to confirm the issue is resolved
git push origin main
```

## Step 8: Security Cleanup (Critical)
After successful push, the user MUST:
1. Rotate/regenerate all exposed API keys:
   - Generate new Figma Personal Access Token
   - Generate new Anthropic API Key
   - Generate new OpenAI API Key
2. Update the `.env` file with new keys
3. Test application functionality with new keys

## Expected Outcome
- Secrets removed from git history
- GitHub push protection satisfied
- Application can still function using environment variables
- Future commits won't contain hardcoded secrets

## Fallback Option
If force push fails, the coding assistant should:
1. Create a completely new repository on GitHub
2. Copy code files (excluding .git folder)
3. Initialize fresh git repository
4. Commit clean code without secrets
5. Push to new repository

## Notes for Coding Assistant
- Do NOT attempt to edit commit history with complex git operations
- Force push is acceptable here since it's removing sensitive data
- Verify each step completes successfully before proceeding
- If any step fails, report the exact error message