# MCP Server Usage Rules

## Serena MCP Server Integration

**MANDATORY RULE**: For every task assigned, you MUST utilize the Serena MCP server tools when available and appropriate. The Serena MCP server is installed at `C:\Users\david\Documents\Cline\MCP\serena\` and provides advanced coding assistance capabilities.

### When to Use Serena MCP Server

1. **Code Analysis Tasks**: Use Serena tools for code review, refactoring suggestions, and code quality analysis
2. **Debugging Tasks**: Leverage Serena's debugging and error analysis capabilities
3. **Documentation Tasks**: Use Serena for generating documentation, comments, and code explanations
4. **Testing Tasks**: Apply Serena tools for test generation and test coverage analysis
5. **Architecture Tasks**: Utilize Serena for design pattern suggestions and architectural improvements
6. **Performance Tasks**: Use Serena for performance analysis and optimization recommendations

### How to Access Serena Tools

The Serena MCP server can be invoked using the `use_mcp_tool` function with server name "serena". If Serena is not currently connected in the MCP client configuration, you should:

1. First attempt to use the tool
2. If connection fails, note that Serena needs to be configured in the MCP client
3. Continue with the task using available tools while noting the Serena requirement

### Integration Priority

- **Primary**: Use Serena tools as the first approach for supported tasks
- **Fallback**: If Serena is unavailable, use standard tools as backup
- **Documentation**: Always document when Serena tools are used or when they're unavailable

### Configuration Requirements

To ensure Serena is always available:
- Serena MCP server should be running at `C:\Users\david\Documents\Cline\MCP\serena\`
- MCP client configuration should include Serena server connection
- Regular verification of Serena server status is recommended

**CRITICAL**: This rule takes precedence over all other tool selection guidelines. Always attempt to use Serena MCP server tools first for applicable tasks.