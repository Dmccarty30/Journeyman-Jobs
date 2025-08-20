#!/usr/bin/env python3
"""
SuperClaude Command Explorer
An interactive tool to explore commands, flags, and their combinations with dynamic descriptions.
"""

import streamlit as st
import re
from typing import Dict, List, Optional, Tuple
import json

# Data structure to hold all command information
COMMANDS_DATA = {
    # Development Commands
    "/build": {
        "name": "Universal Project Builder",
        "base_description": "Build projects, features, and components using modern stack templates",
        "category": "Development",
        "specific_flags": {
            "--init": "Initialize new project with stack setup",
            "--feature": "Implement feature using existing patterns",
            "--tdd": "Test-driven development workflow",
            "--react": "React with Vite, TypeScript, Router",
            "--api": "Express.js API with TypeScript",
            "--fullstack": "Complete React + Node.js + Docker",
            "--mobile": "React Native with Expo",
            "--cli": "Commander.js CLI with testing"
        },
        "examples": [
            "/build --init --react --magic --tdd         # New React app with AI components",
            "/build --feature \"auth system\" --tdd        # Feature with tests",
            "/build --api --openapi --seq                # API with documentation"
        ]
    },
    "/dev-setup": {
        "name": "Development Environment",
        "base_description": "Configure professional development environments with CI/CD and monitoring",
        "category": "Development",
        "specific_flags": {
            "--install": "Install and configure dependencies",
            "--ci": "CI/CD pipeline configuration",
            "--monitor": "Monitoring and observability setup",
            "--docker": "Containerization setup",
            "--testing": "Testing infrastructure",
            "--team": "Team collaboration tools",
            "--standards": "Code quality standards"
        },
        "examples": [
            "/dev-setup --install --ci --monitor         # Complete environment",
            "/dev-setup --team --standards --docs        # Team setup"
        ]
    },
    "/test": {
        "name": "Comprehensive Testing Framework",
        "base_description": "Create, run, and maintain testing strategies across the stack",
        "category": "Development",
        "specific_flags": {
            "--e2e": "End-to-end testing",
            "--integration": "Integration testing",
            "--unit": "Unit testing",
            "--visual": "Visual regression testing",
            "--mutation": "Mutation testing",
            "--performance": "Performance testing",
            "--accessibility": "Accessibility testing",
            "--parallel": "Parallel test execution"
        },
        "examples": [
            "/test --coverage --e2e --pup               # Full test suite",
            "/test --mutation --strict                  # Test quality validation"
        ]
    },
    # Analysis & Improvement Commands
    "/review": {
        "name": "AI-Powered Code Review",
        "base_description": "Comprehensive code review and quality analysis with evidence-based recommendations",
        "category": "Analysis & Improvement",
        "specific_flags": {
            "--files": "Review specific files or directories",
            "--commit": "Review changes in specified commit (HEAD, hash, range)",
            "--pr": "Review pull request changes (git diff main..branch)",
            "--quality": "Focus on code quality issues (DRY, SOLID, complexity)",
            "--evidence": "Include sources and documentation for all suggestions",
            "--fix": "Suggest specific fixes for identified issues",
            "--summary": "Generate executive summary of review findings"
        },
        "examples": [
            "/review --files src/auth.ts --persona-security    # Security-focused file review",
            "/review --commit HEAD --quality --evidence        # Quality review with sources",
            "/review --pr 123 --all --interactive             # Comprehensive PR review"
        ]
    },
    "/analyze": {
        "name": "Multi-Dimensional Analysis",
        "base_description": "Comprehensive analysis of code, architecture, performance, and security",
        "category": "Analysis & Improvement",
        "specific_flags": {
            "--code": "Code quality analysis",
            "--architecture": "System design assessment",
            "--profile": "Performance profiling",
            "--deps": "Dependency analysis",
            "--surface": "Quick overview",
            "--deep": "Comprehensive analysis",
            "--forensic": "Detailed investigation"
        },
        "examples": [
            "/analyze --code --architecture --seq       # Full analysis",
            "/analyze --profile --deep --persona-performance  # Performance deep-dive"
        ]
    },
    "/troubleshoot": {
        "name": "Professional Debugging",
        "base_description": "Systematic debugging and issue resolution",
        "category": "Analysis & Improvement",
        "specific_flags": {
            "--investigate": "Systematic issue analysis",
            "--five-whys": "Root cause analysis",
            "--prod": "Production debugging",
            "--perf": "Performance investigation",
            "--fix": "Complete resolution",
            "--hotfix": "Emergency fixes",
            "--rollback": "Safe rollback"
        },
        "examples": [
            "/troubleshoot --prod --five-whys --seq    # Production RCA",
            "/troubleshoot --perf --fix --pup          # Performance fix"
        ]
    },
    "/improve": {
        "name": "Enhancement & Optimization",
        "base_description": "Evidence-based improvements with measurable outcomes",
        "category": "Analysis & Improvement",
        "specific_flags": {
            "--quality": "Code structure improvements",
            "--performance": "Performance optimization",
            "--accessibility": "Accessibility improvements",
            "--iterate": "Iterative improvement",
            "--threshold": "Quality target percentage",
            "--refactor": "Systematic refactoring",
            "--modernize": "Technology updates"
        },
        "examples": [
            "/improve --quality --iterate --threshold 95%    # Quality improvement",
            "/improve --performance --cache --pup            # Performance boost"
        ]
    },
    "/explain": {
        "name": "Technical Documentation",
        "base_description": "Generate comprehensive explanations and documentation",
        "category": "Analysis & Improvement",
        "specific_flags": {
            "--depth": "Complexity level (ELI5|beginner|intermediate|expert)",
            "--visual": "Include diagrams",
            "--examples": "Code examples",
            "--api": "API documentation",
            "--architecture": "System documentation",
            "--tutorial": "Learning tutorials",
            "--reference": "Reference docs"
        },
        "examples": [
            "/explain --depth expert --visual --seq     # Expert documentation",
            "/explain --api --examples --c7             # API docs with examples"
        ]
    },
    # Operations Commands
    "/deploy": {
        "name": "Application Deployment",
        "base_description": "Safe deployment with rollback capabilities",
        "category": "Operations",
        "specific_flags": {
            "--env": "Target environment (dev|staging|prod)",
            "--canary": "Canary deployment",
            "--blue-green": "Blue-green deployment",
            "--rolling": "Rolling deployment",
            "--checkpoint": "Create checkpoint",
            "--rollback": "Rollback to previous",
            "--monitor": "Post-deployment monitoring"
        },
        "examples": [
            "/deploy --env prod --canary --monitor      # Canary production deploy",
            "/deploy --rollback --env prod              # Emergency rollback"
        ]
    },
    "/migrate": {
        "name": "Database & Code Migration",
        "base_description": "Safe migrations with rollback capabilities",
        "category": "Operations",
        "specific_flags": {
            "--database": "Database migrations",
            "--code": "Code migrations",
            "--config": "Configuration migrations",
            "--dependencies": "Dependency updates",
            "--backup": "Create backup first",
            "--rollback": "Rollback migration",
            "--validate": "Data integrity checks"
        },
        "examples": [
            "/migrate --database --backup --validate    # Safe DB migration",
            "/migrate --code --dry-run                  # Preview code changes"
        ]
    },
    "/scan": {
        "name": "Security & Validation",
        "base_description": "Comprehensive security auditing and compliance",
        "category": "Operations",
        "specific_flags": {
            "--owasp": "OWASP Top 10 compliance",
            "--secrets": "Secret detection",
            "--compliance": "Regulatory compliance",
            "--quality": "Code quality validation",
            "--automated": "Continuous monitoring"
        },
        "examples": [
            "/scan --security --owasp --deps           # Security audit",
            "/scan --compliance --gdpr --strict        # Compliance check"
        ]
    },
    "/estimate": {
        "name": "Project Estimation",
        "base_description": "Professional estimation with risk assessment",
        "category": "Operations",
        "specific_flags": {
            "--detailed": "Comprehensive breakdown",
            "--rough": "Quick estimation",
            "--worst-case": "Pessimistic estimate",
            "--agile": "Story point estimation",
            "--complexity": "Technical assessment",
            "--resources": "Resource planning",
            "--timeline": "Timeline planning",
            "--risk": "Risk assessment"
        },
        "examples": [
            "/estimate --detailed --complexity --risk   # Full estimation",
            "/estimate --agile --story-points          # Agile planning"
        ]
    },
    "/cleanup": {
        "name": "Project Maintenance",
        "base_description": "Professional cleanup with safety validations",
        "category": "Operations",
        "specific_flags": {
            "--code": "Remove dead code",
            "--files": "Clean build artifacts",
            "--deps": "Remove unused dependencies",
            "--git": "Clean git repository",
            "--all": "Comprehensive cleanup",
            "--aggressive": "Deep cleanup",
            "--conservative": "Safe cleanup"
        },
        "examples": [
            "/cleanup --all --dry-run                  # Preview cleanup",
            "/cleanup --code --deps --validate         # Code cleanup"
        ]
    },
    "/git": {
        "name": "Git Workflow Management",
        "base_description": "Professional Git operations with safety features",
        "category": "Operations",
        "specific_flags": {
            "--status": "Repository status",
            "--commit": "Professional commit",
            "--branch": "Branch management",
            "--sync": "Remote synchronization",
            "--checkpoint": "Create checkpoint",
            "--merge": "Smart merge",
            "--history": "History analysis",
            "--pre-commit": "Setup and run pre-commit hooks"
        },
        "examples": [
            "/git --checkpoint \"before refactor\"       # Safety checkpoint",
            "/git --commit --validate --test          # Safe commit"
        ]
    },
    # Design & Architecture Commands
    "/design": {
        "name": "System Architecture",
        "base_description": "Professional system design with specifications",
        "category": "Design & Architecture",
        "specific_flags": {
            "--api": "REST/GraphQL design",
            "--ddd": "Domain-driven design",
            "--microservices": "Microservices architecture",
            "--event-driven": "Event patterns",
            "--openapi": "OpenAPI specs",
            "--graphql": "GraphQL schema",
            "--bounded-context": "DDD contexts",
            "--integration": "Integration patterns"
        },
        "examples": [
            "/design --api --ddd --openapi --seq      # API with DDD",
            "/design --microservices --event-driven   # Microservices design"
        ]
    },
    # Workflow Commands
    "/spawn": {
        "name": "Specialized Agents",
        "base_description": "Spawn focused agents for parallel tasks",
        "category": "Workflow",
        "specific_flags": {
            "--task": "Define specific task",
            "--parallel": "Concurrent execution",
            "--specialized": "Domain expertise",
            "--collaborative": "Multi-agent work",
            "--sync": "Synchronize results",
            "--merge": "Merge outputs"
        },
        "examples": [
            "/spawn --task \"frontend tests\" --parallel  # Parallel testing",
            "/spawn --collaborative --sync              # Team simulation"
        ]
    },
    "/document": {
        "name": "Documentation Creation",
        "base_description": "Professional documentation in multiple formats",
        "category": "Workflow",
        "specific_flags": {
            "--user": "User guides",
            "--technical": "Developer docs",
            "--markdown": "Markdown format",
            "--interactive": "Interactive docs",
            "--multilingual": "Multi-language",
            "--maintain": "Maintenance plan"
        },
        "examples": [
            "/document --api --interactive --examples   # API documentation",
            "/document --user --visual --multilingual   # User guides"
        ]
    },
    "/load": {
        "name": "Project Context Loading",
        "base_description": "Load and analyze project context",
        "category": "Workflow",
        "specific_flags": {
            "--depth": "Analysis depth (shallow|normal|deep)",
            "--context": "Context preservation",
            "--patterns": "Pattern recognition",
            "--relationships": "Dependency mapping",
            "--structure": "Project structure",
            "--health": "Project health",
            "--standards": "Coding standards"
        },
        "examples": [
            "/load --depth deep --patterns --seq       # Deep analysis",
            "/load --structure --health --standards   # Project assessment"
        ]
    },
    "/task": {
        "name": "Task Management",
        "base_description": "Complex feature management across sessions with automatic breakdown and recovery",
        "category": "Workflow",
        "specific_flags": {},
        "operations": {
            "/task:create": "Create new task with automatic breakdown",
            "/task:status": "Check task status and progress",
            "/task:resume": "Resume work after break",
            "/task:update": "Update task progress and requirements",
            "/task:complete": "Mark task as done with summary"
        },
        "examples": [
            "/task:create \"Implement OAuth 2.0 authentication system\"",
            "/task:status oauth-task-id",
            "/task:resume oauth-task-id"
        ]
    }
}

