# Claude Code Master Guide: Complete Subagents & Hooks Implementation

> **CRITICAL CONTEXT FOR PRIMARY AGENT**: This document provides comprehensive instructions and context for implementing advanced Claude Code automation workflows using subagents and hooks. Use this as your primary reference for understanding capabilities, implementation patterns, and best practices.

## Executive Summary

Claude Code has evolved from a coding assistant to a **deterministic automation platform** through two revolutionary features:

1. **Subagents**: Specialized AI assistants with isolated contexts and domain expertise
2. **Hooks**: Programmatic control points that guarantee specific behaviors at lifecycle events

This combination enables **production-grade workflows** with security enforcement, audit trails, and sophisticated multi-agent orchestration that surpasses traditional prompt-based interactions.

---

## Part 1: Subagents - Specialized AI Team Architecture

### Core Philosophy

Subagents transform the "jack of all trades, master of none" problem into a **specialist team approach**. Instead of one AI attempting everything, you create focused experts that excel in specific domains with isolated contexts.

### Fundamental Concepts

#### Context Isolation Benefits

- **Main conversation preservation**: Each subagent operates independently
- **Specialized memory**: Domain-specific context without pollution
- **Parallel processing**: Multiple agents can work simultaneously
- **Task-specific optimization**: Fine-tuned prompts for higher success rates

#### Automatic vs Explicit Delegation

```bash
# Automatic (Claude chooses based on context)
> "Review this code for security issues"  # → security-auditor subagent

# Explicit (Direct specification)
> "Use the code-reviewer subagent to check style compliance"
```

### Implementation Architecture

#### File Structure

``` tree
.claude/
├── settings.json          # Central configuration
├── agents/               # Project-level subagents (highest priority)
│   ├── security-auditor.md
│   ├── test-automator.md
│   ├── code-reviewer.md
│   └── performance-optimizer.md
└── ~/.claude/agents/     # User-level subagents (global, lower priority)
    ├── debugger.md
    ├── documenter.md
    └── data-scientist.md
```

#### Subagent Configuration Template

```markdown
---
name: agent-name
description: Specific trigger conditions and use cases
model: haiku|sonnet|opus  # Optional: Cost-effective model selection
tools: Read, Write, Bash, Grep  # Optional: Granular permissions
---

# Agent Role Definition
**Role**: Primary responsibilities and expertise area
**Expertise**: Specific technologies and domain knowledge
**Key Capabilities**: 
- Capability 1: Detailed description
- Capability 2: Implementation approach
- Capability 3: Quality standards

## System Instructions
Detailed behavioral guidelines, decision-making patterns, 
interaction protocols, and quality standards.

## Workflow Patterns
Step-by-step processes for common tasks within domain.
```

### Production-Ready Subagent Examples

#### Security Auditor

```markdown
---
name: security-auditor
description: Proactive security analysis for code vulnerabilities, access control, and compliance. Use IMMEDIATELY for any security-sensitive operations.
model: opus
tools: Read, Grep, Bash
---

# Security Auditor

**Role**: Comprehensive security analysis and vulnerability detection
**Expertise**: OWASP Top 10, secure coding practices, cryptography, access control
**Key Capabilities**:
- Static code analysis for security vulnerabilities
- Authentication and authorization review
- Cryptographic implementation validation
- Security compliance verification

## Security Analysis Protocol
1. **Initial Scan**: Identify security-sensitive code patterns
2. **Vulnerability Assessment**: Check against OWASP Top 10
3. **Access Control Review**: Validate authentication/authorization
4. **Cryptographic Analysis**: Verify secure implementations
5. **Compliance Check**: Ensure regulatory compliance
6. **Risk Assessment**: Prioritize findings by severity

## Critical Security Patterns
- Input validation and sanitization
- SQL injection prevention
- XSS protection mechanisms
- CSRF token implementation
- Secure session management
- Proper error handling (no information leakage)
- Secrets management (no hardcoded credentials)

Always provide specific remediation steps with code examples.
```

#### Performance Optimizer

```markdown
---
name: performance-optimizer
description: Database query optimization, algorithm efficiency, caching strategies, and performance bottleneck resolution. Use proactively for performance-critical code.
model: sonnet
tools: Read, Write, Bash, Grep
---

# Performance Optimizer

**Role**: System performance analysis and optimization
**Expertise**: Algorithm complexity, database optimization, caching, profiling
**Key Capabilities**:
- Performance bottleneck identification
- Database query optimization
- Caching strategy implementation
- Memory usage optimization

## Performance Analysis Workflow
1. **Profiling Setup**: Configure performance monitoring
2. **Bottleneck Identification**: Find slow operations
3. **Root Cause Analysis**: Determine performance issues
4. **Optimization Implementation**: Apply specific improvements
5. **Verification**: Measure performance gains
6. **Documentation**: Record optimization decisions

## Optimization Focus Areas
- O(n) complexity reduction
- Database index optimization
- Caching layer implementation
- Memory leak prevention
- Asynchronous operation implementation
- Resource pooling strategies

Provide before/after metrics and benchmark comparisons.
```

