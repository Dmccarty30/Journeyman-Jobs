# SECURITY ALERT: API Key Rotation Required

## ⚠️ IMMEDIATE ACTION REQUIRED ⚠️

The following API keys were previously exposed in the git repository and **MUST** be rotated immediately:

### 🔐 Keys That Need Rotation:

1. **Brave Search API Key**
   - Previous value: `BSAYbBwe8YXBcFOibs-LlyE6NOZpOzD`
   - Action: Generate new key at [Brave Search API Console](https://api.search.brave.com/)

2. **Bright Data API Token**
   - Previous value: `b3eb2cca-6d1e-41a8-950c-65399c518794`
   - Action: Generate new token in Bright Data dashboard

3. **Firecrawl API Key**
   - Previous value: `fc-c99dfdb07ed747a49d22fc4c1c6bbafc`
   - Action: Generate new key at [Firecrawl Dashboard](https://firecrawl.dev/)

4. **Perplexity API Key**
   - Previous value: `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`
   - Action: Generate new key at [Perplexity Console](https://perplexity.ai/)

5. **Anthropic API Key**
   - Previous value: `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`
   - Action: Generate new key at [Anthropic Console](https://console.anthropic.com/)

6. **OpenAI API Key**
   - Previous value: `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`
   - Action: Generate new key at [OpenAI Platform](https://platform.openai.com/api-keys)

7. **Google API Key**
   - Previous value: `AIzaSyAe7bb3l1oO32kXkU3u2ElVZbvJ7YZndVo`
   - Action: Generate new key at [Google Cloud Console](https://console.cloud.google.com/)

8. **Mistral API Key**
   - Previous value: `7wEeSRggnOQzxcXq4H7qD3MjId861XAZ`
   - Action: Generate new key at [Mistral Console](https://console.mistral.ai/)

9. **OpenRouter API Key**
   - Previous value: `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`
   - Action: Generate new key at [OpenRouter](https://openrouter.ai/)

10. **xAI API Key**
    - Previous value: `xai-QaXHssUUBlPdtoZhbwY9Ap8AFYOEFWKygipNvGu53ovPk3hYNmH8OeT2ZbmJ479UQa56o1N95ArArGGd`
    - Action: Generate new key at [xAI Console](https://console.x.ai/)

11. **21st Dev Magic API Key**
    - Previous value: `754cfc699bd42499f043152c872af4cc39022bdbbf7e9db980cf2c038c09b029`
    - Action: Generate new key at 21st Dev platform

12. **Smithery CLI Key**
    - Previous value: `ced69534-0894-4d1e-b727-c826bc7ce45c`
    - Action: Generate new key at Smithery platform

13. **Figma API Key**
    - Previous value: `figd_xDJ3gNwBtU0GlOP0vvLe8Xb6xxVVdzB67iFZ10iL`
    - Action: Generate new token at [Figma Developers](https://www.figma.com/developers/api)

14. **AgentR API Key**
    - Previous value: `sk_0e4dcdc3-3fb3-4290-850e-6190f1c54501`
    - Action: Generate new key at AgentR platform

## 📋 Steps to Complete:

1. **Rotate all API keys** listed above by generating new ones from their respective consoles
2. **Update the `.env` file** with the new API keys
3. **Test all MCP servers** to ensure they work with new keys
4. **Delete this file** once rotation is complete

## ✅ Remediation Completed:

- [x] API keys removed from git repository
- [x] `.mcp.json` sanitized with environment variable references
- [x] `.env` file created with secure key storage
- [x] `.gitignore` updated to prevent future exposure
- [x] Commit history cleaned (amended commit to remove secrets)

## 🛡️ Security Measures in Place:

- All API keys now use environment variable references: `${KEY_NAME}`
- `.env` file is properly gitignored
- Backup of original configuration saved as `.mcp.json.backup` (also gitignored)

## ⏰ Timeline:

- **Detected**: GitHub secret scanning blocked push
- **Fixed**: 2025-07-11 (secrets removed from repository)
- **Rotation Required**: IMMEDIATELY

## 🔒 Security Best Practices Going Forward:

1. Never commit API keys directly in configuration files
2. Always use environment variables for sensitive data
3. Regularly rotate API keys as a security practice
4. Monitor for any unauthorized usage of the old keys
5. Consider using secret management tools for production deployments

---

**Status**: 🚨 **CRITICAL - API Key Rotation Pending** 🚨