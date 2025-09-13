# Quality Enforcement Scripts

This directory contains the Claude Code hook scripts that enforce quality standards and prevent technical debt in the Journeyman Jobs Flutter project.

## 🎯 Purpose

These scripts act as intelligent guardrails during development, automatically:
- Preventing duplicate component creation
- Enforcing Riverpod state management patterns  
- Ensuring electrical theme compliance
- Validating architectural consistency
- Providing proactive guidance to developers

## 📁 Files

### Core Scripts
- **`pre_edit_validation.py`** - Validates Edit/MultiEdit operations before execution
- **`pre_write_validation.py`** - Validates Write operations for new file creation
- **`post_change_validation.py`** - Comprehensive validation after file modifications
- **`prompt_enhancement.py`** - Enhances user prompts with quality guidance

### Configuration
- **`quality_config.yaml`** - Centralized quality rules and patterns
- **`test_hooks.py`** - Comprehensive test suite for all hooks

## 🚀 Quick Start

### Test the Hook System
```bash
# Run comprehensive test suite
python3 scripts/quality_checks/test_hooks.py

# Test individual hooks
python3 scripts/quality_checks/pre_edit_validation.py "lib/test.dart" "old" "new content"
python3 scripts/quality_checks/pre_write_validation.py "lib/test.dart" "content"
python3 scripts/quality_checks/prompt_enhancement.py "Create a job card component"
```

### Manual Validation
```bash
# Check a specific file after modification
python3 scripts/quality_checks/post_change_validation.py "lib/screens/home_screen.dart" "Edit"

# Test prompt enhancement
python3 scripts/quality_checks/prompt_enhancement.py "Build a new screen for unions"
```

## ⚙️ Integration with Claude Code

The hooks are automatically triggered by Claude Code through the configuration in `.claude/settings.json`:

### PreToolUse Hooks (Blocking)
- Trigger before Edit/MultiEdit/Write operations
- Block execution if critical errors found
- Prevent technical debt introduction

### PostToolUse Hooks (Non-blocking)  
- Run after file modifications
- Provide warnings and suggestions
- Include flutter analyze validation

### UserPromptSubmit Hooks (Enhancement)
- Enhance user prompts with quality guidance
- Provide context-aware suggestions
- Educate about best practices

## 🔍 Validation Categories

### 1. State Management
- **Prevents**: Provider usage when Riverpod exists
- **Enforces**: ConsumerWidget patterns
- **Detects**: Mixed state management approaches

### 2. Component Architecture
- **Prevents**: Job card duplication (primary concern)
- **Enforces**: Use of existing JobCard variants
- **Validates**: Proper component documentation

### 3. Electrical Theme Compliance
- **Requires**: Electrical backgrounds on mandatory screens
- **Enforces**: AppTheme constant usage
- **Prevents**: Hardcoded color values

### 4. File Organization
- **Validates**: Correct directory placement
- **Enforces**: Naming conventions
- **Checks**: Import organization

### 5. Widget Structure
- **Prevents**: AppBar nesting in Scaffold body
- **Validates**: RichText Label: Value patterns
- **Checks**: Performance anti-patterns

## 📊 Expected Results

### Successful Validation
```
✅ Pre-Edit validation passed for: lib/test.dart
```

### Blocking Errors (PreToolUse)
```
❌ BLOCKING ERRORS:
  • Forbidden import detected: package:provider/provider.dart
  • Use flutter_riverpod instead of Provider
```

### Warnings (PostToolUse)
```
⚠️ WARNINGS:
  • RichText may not follow Label: Value pattern
  • Use format: TextSpan(text: 'Label: '), TextSpan(text: value)
```

### Enhanced Prompts
```
Original: "Create a new job card component"

Enhanced:
🚨 COMPONENT GUIDANCE: Job Card components already exist!
- Use existing JobCard with JobCardVariant.half or JobCardVariant.full
- Located: lib/design_system/components/job_card.dart
```

## 🛠️ Customization

### Modify Rules
Edit `quality_config.yaml` to adjust:
- Forbidden patterns
- Required components
- File location rules
- Error messages

### Add New Validations
1. Update the appropriate Python script
2. Add test cases to `test_hooks.py`
3. Update configuration in `quality_config.yaml`
4. Run tests to validate

### Performance Tuning
- Adjust timeout values in `.claude/settings.json`
- Enable/disable specific checks in `quality_config.yaml`
- Modify strictness levels for different environments

## 🐛 Troubleshooting

### Hook Not Triggering
- Check `.claude/settings.json` configuration
- Verify script file permissions (should be executable)
- Ensure Python 3 is available

### Validation Errors
- Check script syntax with `python3 -m py_compile script_name.py`
- Verify YAML configuration is valid
- Run test suite to identify issues

### Performance Issues
- Increase timeout values if needed
- Disable flutter analyze for faster validation
- Use non-blocking mode for development

## 📈 Monitoring

### Track Hook Effectiveness
- Monitor exit codes (0 = success, 1 = blocking errors)
- Count prevented technical debt instances
- Gather developer feedback on guidance quality

### Success Metrics
- Test suite pass rate (target: >90%)
- Reduced technical debt accumulation
- Improved code consistency
- Developer adoption and satisfaction

This quality enforcement system represents the culmination of the technical debt cleanup process, transitioning from reactive fixing to proactive prevention.