#### Test Automator

```markdown
---
name: test-automator
description: Comprehensive testing strategy including unit, integration, and end-to-end tests. Use proactively when code changes affect testable functionality.
model: sonnet
tools: Read, Write, Bash
---

# Test Automator

**Role**: Comprehensive test coverage and quality assurance
**Expertise**: TDD/BDD, test frameworks, mocking, CI/CD integration
**Key Capabilities**:
- Test strategy development
- Automated test generation
- Test coverage analysis
- Test data management

## Testing Workflow
1. **Test Planning**: Analyze testing requirements
2. **Test Implementation**: Write comprehensive test suites
3. **Coverage Analysis**: Ensure adequate test coverage
4. **Test Execution**: Run tests and analyze results
5. **Test Maintenance**: Update tests for code changes
6. **CI/CD Integration**: Automate test execution

## Test Categories
- Unit tests: Function-level testing
- Integration tests: Component interaction testing
- End-to-end tests: User workflow testing
- Performance tests: Load and stress testing
- Security tests: Vulnerability testing

Always maintain test coverage above 80% for critical paths.
```

### Advanced Subagent Patterns

#### Multi-Agent Orchestration

```markdown
---
name: workflow-orchestrator
description: Coordinates complex multi-step tasks across specialized subagents for large-scale implementations.
model: opus
tools: Read, Write, Bash
---

# Workflow Orchestrator

**Role**: Multi-agent coordination for complex workflows
**Workflow Pattern**:
1. **Analysis Phase**: Use domain-specific analyzer agents
2. **Planning Phase**: Architecture and design agents
3. **Implementation Phase**: Specialized development agents
4. **Validation Phase**: Testing and security agents
5. **Documentation Phase**: Documentation specialists

## Coordination Strategies
- Sequential execution for dependent tasks
- Parallel execution for independent tasks
- Quality gates between phases
- Context sharing between agents
- Error handling and rollback procedures
```

#### Meta-Agent Generator

```markdown
---
name: meta-agent
description: Generates new specialized subagents based on project requirements. Use when existing agents don't cover specific domain needs.
model: opus
tools: Read, Write
---

# Meta-Agent Generator

**Role**: Dynamic subagent creation for emerging requirements
**Generation Process**:
1. **Requirement Analysis**: Understand domain expertise needed
2. **Template Selection**: Choose appropriate agent template
3. **Customization**: Adapt template to specific requirements
4. **Tool Selection**: Configure appropriate tool access
5. **Validation**: Test generated agent functionality

## Agent Templates Available
- Development specialists (frontend, backend, mobile)
- Quality assurance specialists (testing, security, performance)
- Operations specialists (DevOps, monitoring, deployment)
- Domain specialists (AI/ML, data science, design)

Output complete .md files ready for immediate deployment.
```

---

## Part 2: Hooks - Deterministic Control System

### Revolutionary Paradigm Shift

Hooks transform Claude Code from **suggestion-based** to **guarantee-based** automation. Instead of hoping Claude chooses correct actions, hooks **programmatically enforce** specific behaviors at defined lifecycle events.

### Eight Hook Intervention Points

| Hook Type | Execution Point | Primary Use Cases |
|-----------|----------------|-------------------|
| `SessionStart` | Session initialization | Load development context, environment setup |
| `UserPromptSubmit` | Before prompt processing | Input validation, prompt enhancement |
| `PreToolUse` | Before tool execution | Security enforcement, permission gates |
| `ToolCallStreamStart` | Tool execution begins | Monitoring initialization, logging |
| `ToolCallStreamChunk` | During tool execution | Real-time processing, progress tracking |
| `ToolCallStreamEnd` | Tool execution completes | Result validation, cleanup |
| `PostToolUse` | After tool execution | Result processing, audit logging |
| `SubagentStop` | Subagent completion | Agent coordination, result aggregation |
| `Stop` | Conversation ends | Completion actions, final processing |
| `Notification` | Claude needs input | User alerts, attention management |

### Hook Architecture Implementation

#### Configuration Structure

```json
{
  "hooks": {
    "SessionStart": ".claude/hooks/session_start.py",
    "UserPromptSubmit": ".claude/hooks/prompt_validator.py",
    "PreToolUse": ".claude/hooks/security_gate.py",
    "PostToolUse": ".claude/hooks/result_processor.py",
    "Stop": ".claude/hooks/completion_handler.py",
    "Notification": ".claude/hooks/user_alert.py"
  },
  "permissions": {
    "require_approval": ["sudo", "rm -rf"],
    "blocked_paths": [".env", "id_rsa", "*.key"],
    "audit_all_actions": true
  }
}
```

#### UV Single-File Script Template

