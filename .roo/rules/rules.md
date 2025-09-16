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
7. **Search and Symbol Exploration**: Use Serena's powerful search capabilities (`search_for_pattern`, `find_symbol`, `get_symbols_overview`) for efficient codebase exploration. Prioritize symbolic tools (`find_symbol`, `find_referencing_symbols`) over reading entire files to maintain token efficiency
8. **Targeted Code Reading**: Use Serena's `get_symbols_overview` first to understand file structure, then `find_symbol` with `include_body=true` for specific symbols only. Avoid reading entire files unless absolutely necessary
9. **Symbol-Based Editing**: Use Serena's `replace_symbol_body`, `insert_after_symbol`, `insert_before_symbol` tools for precise, resource-efficient code modifications instead of full file rewrites
10. **Cross-Reference Analysis**: Use Serena's `find_referencing_symbols` to understand symbol relationships and maintain backward compatibility when editing
11. **Resource-Efficient Approach**: Follow Serena's philosophy of avoiding unnecessary code reading. Use step-by-step acquisition of information rather than reading entire files. If you already read a file, don't re-analyze it with symbolic tools
12. **Editing Strategy Selection**: Use symbol-based editing for entire symbols (methods, classes, functions). Use regex-based editing for small changes within symbols. Never read entire files unless absolutely necessary (as a last resort)

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