# Universal flags available for all commands
UNIVERSAL_FLAGS = {
    # Thinking Depth Control
    "--think": {
        "description": "Multi-file analysis with expanded context",
        "token_usage": "~4K tokens",
        "category": "Thinking Depth"
    },
    "--think-hard": {
        "description": "Architecture-level depth analysis",
        "token_usage": "~10K tokens",
        "category": "Thinking Depth"
    },
    "--ultrathink": {
        "description": "Critical system analysis with maximum depth",
        "token_usage": "~32K tokens",
        "category": "Thinking Depth"
    },
    # Token Optimization
    "--uc": {
        "description": "Activate UltraCompressed mode (huge token reduction)",
        "alias": "--ultracompressed",
        "category": "Token Optimization"
    },
    # MCP Server Control
    "--c7": {
        "description": "Enable Context7 documentation lookup",
        "category": "MCP Server"
    },
    "--seq": {
        "description": "Enable Sequential thinking analysis",
        "category": "MCP Server"
    },
    "--magic": {
        "description": "Enable Magic UI component generation",
        "category": "MCP Server"
    },
    "--pup": {
        "description": "Enable Puppeteer browser automation",
        "category": "MCP Server"
    },
    "--all-mcp": {
        "description": "Enable all MCP servers for maximum capability",
        "category": "MCP Server"
    },
    "--no-mcp": {
        "description": "Disable all MCP servers (native tools only)",
        "category": "MCP Server"
    },
    # Analysis & Introspection
    "--introspect": {
        "description": "Enable self-aware analysis with cognitive transparency",
        "category": "Analysis"
    },
    # Planning & Execution
    "--plan": {
        "description": "Show detailed execution plan before running",
        "category": "Planning"
    },
    "--dry-run": {
        "description": "Preview changes without execution",
        "category": "Planning"
    },
    "--watch": {
        "description": "Continuous monitoring with real-time feedback",
        "category": "Planning"
    },
    "--interactive": {
        "description": "Step-by-step guided process",
        "category": "Planning"
    },
    "--force": {
        "description": "Override safety checks (use with caution)",
        "category": "Planning"
    },
    # Quality & Validation
    "--validate": {
        "description": "Enhanced pre-execution safety checks",
        "category": "Quality"
    },
    "--security": {
        "description": "Security-focused analysis and validation",
        "category": "Quality"
    },
    "--coverage": {
        "description": "Generate comprehensive coverage analysis",
        "category": "Quality"
    },
    "--strict": {
        "description": "Zero-tolerance mode with enhanced validation",
        "category": "Quality"
    },
    # Persistence & Context
    "--remember": {
        "description": "Remember context across sessions",
        "category": "Context"
    },
    "--context": {
        "description": "Enhanced context awareness",
        "category": "Context"
    },
    "--session": {
        "description": "Session-specific context management",
        "category": "Context"
    },
    # Output Control
    "--verbose": {
        "description": "Detailed output with step-by-step progress",
        "category": "Output"
    },
    "--quiet": {
        "description": "Minimal output (errors only)",
        "category": "Output"
    },
    "--json": {
        "description": "JSON formatted output",
        "category": "Output"
    },
    "--markdown": {
        "description": "Markdown formatted output",
        "category": "Output"
    },
    # Performance
    "--parallel": {
        "description": "Execute tasks in parallel when possible",
        "category": "Performance"
    },
    "--cache": {
        "description": "Enable intelligent caching",
        "category": "Performance"
    },
    "--optimize": {
        "description": "Optimize for performance",
        "category": "Performance"
    },
    # Additional Quality Flags
    "--evidence": {
        "description": "Include sources and evidence for all claims",
        "category": "Quality"
    },
    "--best-practices": {
        "description": "Enforce industry best practices",
        "category": "Quality"
    },
    # Git/Version Control
    "--branch": {
        "description": "Specify git branch for operations",
        "category": "Version Control"
    },
    "--commit": {
        "description": "Reference specific commit or range",
        "category": "Version Control"
    },
    # Search & Filter
    "--files": {
        "description": "Target specific files or patterns",
        "category": "Search"
    },
    "--exclude": {
        "description": "Exclude files or patterns",
        "category": "Search"
    },
    "--depth": {
        "description": "Analysis depth level",
        "category": "Search"
    }
}