```python
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "requests>=2.28.0",
#     "openai>=1.0.0",
#     "pydantic>=2.0.0"
# ]
# ///

import json
import sys
import subprocess
import logging
from pathlib import Path
from typing import Dict, Any, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('.claude/logs/hooks.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def main():
    """Main hook execution with comprehensive error handling."""
    try:
        # Read hook data from stdin
        hook_data = json.loads(sys.stdin.read())
        logger.info(f"Hook triggered: {hook_data.get('hook_event_name', 'unknown')}")
        
        # Process hook logic
        result = process_hook(hook_data)
        
        # Handle different response types
        if result.get('block', False):
            # Block execution with feedback
            response = {
                "decision": "block",
                "reason": result.get('reason', 'Blocked by security policy'),
                "continue": False
            }
            print(json.dumps(response), file=sys.stderr)
            sys.exit(2)  # Block with feedback
        elif result.get('allow', False):
            # Allow with modifications
            response = {
                "decision": "allow",
                "permissionDecisionReason": result.get('reason', 'Approved by policy')
            }
            print(json.dumps(response))
            sys.exit(0)
        else:
            # Normal success
            print(json.dumps(result))
            sys.exit(0)
            
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON input: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Hook execution error: {e}")
        print(f"Hook error: {str(e)}", file=sys.stderr)
        sys.exit(1)

def process_hook(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Process the hook logic - override this in specific implementations.
    
    Args:
        data: Hook event data from Claude Code
        
    Returns:
        Dict containing response data
    """
    hook_type = data.get('hook_event_name', '')
    tool_name = data.get('tool_name', '')
    
    # Example processing logic
    if hook_type == 'PreToolUse':
        return handle_pre_tool_use(data)
    elif hook_type == 'PostToolUse':
        return handle_post_tool_use(data)
    else:
        return {"success": True, "processed": True}

def handle_pre_tool_use(data: Dict[str, Any]) -> Dict[str, Any]:
    """Security gate for tool execution."""
    tool_name = data.get('tool_name', '')
    tool_input = data.get('tool_input', {})
    
    # Security validation logic here
    if is_dangerous_operation(tool_name, tool_input):
        return {
            "block": True,
            "reason": "Security policy violation detected"
        }
    
    return {"allow": True, "reason": "Security validation passed"}

def handle_post_tool_use(data: Dict[str, Any]) -> Dict[str, Any]:
    """Result processing and validation."""
    tool_name = data.get('tool_name', '')
    tool_response = data.get('tool_response', {})
    
    # Process results, update logs, trigger notifications
    process_results(tool_name, tool_response)
    
    return {"processed": True, "logged": True}

def is_dangerous_operation(tool_name: str, tool_input: Dict[str, Any]) -> bool:
    """Comprehensive security pattern matching."""
    import re
    
    DANGEROUS_PATTERNS = [
        r'\brm\s+.*-[a-z]*r[a-z]*f',  # rm -rf variations
        r'\brm\s+--recursive\s+--force',
        r'\bsudo\s+',
        r'\bchmod\s+777',
        r'\.env\b',
        r'id_rsa\b',
        r'\.key\b',
        r'\bpassword\s*=',
    ]
    
    if tool_name == 'bash':
        command = tool_input.get('command', '')
        for pattern in DANGEROUS_PATTERNS:
            if re.search(pattern, command, re.IGNORECASE):
                logger.warning(f"Dangerous pattern detected: {pattern} in {command}")
                return True
    
    return False

def process_results(tool_name: str, tool_response: Dict[str, Any]) -> None:
    """Process tool execution results."""
    # Log results
    log_entry = {
        "tool_name": tool_name,
        "timestamp": str(Path('.claude/logs/execution.jsonl')),
        "response": tool_response
    }
    
    # Append to execution log
    with open('.claude/logs/execution.jsonl', 'a') as f:
        f.write(json.dumps(log_entry) + '\n')

if __name__ == "__main__":
    main()
```

### Production Hook Implementations

#### Advanced Security Gate (PreToolUse)

