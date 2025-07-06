# Search1API MCP Server

[中文文档](./README_zh.md)

A Model Context Protocol (MCP) server that provides search and crawl functionality using Search1API.

https://github.com/user-attachments/assets/58bc98ae-3b6b-442c-a7fc-010508b5f028

More discussions and updates, please follow our official [X](https://x.com/search1api), or join the official [discord](https://discord.com/invite/AKXYq32Bxc)

## Features

- Web search functionality
- News search functionality
- Web page content extraction
- Website sitemap extraction
- Deep thinking and complex problem solving with DeepSeek R1
- Seamless integration with Claude Desktop, Cursor, Windsurf, Cline and other MCP clients

## Tools

### 1. Search Tool
- Name: `search`
- Description: Search the web using Search1API
- Parameters:
  * `query` (required): Search query in natural language. Be specific and concise for better results
  * `max_results` (optional, default: 10): Number of results to return
  * `search_service` (optional, default: "google"): Search service to use (google, bing, duckduckgo, yahoo, x, reddit, github, youtube, arxiv, wechat, bilibili, imdb, wikipedia)
  * `crawl_results` (optional, default: 0): Number of results to crawl for full webpage content
  * `include_sites` (optional): List of sites to include in search
  * `exclude_sites` (optional): List of sites to exclude from search
  * `time_range` (optional): Time range for search results ("day", "month", "year")

### 2. News Tool
- Name: `news`
- Description: Search for news articles using Search1API
- Parameters:
  * `query` (required): Search query in natural language. Be specific and concise for better results
  * `max_results` (optional, default: 10): Number of results to return
  * `search_service` (optional, default: "bing"): Search service to use (google, bing, duckduckgo, yahoo, hackernews)
  * `crawl_results` (optional, default: 0): Number of results to crawl for full webpage content
  * `include_sites` (optional): List of sites to include in search
  * `exclude_sites` (optional): List of sites to exclude from search
  * `time_range` (optional): Time range for search results ("day", "month", "year")

### 3. Crawl Tool
- Name: `crawl`
- Description: Extract content from a URL using Search1API
- Parameters:
  * `url` (required): URL to crawl

### 4. Sitemap Tool
- Name: `sitemap`
- Description: Get all related links from a URL
- Parameters:
  * `url` (required): URL to get sitemap

### 5. Reasoning Tool
- Name: `reasoning`
- Description: A tool for deep thinking and complex problem solving with fast deepseek r1 model and web search ability(You can change to any other model in search1api website but the speed is not guaranteed)
- Parameters:
  * `content` (required): The question or problem that needs deep thinking

### 6. Trending Tool
- Name: `trending`
- Description: Get trending topics from popular platforms
- Parameters:
  * `search_service` (required): Specify the platform to get trending topics from (github, hackernews)
  * `max_results` (optional, default: 10): Maximum number of trending items to return

## Setup Guide

### 1. Get Search1API Key
1. Register at [Search1API](https://www.search1api.com/?utm_source=mcp)
2. Get your api key and 100 free credits

### 2. Configure 

```json
{
  "mcpServers": {
    "search1api": {
      "command": "npx",
      "args": ["-y", "search1api-mcp"],
      "env": {
        "SEARCH1API_KEY": "YOUR_SEARCH1API_KEY"
      }
    }
  }
}
```

## Version History

- v0.1.8: Added X(Twitter) and Reddit search services
- v0.1.7: Added Trending tool for GitHub and Hacker News
- v0.1.6: Added Wikipedia search service
- v0.1.5: Added new search parameters (include_sites, exclude_sites, time_range) and new search services (arxiv, wechat, bilibili, imdb)
- v0.1.4: Added reasoning tool with deepseek r1 and updated the Cursor and Windsurf configuration guide
- v0.1.3: Added news search functionality
- v0.1.2: Added sitemap functionality
- v0.1.1: Added web crawling functionality
- v0.1.0: Initial release with search functionality

## License

This project is licensed under the MIT License - see the LICENSE file for details.