# Persona flags
PERSONA_FLAGS = {
    "--persona-architect": {
        "expertise": "Systems thinking, scalability, patterns",
        "best_for": "Architecture decisions, system design"
    },
    "--persona-frontend": {
        "expertise": "UI/UX obsessed, accessibility-first",
        "best_for": "User interfaces, component design"
    },
    "--persona-backend": {
        "expertise": "APIs, databases, reliability",
        "best_for": "Server architecture, data modeling"
    },
    "--persona-analyzer": {
        "expertise": "Root cause analysis, evidence-based",
        "best_for": "Complex debugging, investigations"
    },
    "--persona-security": {
        "expertise": "Threat modeling, zero-trust, OWASP",
        "best_for": "Security audits, vulnerability assessment"
    },
    "--persona-mentor": {
        "expertise": "Teaching, guided learning, clarity",
        "best_for": "Documentation, knowledge transfer"
    },
    "--persona-refactorer": {
        "expertise": "Code quality, maintainability",
        "best_for": "Code cleanup, technical debt"
    },
    "--persona-performance": {
        "expertise": "Optimization, profiling, efficiency",
        "best_for": "Performance tuning, bottlenecks"
    },
    "--persona-qa": {
        "expertise": "Testing, edge cases, validation",
        "best_for": "Quality assurance, test coverage"
    }
}