```python
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "requests>=2.28.0",
#     "pydantic>=2.0.0"
# ]
# ///

import json
import sys
import re
import os
from pathlib import Path
from typing import Dict, List, Any

class SecurityPolicy:
    """Comprehensive security policy enforcement."""
    
    CRITICAL_PATTERNS = [
        r'\brm\s+.*-[a-z]*r[a-z]*f',  # rm -rf variations
        r'\brm\s+--recursive\s+--force',
        r'\bsudo\s+(?!npm|pip)',  # Allow sudo for package managers
        r'\bchmod\s+777',
        r'\beval\s*\(',
        r'\bexec\s*\(',
        r'__import__\s*\(',
    ]
    
    SENSITIVE_FILES = [
        r'\.env\b',
        r'\.key\b',
        r'id_rsa\b',
        r'\.pem\b',
        r'password\b',
        r'secret\b',
        r'token\b',
    ]
    
    APPROVED_COMMANDS = {
        'git', 'npm', 'pip', 'python', 'node', 'yarn',
        'docker', 'kubectl', 'terraform', 'aws'
    }

def main():
    try:
        data = json.loads(sys.stdin.read())
        policy = SecurityPolicy()
        
        tool_name = data.get('tool_name', '')
        tool_input = data.get('tool_input', {})
        
        # Apply security checks
        security_result = apply_security_policy(policy, tool_name, tool_input)
        
        if security_result['blocked']:
            response = {
                "decision": "block",
                "reason": security_result['reason'],
                "suggestion": security_result.get('suggestion', ''),
                "continue": False
            }
            print(json.dumps(response), file=sys.stderr)
            sys.exit(2)
        else:
            response = {
                "decision": "allow",
                "permissionDecisionReason": "Security validation passed"
            }
            print(json.dumps(response))
            sys.exit(0)
            
    except Exception as e:
        print(f"Security hook error: {e}", file=sys.stderr)
        sys.exit(1)

def apply_security_policy(policy: SecurityPolicy, tool_name: str, tool_input: Dict[str, Any]) -> Dict[str, Any]:
    """Apply comprehensive security policy."""
    
    if tool_name == 'bash':
        command = tool_input.get('command', '')
        
        # Check for critical patterns
        for pattern in policy.CRITICAL_PATTERNS:
            if re.search(pattern, command, re.IGNORECASE):
                return {
                    "blocked": True,
                    "reason": f"Dangerous command pattern detected: {pattern}",
                    "suggestion": "Use safer alternatives or request manual approval"
                }
        
        # Check for sensitive file access
        for pattern in policy.SENSITIVE_FILES:
            if re.search(pattern, command, re.IGNORECASE):
                return {
                    "blocked": True,
                    "reason": f"Sensitive file access detected: {pattern}",
                    "suggestion": "Verify file access is necessary and secure"
                }
    
    elif tool_name in ['Write', 'Edit']:
        file_path = tool_input.get('file_path', '')
        
        # Prevent writing to sensitive locations
        if any(sensitive in file_path.lower() for sensitive in ['.env', '.key', 'password', 'secret']):
            return {
                "blocked": True,
                "reason": f"Attempted write to sensitive file: {file_path}",
                "suggestion": "Use secure configuration management instead"
            }
    
    return {"blocked": False, "reason": "Security validation passed"}

if __name__ == "__main__":
    main()
```

#### Intelligent TTS Notification System

```python
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "requests>=2.28.0",
#     "openai>=1.0.0",
#     "pyttsx3>=2.90"
# ]
# ///

import json
import sys
import os
import random
import requests
from pathlib import Path

class TTSManager:
    """Multi-provider TTS with intelligent fallback."""
    
    def __init__(self):
        self.engineer_name = os.getenv('ENGINEER_NAME', 'Engineer')
        
    def speak(self, message: str) -> bool:
        """Attempt TTS with provider fallback."""
        # Personalize message (30% chance)
        if random.random() < 0.3:
            message = f"Hey {self.engineer_name}! {message}"
        
        # Try ElevenLabs first
        if self._try_elevenlabs(message):
            return True
            
        # Fallback to OpenAI
        if self._try_openai_tts(message):
            return True
            
        # Final fallback to local TTS
        return self._try_local_tts(message)
    
    def _try_elevenlabs(self, message: str) -> bool:
        """ElevenLabs TTS implementation."""
        api_key = os.getenv('ELEVENLABS_API_KEY')
        if not api_key:
            return False
            
        try:
            voice_id = os.getenv('ELEVENLABS_VOICE_ID', 'default')
            url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
            
            response = requests.post(
                url,
                headers={'xi-api-key': api_key},
                json={'text': message, 'voice_settings': {'speed': 1.1}},
                timeout=10
            )
            
            if response.status_code == 200:
                # Save and play audio
                audio_path = Path('.claude/temp/notification.mp3')
                audio_path.parent.mkdir(exist_ok=True)
                audio_path.write_bytes(response.content)
                os.system(f'afplay {audio_path}')  # macOS
                return True
                
        except Exception:
            pass
        
        return False
    
    def _try_openai_tts(self, message: str) -> bool:
        """OpenAI TTS implementation."""
        api_key = os.getenv('OPENAI_API_KEY')
        if not api_key:
            return False
            
        try:
            import openai
            client = openai.OpenAI(api_key=api_key)
            
            response = client.audio.speech.create(
                model="tts-1",
                voice="alloy",
                input=message
            )
            
            audio_path = Path('.claude/temp/notification.mp3')
            audio_path.parent.mkdir(exist_ok=True)
            response.stream_to_file(audio_path)
            os.system(f'afplay {audio_path}')  # macOS
            return True
            
        except Exception:
            pass
        
        return False
    
    def _try_local_tts(self, message: str) -> bool:
        """Local TTS fallback."""
        try:
            import pyttsx3
            engine = pyttsx3.init()
            engine.setProperty('rate', 180)
            engine.say(message)
            engine.runAndWait()
            return True
        except Exception:
            # Final fallback - system notification
            os.system(f'osascript -e "display notification \\"{message}\\" with title \\"Claude Code\\""')
            return True

def main():
    try:
        data = json.loads(sys.stdin.read())
        message = data.get('notification', 'Claude needs your attention')
        
        tts = TTSManager()
        tts.speak(message)
        
        # Log notification
        log_entry = {
            "timestamp": str(Path('.claude/logs/notifications.jsonl')),
            "message": message,
            "delivered": True
        }
        
        log_path = Path('.claude/logs/notifications.jsonl')
        log_path.parent.mkdir(exist_ok=True)
        with open(log_path, 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
        
        sys.exit(0)
        
    except Exception as e:
        print(f"Notification hook error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
```

