#!/usr/bin/env python3
"""
Prompt Enhancement Hook for Claude Code
Enhances user prompts with quality context and architectural guidance

This hook analyzes user prompts and adds:
1. Context about architectural standards
2. Suggestions for better patterns
3. Electrical theme guidance
4. Prevention of known anti-patterns
5. Quality reminders
"""

import sys
import os
import json
import yaml
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class PromptEnhancer:
    def __init__(self, config_path: str = None):
        """Initialize enhancer with quality configuration"""
        self.project_root = Path(__file__).parent.parent.parent
        self.config_path = config_path or self.project_root / "scripts/quality_checks/quality_config.yaml"
        self.config = self._load_config()
        
    def _load_config(self) -> Dict:
        """Load quality configuration from YAML"""
        try:
            with open(self.config_path, 'r') as f:
                return yaml.safe_load(f)
        except Exception as e:
            return self._default_config()
    
    def _default_config(self) -> Dict:
        """Fallback configuration if YAML not available"""
        return {
            "state_management": {"preferred": "riverpod"},
            "electrical_theme": {"mandatory_backgrounds": {"screens": ["splash", "home", "jobs", "locals"]}},
            "suggestions": {},
            "error_messages": {}
        }
    
    def enhance_prompt(self, user_prompt: str) -> str:
        """
        Enhance user prompt with quality context and guidance
        
        Args:
            user_prompt: Original user prompt
            
        Returns:
            str: Enhanced prompt with quality context
        """
        # Analyze prompt for patterns
        enhancements = []
        
        # Check for component creation requests
        component_enhancement = self._check_component_patterns(user_prompt)
        if component_enhancement:
            enhancements.append(component_enhancement)
        
        # Check for state management requests
        state_enhancement = self._check_state_management_patterns(user_prompt)
        if state_enhancement:
            enhancements.append(state_enhancement)
        
        # Check for screen creation requests
        screen_enhancement = self._check_screen_patterns(user_prompt)
        if screen_enhancement:
            enhancements.append(screen_enhancement)
        
        # Check for styling/color requests
        theme_enhancement = self._check_theme_patterns(user_prompt)
        if theme_enhancement:
            enhancements.append(theme_enhancement)
        
        # Check for job-related functionality
        job_enhancement = self._check_job_patterns(user_prompt)
        if job_enhancement:
            enhancements.append(job_enhancement)
        
        # Check for refactoring requests
        refactor_enhancement = self._check_refactor_patterns(user_prompt)
        if refactor_enhancement:
            enhancements.append(refactor_enhancement)
        
        # Add general quality reminders for development tasks
        quality_enhancement = self._add_quality_reminders(user_prompt)
        if quality_enhancement:
            enhancements.append(quality_enhancement)
        
        # Combine original prompt with enhancements
        if enhancements:
            enhanced_prompt = user_prompt + "\n\n" + "\n".join(enhancements)
            return enhanced_prompt
        
        return user_prompt
    
    def _check_component_patterns(self, prompt: str) -> Optional[str]:
        """Check for component creation patterns and provide guidance"""
        component_keywords = ["create component", "new component", "build component", "component for"]
        
        if any(keyword in prompt.lower() for keyword in component_keywords):
            if "job" in prompt.lower() and ("card" in prompt.lower() or "display" in prompt.lower()):
                return """
🚨 COMPONENT GUIDANCE: Job Card components already exist!
- Use existing JobCard with JobCardVariant.half or JobCardVariant.full
- Located: lib/design_system/components/job_card.dart
- Avoid creating duplicate job card components
- If new functionality needed, extend existing JobCard with additional parameters
"""
            
            return """
📋 COMPONENT BEST PRACTICES:
- Place reusable components in lib/design_system/components/
- Use ConsumerWidget for state access with Riverpod
- Include electrical theme elements (AppTheme.primaryNavy, AppTheme.accentCopper)
- Add proper documentation with /// comments
- Follow naming convention: ComponentNameWidget
"""
    
    def _check_state_management_patterns(self, prompt: str) -> Optional[str]:
        """Check for state management requests and provide Riverpod guidance"""
        state_keywords = ["state", "provider", "manage", "data flow", "state management"]
        
        if any(keyword in prompt.lower() for keyword in state_keywords):
            if "provider" in prompt.lower() and "riverpod" not in prompt.lower():
                return """
🔄 STATE MANAGEMENT GUIDANCE:
- This project uses Riverpod, not Provider
- Use ConsumerWidget instead of StatefulWidget
- Access state with ref.watch(providerName) or ref.read(providerName)
- Create providers in lib/providers/riverpod/
- Example: final jobsProvider = StateNotifierProvider<JobsNotifier, List<Job>>((ref) => JobsNotifier());
"""
        
        return None
    
    def _check_screen_patterns(self, prompt: str) -> Optional[str]:
        """Check for screen creation and provide electrical theme guidance"""
        screen_keywords = ["screen", "page", "new screen", "create screen", "build screen"]
        
        if any(keyword in prompt.lower() for keyword in screen_keywords):
            return """
⚡ SCREEN REQUIREMENTS:
- All screens must include electrical background: CircuitPatternBackground() or ElectricalBackground()
- Use ConsumerWidget for Riverpod state access
- Place in lib/screens/[category]/[screen_name]_screen.dart
- Include electrical theme colors: AppTheme.primaryNavy, AppTheme.accentCopper
- Add to app_router.dart for navigation
- Required structure: Scaffold with backgroundColor and proper AppBar placement
"""
    
    def _check_theme_patterns(self, prompt: str) -> Optional[str]:
        """Check for styling requests and provide theme guidance"""
        theme_keywords = ["color", "style", "theme", "design", "appearance", "ui"]
        
        if any(keyword in prompt.lower() for keyword in theme_keywords):
            return """
🎨 ELECTRICAL THEME GUIDANCE:
- Use AppTheme constants: AppTheme.primaryNavy, AppTheme.accentCopper
- Never use hardcoded Color(0xFF...) values
- Import: '../design_system/app_theme.dart'
- Primary colors: Navy (#1A202C) and Copper (#B45309)
- Include electrical elements: circuit patterns, lightning effects
- Use JJ prefix for custom components (e.g., JJButton, JJElectricalLoader)
"""
    
    def _check_job_patterns(self, prompt: str) -> Optional[str]:
        """Check for job-related functionality requests"""
        job_keywords = ["job", "position", "listing", "employment", "work"]
        
        if any(keyword in prompt.lower() for keyword in job_keywords):
            if "card" in prompt.lower() or "display" in prompt.lower():
                return """
💼 JOB FUNCTIONALITY GUIDANCE:
- Use existing JobCard component with variants (half/full)
- Job data model: lib/models/job_model.dart
- Job service: lib/services/job_service.dart (if needed)
- Job provider: lib/providers/riverpod/jobs_riverpod_provider.dart
- Follow IBEW electrical worker terminology
- Include storm work indicators where applicable
"""
        
        return None
    
    def _check_refactor_patterns(self, prompt: str) -> Optional[str]:
        """Check for refactoring requests and provide guidance"""
        refactor_keywords = ["refactor", "improve", "clean up", "optimize", "reorganize"]
        
        if any(keyword in prompt.lower() for keyword in refactor_keywords):
            return """
🔧 REFACTORING GUIDANCE:
- Maintain electrical theme consistency throughout changes
- Convert Provider patterns to Riverpod where found
- Ensure proper import organization (dart → flutter → packages → relative)
- Keep existing JobCard patterns, avoid creating duplicates
- Validate RichText follows Label: Value format
- Check for AppBar in correct Scaffold.appBar position
- Use AppTheme constants instead of hardcoded colors
"""
    
    def _add_quality_reminders(self, prompt: str) -> Optional[str]:
        """Add general quality reminders for development tasks"""
        dev_keywords = ["implement", "create", "build", "develop", "add", "make", "code"]
        
        if any(keyword in prompt.lower() for keyword in dev_keywords):
            return """
✅ QUALITY CHECKLIST:
- Use Riverpod (ConsumerWidget) for state management
- Include electrical backgrounds for screens
- Follow import organization: dart → flutter → packages → relative
- Use AppTheme constants for colors
- Place files in correct lib/ subdirectories
- Add /// documentation for new components
- Avoid duplicate components (especially JobCard variants)
- Ensure AppBar is in Scaffold.appBar, not body
"""
        
        return None

def main():
    """Main entry point for the prompt enhancement hook"""
    user_prompt = ""
    
    # Get user prompt from command line or stdin
    if len(sys.argv) > 1:
        user_prompt = " ".join(sys.argv[1:])
    else:
        try:
            # Read from stdin
            stdin_data = sys.stdin.read().strip()
            if stdin_data:
                try:
                    # Try to parse as JSON (Claude Code hook format)
                    hook_data = json.loads(stdin_data)
                    user_prompt = hook_data.get('prompt', stdin_data)
                except json.JSONDecodeError:
                    user_prompt = stdin_data
        except:
            user_prompt = "No prompt provided"
    
    if not user_prompt or user_prompt == "No prompt provided":
        # If no prompt provided, just exit
        sys.exit(0)
    
    enhancer = PromptEnhancer()
    enhanced_prompt = enhancer.enhance_prompt(user_prompt)
    
    # Output the enhanced prompt
    print(enhanced_prompt)
    
    sys.exit(0)

if __name__ == "__main__":
    main()