def generate_combined_description(command: str, flags: List[str], argument: str = "") -> str:
    """Generate a combined description based on selected command, flags, and argument."""
    if command not in COMMANDS_DATA:
        return "Invalid command selected."
    
    cmd_data = COMMANDS_DATA[command]
    description_parts = [f"**{cmd_data['name']}**: {cmd_data['base_description']}"]
    
    # Add command-specific flag descriptions
    for flag in flags:
        if flag in cmd_data.get("specific_flags", {}):
            description_parts.append(f"\n• **{flag}**: {cmd_data['specific_flags'][flag]}")
        elif flag in UNIVERSAL_FLAGS:
            flag_data = UNIVERSAL_FLAGS[flag]
            desc = f"\n• **{flag}** ({flag_data['category']}): {flag_data['description']}"
            if "token_usage" in flag_data:
                desc += f" [{flag_data['token_usage']}]"
            description_parts.append(desc)
        elif flag in PERSONA_FLAGS:
            persona_data = PERSONA_FLAGS[flag]
            description_parts.append(f"\n• **{flag}** (Persona): {persona_data['expertise']} - Best for: {persona_data['best_for']}")
    
    # Add argument context if provided
    if argument:
        description_parts.append(f"\n\n**Argument**: `{argument}`")
        description_parts.append(f"This will apply the above configuration to: {argument}")
    
    # Generate action summary
    action_summary = generate_action_summary(command, flags, argument)
    if action_summary:
        description_parts.append(f"\n\n**What this will do**: {action_summary}")
    
    return "\n".join(description_parts)