#### Smart Completion Handler (Stop Hook)

```python
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "openai>=1.0.0",
#     "requests>=2.28.0"
# ]
# ///

import json
import sys
import os
from pathlib import Path

def main():
    try:
        data = json.loads(sys.stdin.read())
        
        # Generate AI-powered completion message
        completion_message = generate_completion_message(data)
        
        # Process conversation transcript
        process_transcript(data)
        
        # Optional: Send completion notification
        send_completion_notification(completion_message)
        
        # Force continuation if needed
        if should_force_continuation(data):
            response = {
                "decision": "block",
                "reason": "Additional validation required before completion"
            }
            print(json.dumps(response), file=sys.stderr)
            sys.exit(2)
        
        sys.exit(0)
        
    except Exception as e:
        print(f"Completion hook error: {e}", file=sys.stderr)
        sys.exit(1)

def generate_completion_message(data: Dict[str, Any]) -> str:
    """Generate contextual completion message using LLM."""
    try:
        import openai
        
        api_key = os.getenv('OPENAI_API_KEY')
        if not api_key:
            return "Task completed successfully."
        
        client = openai.OpenAI(api_key=api_key)
        
        # Extract context from conversation
        transcript_path = data.get('transcript_path', '')
        context = extract_conversation_context(transcript_path)
        
        prompt = f"""
        Based on this conversation context, generate a brief, helpful completion message:
        
        Context: {context}
        
        Requirements:
        - Be concise (1-2 sentences)
        - Highlight key accomplishments
        - Suggest next steps if appropriate
        - Maintain professional but friendly tone
        """
        
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100,
            temperature=0.7
        )
        
        return response.choices[0].message.content.strip()
        
    except Exception:
        return "Task completed successfully."

def process_transcript(data: Dict[str, Any]) -> None:
    """Convert JSONL transcript to readable JSON format."""
    transcript_path = data.get('transcript_path', '')
    if not transcript_path or not Path(transcript_path).exists():
        return
    
    try:
        # Read JSONL transcript
        messages = []
        with open(transcript_path, 'r') as f:
            for line in f:
                if line.strip():
                    messages.append(json.loads(line))
        
        # Save as readable JSON
        chat_path = Path('.claude/logs/chat.json')
        chat_path.parent.mkdir(exist_ok=True)
        
        with open(chat_path, 'w') as f:
            json.dump(messages, f, indent=2)
            
    except Exception as e:
        print(f"Transcript processing error: {e}", file=sys.stderr)

def extract_conversation_context(transcript_path: str) -> str:
    """Extract key context from conversation transcript."""
    try:
        if not Path(transcript_path).exists():
            return "Development session"
        
        with open(transcript_path, 'r') as f:
            lines = f.readlines()[-5:]  # Last 5 messages
        
        context_items = []
        for line in lines:
            try:
                msg = json.loads(line)
                if msg.get('type') == 'user':
                    context_items.append(f"User: {msg.get('content', '')[:100]}")
                elif msg.get('type') == 'assistant':
                    context_items.append(f"Assistant: {msg.get('content', '')[:100]}")
            except:
                continue
        
        return " | ".join(context_items)
        
    except Exception:
        return "Development session"

def should_force_continuation(data: Dict[str, Any]) -> bool:
    """Determine if conversation should be forced to continue."""
    # Example: Force continuation if there are failing tests
    try:
        import subprocess
        result = subprocess.run(['npm', 'test'], capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            return True
    except:
        pass
    
    return False

def send_completion_notification(message: str) -> None:
    """Send completion notification via TTS or system notification."""
    try:
        # Use TTS if available
        tts_script = Path('.claude/hooks/notification.py')
        if tts_script.exists():
            subprocess.run([
                'python', str(tts_script)
            ], input=json.dumps({"notification": message}), text=True)
        else:
            # Fallback to system notification
            os.system(f'osascript -e "display notification \\"{message}\\" with title \\"Claude Code Complete\\""')
    except:
        pass

if __name__ == "__main__":
    main()
```

---

## Part 3: Integration Patterns & Advanced Workflows

### Multi-Agent Hook Coordination

#### Session Context Injection

```python
# SessionStart hook - Load development context
def load_development_context(data: Dict[str, Any]) -> Dict[str, Any]:
    """Load project context and recent changes."""
    context_items = []
    
    # Load recent git changes
    try:
        import subprocess
        result = subprocess.run(['git', 'log', '--oneline', '-10'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            context_items.append(f"Recent commits:\n{result.stdout}")
    except:
        pass
    
    # Load open issues or TODOs
    try:
        result = subprocess.run(['grep', '-r', 'TODO', '.', '--exclude-dir=node_modules'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            todos = result.stdout.split('\n')[:5]  # First 5 TODOs
            context_items.append(f"Open TODOs:\n" + '\n'.join(todos))
    except:
        pass
    
    additional_context = '\n\n'.join(context_items)
    
    return {
        "hookSpecificOutput": {
            "additionalContext": additional_context
        }
    }
```

#### Agent Selection and Routing

```python
# UserPromptSubmit hook - Intelligent agent routing
def enhance_prompt_with_agent_routing(data: Dict[str, Any]) -> Dict[str, Any]:
    """Enhance prompts with agent selection hints."""
    prompt = data.get('prompt', '')
    
    # Analyze prompt for agent hints
    agent_suggestions = analyze_prompt_for_agents(prompt)
    
    if agent_suggestions:
        enhanced_prompt = f"""
        {prompt}
        
        AGENT ROUTING SUGGESTIONS:
        {chr(10).join(agent_suggestions)}
        
        Consider delegating to appropriate specialized subagents for optimal results.
        """
        
        return {
            "hookSpecificOutput": {
                "modifiedPrompt": enhanced_prompt
            }
        }
    
    return {"processed": True}

def analyze_prompt_for_agents(prompt: str) -> List[str]:
    """Analyze prompt content to suggest appropriate agents."""
    suggestions = []
    prompt_lower = prompt.lower()
    
    if any(keyword in prompt_lower for keyword in ['security', 'vulnerability', 'auth', 'password']):
        suggestions.append("- Use security-auditor for security-related analysis")
    
    if any(keyword in prompt_lower for keyword in ['test', 'testing', 'spec', 'coverage']):
        suggestions.append("- Use test-automator for testing tasks")
    
    if any(keyword in prompt_lower for keyword in ['performance', 'slow', 'optimize', 'speed']):
        suggestions.append("- Use performance-optimizer for performance analysis")
    
    if any(keyword in prompt_lower for keyword in ['review', 'quality', 'refactor', 'clean']):
        suggestions.append("- Use code-reviewer for code quality analysis")
    
    return suggestions
```

### Real-Time Observability Dashboard

#### Hook Event Streaming

```python
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "websockets>=11.0",
#     "sqlite3",
#     "uuid"
# ]
# ///

import json
import sqlite3
import asyncio
import websockets
import uuid
from datetime import datetime
from pathlib import Path

class HookEventTracker:
    """Real-time hook event tracking and streaming."""
    
    def __init__(self):
        self.db_path = Path('.claude/logs/hooks.db')
        self.ensure_database()
        self.session_id = str(uuid.uuid4())
    
    def ensure_database(self):
        """Initialize SQLite database for hook events."""
        self.db_path.parent.mkdir(exist_ok=True)
        
        conn = sqlite3.connect(self.db_path)
        conn.execute('''
            CREATE TABLE IF NOT EXISTS hook_events (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                session_id TEXT,
                hook_type TEXT,
                tool_name TEXT,
                success BOOLEAN,
                duration_ms INTEGER,
                data TEXT,
                result TEXT
            )
        ''')
        conn.commit()
        conn.close()
    
    def log_event(self, hook_type: str, tool_name: str, success: bool, 
                  duration_ms: int, data: dict, result: dict):
        """Log hook event to database."""
        conn = sqlite3.connect(self.db_path)
        conn.execute('''
            INSERT INTO hook_events 
            (timestamp, session_id, hook_type, tool_name, success, duration_ms, data, result)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            datetime.now().isoformat(),
            self.session_id,
            hook_type,
            tool_name,
            success,
            duration_ms,
            json.dumps(data),
            json.dumps(result)
        ))
        conn.commit()
        conn.close()
    
    async def stream_event(self, event_data: dict):
        """Stream event to observability dashboard."""
        try:
            uri = "ws://localhost:3001/hooks"
            async with websockets.connect(uri, timeout=5) as websocket:
                await websocket.send(json.dumps(event_data))
        except Exception:
            # Dashboard connection optional
            pass

# Usage in hooks
tracker = HookEventTracker()

def track_hook_execution(hook_type: str, data: dict, result: dict, duration_ms: int):
    """Track hook execution with observability."""
    tool_name = data.get('tool_name', 'unknown')
    success = result.get('success', True)
    
    # Log to database
    tracker.log_event(hook_type, tool_name, success, duration_ms, data, result)
    
    # Stream to dashboard
    event_data = {
        "type": "hook_event",
        "timestamp": datetime.now().isoformat(),
        "session_id": tracker.session_id,
        "hook_type": hook_type,
        "tool_name": tool_name,
        "success": success,
        "duration_ms": duration_ms
    }
    
    asyncio.run(tracker.stream_event(event_data))
```

---

## Part 4: Production Implementation Strategy

### Development Environment Setup

#### Project Initialization Script