def generate_action_summary(command: str, flags: List[str], argument: str) -> str:
    """Generate a summary of what the command will actually do."""
    cmd_data = COMMANDS_DATA.get(command, {})
    action_parts = []
    
    # Base action from command
    if command == "/build":
        if "--init" in flags:
            action_parts.append("Initialize a new project")
        elif "--feature" in flags:
            action_parts.append(f"Implement feature: {argument}" if argument else "Implement a new feature")
        else:
            action_parts.append("Build the project")
            
        # Add stack details
        for stack in ["--react", "--api", "--fullstack", "--mobile", "--cli"]:
            if stack in flags:
                action_parts.append(f"using {stack[2:].capitalize()} stack")
                break
    
    elif command == "/review":
        action_parts.append("Perform code review")
        if "--files" in flags and argument:
            action_parts.append(f"on {argument}")
        elif "--commit" in flags:
            action_parts.append("on commit changes")
        elif "--pr" in flags:
            action_parts.append("on pull request")
    
    elif command == "/analyze":
        aspects = []
        if "--code" in flags:
            aspects.append("code quality")
        if "--architecture" in flags:
            aspects.append("system architecture")
        if "--profile" in flags:
            aspects.append("performance")
        
        if aspects:
            action_parts.append(f"Analyze {', '.join(aspects)}")
        else:
            action_parts.append("Perform analysis")
    
    elif command == "/troubleshoot":
        action_parts.append("Debug and investigate issues")
        if "--prod" in flags:
            action_parts.append("in production environment")
        if "--five-whys" in flags:
            action_parts.append("using root cause analysis")
    
    elif command == "/deploy":
        if "--env" in flags and argument:
            action_parts.append(f"Deploy to {argument} environment")
        else:
            action_parts.append("Deploy application")
        
        if "--canary" in flags:
            action_parts.append("using canary deployment strategy")
        elif "--blue-green" in flags:
            action_parts.append("using blue-green deployment")
    
    else:
        # Generic action based on command name
        action_parts.append(f"Execute {cmd_data.get('name', command)}")
        if argument:
            action_parts.append(f"on {argument}")
    
    # Add modifiers based on universal flags
    modifiers = []
    if "--think" in flags or "--think-hard" in flags or "--ultrathink" in flags:
        modifiers.append("with deep analysis")
    if "--plan" in flags:
        modifiers.append("showing execution plan first")
    if "--dry-run" in flags:
        modifiers.append("in preview mode (no changes)")
    if "--validate" in flags:
        modifiers.append("with enhanced validation")
    if "--strict" in flags:
        modifiers.append("in strict mode")
    
    # Add persona influence
    for flag in flags:
        if flag.startswith("--persona-"):
            persona_name = flag.replace("--persona-", "")
            modifiers.append(f"with {persona_name} expertise")
            break
    
    # Combine all parts
    result = " ".join(action_parts)
    if modifiers:
        result += " " + ", ".join(modifiers)
    
    return result