```bash
#!/bin/bash
# claude-code-setup.sh - Initialize Claude Code with subagents and hooks

set -e

echo "🚀 Initializing Claude Code Advanced Configuration..."

# Create directory structure
mkdir -p .claude/{agents,hooks,logs,commands,docs}

# Create settings.json
cat > .claude/settings.json << 'EOF'
{
  "hooks": {
    "SessionStart": ".claude/hooks/session_start.py",
    "UserPromptSubmit": ".claude/hooks/prompt_enhancer.py",
    "PreToolUse": ".claude/hooks/security_gate.py",
    "PostToolUse": ".claude/hooks/result_processor.py",
    "Stop": ".claude/hooks/completion_handler.py",
    "Notification": ".claude/hooks/tts_notification.py"
  },
  "subagent_defaults": {
    "timeout": 300,
    "max_context": 8000,
    "enable_observability": true
  },
  "security": {
    "require_approval": ["sudo", "rm -rf", "chmod 777"],
    "blocked_paths": [".env", "*.key", "id_rsa", "*.pem"],
    "audit_all_actions": true,
    "max_hook_timeout": 60
  },
  "observability": {
    "enable_real_time_streaming": true,
    "dashboard_port": 3001,
    "log_retention_days": 30
  }
}
EOF

# Install core subagents
echo "📦 Installing core subagents..."

# Code Reviewer
cat > .claude/agents/code-reviewer.md << 'EOF'
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
model: sonnet
tools: Read, Grep, Glob, Bash
---

# Code Reviewer

You are a senior code reviewer ensuring high standards of code quality and security.

## Review Process
1. Run `git diff` to see recent changes
2. Focus on modified files and their context
3. Apply comprehensive review checklist
4. Provide prioritized feedback

## Quality Standards
- Code is simple and readable
- Functions and variables are well-named
- No duplicated code
- Proper error handling
- No exposed secrets or API keys
- Input validation implemented
- Good test coverage
- Performance considerations addressed

## Feedback Structure
**Critical Issues** (must fix):
- Security vulnerabilities
- Logic errors
- Performance bottlenecks

**Warnings** (should fix):
- Code smells
- Maintainability issues
- Style inconsistencies

**Suggestions** (consider improving):
- Optimization opportunities
- Architecture improvements
- Best practice recommendations

Always provide specific examples and remediation steps.
EOF

# Security Auditor
cat > .claude/agents/security-auditor.md << 'EOF'
---
name: security-auditor
description: Comprehensive security analysis for vulnerabilities, access control, and compliance. Use IMMEDIATELY for any security-sensitive operations.
model: opus
tools: Read, Grep, Bash
---

# Security Auditor

You are a cybersecurity expert specializing in application security and vulnerability assessment.

## Security Analysis Protocol
1. **Static Analysis**: Scan for common vulnerabilities
2. **Access Control Review**: Validate authentication/authorization
3. **Data Protection**: Check encryption and data handling
4. **Injection Attacks**: Test for SQL, XSS, command injection
5. **Configuration Security**: Review security settings
6. **Compliance Check**: Ensure regulatory compliance

## OWASP Top 10 Focus
- Injection attacks
- Broken authentication
- Sensitive data exposure
- XML external entities (XXE)
- Broken access control
- Security misconfiguration
- Cross-site scripting (XSS)
- Insecure deserialization
- Using components with known vulnerabilities
- Insufficient logging and monitoring

## Critical Security Patterns
- Input validation and sanitization
- Output encoding
- Parameterized queries
- Secure session management
- Proper error handling (no information leakage)
- Secrets management
- HTTPS enforcement

Provide specific remediation steps with secure code examples.
EOF

# Test Automator
cat > .claude/agents/test-automator.md << 'EOF'
---
name: test-automator
description: Comprehensive testing strategy including unit, integration, and end-to-end tests. Use proactively when code changes affect testable functionality.
model: sonnet
tools: Read, Write, Bash
---

# Test Automator

You are a test automation expert specializing in comprehensive test coverage and quality assurance.

## Testing Strategy
1. **Test Planning**: Analyze requirements and identify test scenarios
2. **Test Implementation**: Write comprehensive test suites
3. **Coverage Analysis**: Ensure adequate test coverage (>80%)
4. **Test Execution**: Run tests and analyze results
5. **Test Maintenance**: Update tests for code changes
6. **CI/CD Integration**: Automate test execution

## Test Categories
- **Unit Tests**: Function-level testing with mocking
- **Integration Tests**: Component interaction testing
- **End-to-End Tests**: User workflow testing
- **Performance Tests**: Load and stress testing
- **Security Tests**: Vulnerability testing

## Test Quality Standards
- Tests are readable and maintainable
- Proper test data management
- Effective use of mocking and stubbing
- Clear test naming conventions
- Comprehensive edge case coverage
- Fast execution times

## Test-Driven Development
- Write tests before implementation
- Red-Green-Refactor cycle
- Maintain test quality standards
- Continuous test improvement

Always provide specific test examples and explain testing rationale.
EOF

echo "🔧 Installing hook implementations..."

# Create all hook files with production-ready implementations
# (Hook implementations would be created here - using the examples above)

echo "📊 Setting up observability dashboard..."

# Create dashboard setup script
cat > .claude/setup-dashboard.sh << 'EOF'
#!/bin/bash
# Setup observability dashboard

echo "Setting up Claude Code Observability Dashboard..."

# Create dashboard directory
mkdir -p .claude/dashboard

# Install dependencies and start dashboard
cd .claude/dashboard
npm init -y
npm install vue@next websocket express sqlite3
npm start
EOF

chmod +x .claude/setup-dashboard.sh

echo "✅ Claude Code advanced configuration complete!"
echo ""
echo "Next steps:"
echo "1. Review and customize subagents in .claude/agents/"
echo "2. Configure environment variables for TTS and LLM APIs"
echo "3. Run './claude/setup-dashboard.sh' for observability"
echo "4. Test with: claude 'Review this codebase for security issues'"
echo ""
echo "🎉 Happy coding with Claude Code!"
```