def main():
    st.set_page_config(
        page_title="SuperClaude Command Explorer",
        page_icon="🚀",
        layout="wide"
    )
    
    st.title("🚀 SuperClaude Command Explorer")
    st.markdown("Select commands and flags to see their combined effects and descriptions.")
    
    # Add clear button at the top
    if st.button("🔄 Clear All Selections", type="primary"):
        st.rerun()
    
    # Create three columns for better layout
    col1, col2, col3 = st.columns([1, 1, 1])
    
    with col1:
        st.subheader("1️⃣ Select Command")
        
        # Group commands by category
        categories = {}
        for cmd, data in COMMANDS_DATA.items():
            cat = data.get("category", "Other")
            if cat not in categories:
                categories[cat] = []
            categories[cat].append(cmd)
        
        # Create a select box with grouped options
        all_commands = []
        for cat, cmds in sorted(categories.items()):
            all_commands.extend(cmds)
        
        selected_command = st.selectbox(
            "Choose a command:",
            [""] + all_commands,
            format_func=lambda x: f"{x} - {COMMANDS_DATA[x]['name']}" if x and x in COMMANDS_DATA else x or "Select a command..."
        )
    
    with col2:
        st.subheader("2️⃣ Select Flags")
        
        if selected_command:
            # Command-specific flags
            cmd_data = COMMANDS_DATA[selected_command]
            specific_flags = list(cmd_data.get("specific_flags", {}).keys())
            
            # Group flags by category - only showing most common ones in checkboxes
            common_flag_groups = {
                "Command-Specific": specific_flags,
                "Thinking Depth": [f for f, d in UNIVERSAL_FLAGS.items() if d.get("category") == "Thinking Depth"],
                "MCP Servers": [f for f, d in UNIVERSAL_FLAGS.items() if d.get("category") == "MCP Server"],
                "Personas": list(PERSONA_FLAGS.keys())
            }
            
            selected_flags = []
            for group_name, flags in common_flag_groups.items():
                if flags:
                    st.markdown(f"**{group_name}:**")
                    for flag in flags:
                        # Get description for tooltip
                        if flag in cmd_data.get("specific_flags", {}):
                            desc = cmd_data["specific_flags"][flag]
                        elif flag in UNIVERSAL_FLAGS:
                            desc = UNIVERSAL_FLAGS[flag]["description"]
                        elif flag in PERSONA_FLAGS:
                            desc = f"{PERSONA_FLAGS[flag]['expertise']} - {PERSONA_FLAGS[flag]['best_for']}"
                        else:
                            desc = ""
                        
                        if st.checkbox(flag, key=f"{group_name}_{flag}", help=desc):
                            selected_flags.append(flag)
        else:
            st.info("👈 Please select a command first")
            selected_flags = []
    
    with col3:
        st.subheader("3️⃣ Additional Flags/Arguments")
        
        if selected_command:
            # Get all remaining flags not shown in step 2
            shown_flags = set()
            for flags in common_flag_groups.values():
                shown_flags.update(flags)
            
            # Collect all additional flags with descriptions
            additional_options = {"": "Select additional flag or enter custom argument..."}
            
            # Add remaining universal flags
            for flag, data in UNIVERSAL_FLAGS.items():
                if flag not in shown_flags:
                    category = data.get("category", "Other")
                    additional_options[flag] = f"{flag} - {data['description']} [{category}]"
            
            # Common argument templates based on command
            if selected_command == "/build":
                additional_options["[feature-name]"] = "[feature-name] - Name/description of feature to build"
                additional_options["[project-name]"] = "[project-name] - Name for new project"
            elif selected_command == "/review":
                additional_options["[file-path]"] = "[file-path] - Path to file or directory to review"
                additional_options["HEAD"] = "HEAD - Review latest commit"
                additional_options["[commit-hash]"] = "[commit-hash] - Review specific commit"
            elif selected_command == "/deploy":
                additional_options["dev"] = "dev - Deploy to development environment"
                additional_options["staging"] = "staging - Deploy to staging environment"
                additional_options["prod"] = "prod - Deploy to production environment"
            elif selected_command == "/analyze":
                additional_options["[directory]"] = "[directory] - Directory to analyze"
                additional_options["[pattern]"] = "[pattern] - File pattern to analyze (e.g., *.ts)"
            elif selected_command == "/troubleshoot":
                additional_options["[error-message]"] = "[error-message] - Error or issue description"
            elif selected_command == "/estimate":
                additional_options["[task-description]"] = "[task-description] - Task or feature to estimate"
            elif selected_command == "/migrate":
                additional_options["[version]"] = "[version] - Target version for migration"
            elif selected_command == "/git":
                additional_options["[branch-name]"] = "[branch-name] - Git branch name"
                additional_options["[commit-message]"] = "[commit-message] - Commit message"
            
            # Create dropdown and text input
            selected_additional = st.selectbox(
                "Select flag or argument template:",
                options=list(additional_options.keys()),
                format_func=lambda x: additional_options[x]
            )
            
            # If user selected a template, allow them to customize it
            if selected_additional and selected_additional.startswith("["):
                argument = st.text_input(
                    "Customize argument:",
                    placeholder=selected_additional.strip("[]"),
                    help=f"Replace {selected_additional} with your specific value"
                )
            elif selected_additional:
                argument = selected_additional
                if selected_additional.startswith("--"):
                    selected_flags.append(selected_additional)
                    argument = ""
            else:
                # Allow free-form input
                argument = st.text_input(
                    "Custom argument:",
                    help="Enter any custom argument or value"
                )
        else:
            st.info("👈 Please select a command first")
            argument = ""
    
    # Display the combined description
    st.markdown("---")
    st.subheader("📋 Combined Command Description")
    
    if selected_command:
        # Show the full command
        full_command = selected_command
        if selected_flags:
            full_command += " " + " ".join(selected_flags)
        if argument:
            full_command += f" {argument}"
        
        st.code(full_command, language="bash")
        
        # Generate and display the combined description
        combined_desc = generate_combined_description(selected_command, selected_flags, argument)
        st.markdown(combined_desc)
        
        # Show examples if available
        if "examples" in COMMANDS_DATA[selected_command]:
            with st.expander("📚 See Examples"):
                for example in COMMANDS_DATA[selected_command]["examples"]:
                    st.code(example, language="bash")
    else:
        st.info("Select a command to see its description")
    
    # Add a sidebar with quick reference
    with st.sidebar:
        st.header("📚 Quick Reference")
        
        st.subheader("Command Categories")
        for category in sorted(set(data.get("category", "Other") for data in COMMANDS_DATA.values())):
            cmds = [cmd for cmd, data in COMMANDS_DATA.items() if data.get("category") == category]
            st.markdown(f"**{category}** ({len(cmds)} commands)")
            for cmd in cmds:
                st.markdown(f"• `{cmd}`")
        
        st.subheader("Best Practices")
        st.markdown("""
        - Use `--validate` for risky operations
        - Add `--dry-run` to preview changes
        - Combine `--think` flags for complex tasks
        - Use personas for specialized expertise
        - Enable MCP servers for enhanced capabilities
        """)

if __name__ == "__main__":
    main()