### Best Practices for Primary Agent

#### Optimal Usage Patterns

```markdown
## Primary Agent Instructions

### Subagent Delegation Strategy
1. **Always consider subagent delegation** for specialized tasks
2. **Use explicit delegation** when you need specific expertise:
   - "Use the security-auditor subagent to analyze this authentication flow"
   - "Have the test-automator subagent create comprehensive tests"
   - "Ask the performance-optimizer subagent to improve this algorithm"

### Multi-Agent Workflows
1. **Sequential Coordination**: Use for dependent tasks
   - Analysis → Planning → Implementation → Testing → Review
2. **Parallel Execution**: Use for independent tasks
   - Code review + Security audit + Performance analysis
3. **Quality Gates**: Ensure validation between phases

### Hook Awareness
1. **Security Constraints**: Understand that dangerous operations are blocked
2. **Automatic Processing**: Know that results are automatically logged/processed
3. **Completion Enhancement**: Expect intelligent completion messages

### Context Management
1. **Preserve Main Context**: Delegate specialized work to subagents
2. **Use Thinking Modes**: Apply "think", "think hard", "think harder", "ultrathink"
3. **Maintain Focus**: Keep main conversation on high-level objectives

### Error Handling
1. **Hook Failures**: Gracefully handle when hooks fail (non-blocking)
2. **Subagent Errors**: Retry with different approaches or manual execution
3. **Security Blocks**: Respect security policies and suggest alternatives
```

### Configuration Validation

```python
# validate-setup.py - Ensure proper configuration
def validate_claude_code_setup():
    """Validate Claude Code configuration completeness."""
    checks = []
    
    # Check directory structure
    required_dirs = ['.claude', '.claude/agents', '.claude/hooks', '.claude/logs']
    for dir_path in required_dirs:
        if Path(dir_path).exists():
            checks.append(f"✅ {dir_path} exists")
        else:
            checks.append(f"❌ {dir_path} missing")
    
    # Check settings.json
    settings_path = Path('.claude/settings.json')
    if settings_path.exists():
        try:
            with open(settings_path) as f:
                settings = json.load(f)
            
            required_keys = ['hooks', 'security', 'subagent_defaults']
            for key in required_keys:
                if key in settings:
                    checks.append(f"✅ settings.{key} configured")
                else:
                    checks.append(f"❌ settings.{key} missing")
        except:
            checks.append("❌ settings.json invalid JSON")
    else:
        checks.append("❌ settings.json missing")
    
    # Check subagents
    agents_dir = Path('.claude/agents')
    if agents_dir.exists():
        agent_files = list(agents_dir.glob('*.md'))
        checks.append(f"✅ {len(agent_files)} subagents found")
    else:
        checks.append("❌ No subagents directory")
    
    # Check hooks
    hooks_dir = Path('.claude/hooks')
    if hooks_dir.exists():
        hook_files = list(hooks_dir.glob('*.py'))
        checks.append(f"✅ {len(hook_files)} hooks found")
    else:
        checks.append("❌ No hooks directory")
    
    return checks
```

---

## Conclusion: Transformative AI Development Platform

This guide provides comprehensive context for implementing **production-grade Claude Code automation** that transforms AI assistance from suggestion-based to guarantee-based development workflows.

### Key Capabilities Unlocked

1. **Deterministic Control**: Hooks ensure specific behaviors regardless of LLM variability
2. **Specialized Expertise**: Subagents provide domain-specific intelligence with isolated contexts
3. **Security Enforcement**: Multi-layer security policies with automatic threat detection
4. **Quality Assurance**: Automated code review, testing, and compliance checking
5. **Real-Time Observability**: Comprehensive monitoring and audit trails
6. **Scalable Architecture**: Production-ready patterns for enterprise deployment

### Implementation Priority

1. **Start with Core Subagents**: code-reviewer, security-auditor, test-automator
2. **Implement Security Hooks**: PreToolUse security gate is critical
3. **Add Notification System**: TTS for immediate feedback
4. **Expand Specialization**: Add domain-specific subagents as needed
5. **Enable Observability**: Monitor and optimize workflows

### Success Metrics

- **Security**: Zero security policy violations
- **Quality**: >80% test coverage maintained automatically
- **Efficiency**: Reduced manual review cycles by 70%
- **Reliability**: Consistent behavior across all development scenarios
- **Scalability**: System handles complex multi-agent workflows seamlessly

Use this guide as your primary reference for implementing advanced Claude Code automation that delivers **production-grade reliability** with **enterprise-level security** and **sophisticated multi-agent orchestration**.
