#!/usr/bin/env python3
"""
Pre-Edit Validation Hook for Claude Code
Prevents technical debt patterns during Edit/MultiEdit operations

This hook validates that Edit/MultiEdit operations don't introduce:
1. Duplicate job card patterns
2. Provider usage when Riverpod exists
3. AppBar nesting in body content
4. Hardcoded colors instead of AppTheme
5. Poor import organization
"""

import sys
import os
import json
import yaml
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class PreEditValidator:
    def __init__(self, config_path: str = None):
        """Initialize validator with quality configuration"""
        self.project_root = Path(__file__).parent.parent.parent
        self.config_path = config_path or self.project_root / "scripts/quality_checks/quality_config.yaml"
        self.config = self._load_config()
        self.errors = []
        self.warnings = []
        
    def _load_config(self) -> Dict:
        """Load quality configuration from YAML"""
        try:
            with open(self.config_path, 'r') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"Warning: Could not load config from {self.config_path}: {e}")
            return self._default_config()
    
    def _default_config(self) -> Dict:
        """Fallback configuration if YAML not available"""
        return {
            "state_management": {"preferred": "riverpod"},
            "electrical_theme": {"mandatory_backgrounds": {"screens": ["splash", "home", "jobs", "locals"]}},
            "component_patterns": {"job_cards": {"max_variants": 2}},
            "quality_gates": {"syntax_validation": {"blocking": True}}
        }
    
    def validate_edit_operation(self, file_path: str, old_content: str, new_content: str) -> bool:
        """
        Validate an Edit operation before it's applied
        
        Args:
            file_path: Path to file being edited
            old_content: Original file content
            new_content: Proposed new content
            
        Returns:
            bool: True if validation passes, False if blocking errors found
        """
        self.errors.clear()
        self.warnings.clear()
        
        # Skip validation for non-Dart files
        if not file_path.endswith('.dart'):
            return True
            
        # Run validation checks
        self._validate_provider_usage(file_path, new_content)
        self._validate_job_card_duplication(file_path, new_content)
        self._validate_appbar_placement(file_path, new_content)
        self._validate_color_usage(file_path, new_content)
        self._validate_import_organization(file_path, new_content)
        self._validate_electrical_theme(file_path, new_content)
        self._validate_widget_structure(file_path, new_content)
        
        # Report results
        self._report_results(file_path)
        
        # Return True if no blocking errors
        return len(self.errors) == 0
    
    def _validate_provider_usage(self, file_path: str, content: str):
        """Check for Provider usage when Riverpod should be used"""
        forbidden_imports = self.config.get("state_management", {}).get("forbidden_imports", [])
        
        for forbidden in forbidden_imports:
            if forbidden in content:
                self.errors.append(f"Forbidden import detected: {forbidden}")
                self.errors.append("Use flutter_riverpod instead of Provider")
        
        # Check for Provider patterns
        provider_patterns = [
            r"Provider\.of\s*\(",
            r"Consumer<.*>",
            r"ChangeNotifierProvider",
            r"StateProvider\s*\("  # Old Provider pattern, not Riverpod
        ]
        
        for pattern in provider_patterns:
            if re.search(pattern, content):
                self.errors.append(f"Provider pattern detected: {pattern}")
                self.errors.append("Convert to Riverpod: ConsumerWidget + ref.watch(provider)")
    
    def _validate_job_card_duplication(self, file_path: str, content: str):
        """Prevent job card component duplication"""
        if "job_card" in file_path.lower() or "jobcard" in file_path.lower():
            # Check if this is creating a new job card variant
            existing_job_cards = [
                "lib/design_system/components/job_card.dart",
                "lib/widgets/rich_text_job_card.dart"
            ]
            
            normalized_path = file_path.replace("\\", "/")
            if normalized_path not in existing_job_cards:
                self.errors.append("Job card duplication detected")
                self.errors.append("Use existing JobCard with JobCardVariant.half or JobCardVariant.full")
        
        # Check for duplicate component creation in content
        if re.search(r"class\s+\w*JobCard\w*\s+extends", content):
            if "JobCard extends StatelessWidget" not in content:
                self.errors.append("Duplicate JobCard class detected")
                self.errors.append("Use existing JobCard component with variant parameter")
    
    def _validate_appbar_placement(self, file_path: str, content: str):
        """Ensure AppBar is not nested in Scaffold body"""
        # Check for AppBar in body instead of appBar property
        appbar_in_body_patterns = [
            r"body:\s*.*AppBar\s*\(",
            r"children:\s*\[.*AppBar\s*\(",
            r"Column\s*\(.*children:\s*\[.*AppBar"
        ]
        
        for pattern in appbar_in_body_patterns:
            if re.search(pattern, content, re.DOTALL):
                self.errors.append("AppBar nested in Scaffold body detected")
                self.errors.append("Move AppBar to Scaffold.appBar property")
    
    def _validate_color_usage(self, file_path: str, content: str):
        """Check for hardcoded colors instead of AppTheme usage"""
        # Look for hardcoded Color() constructors
        hardcoded_patterns = [
            r"Color\(0x[0-9A-Fa-f]{8}\)",
            r"Colors\.\w+(?!\.transparent|\.white|\.black)"
        ]
        
        for pattern in hardcoded_patterns:
            matches = re.findall(pattern, content)
            if matches:
                for match in matches:
                    self.warnings.append(f"Hardcoded color detected: {match}")
                    self.warnings.append("Use AppTheme constants: AppTheme.primaryNavy, AppTheme.accentCopper")
    
    def _validate_import_organization(self, file_path: str, content: str):
        """Check import organization and suggest improvements"""
        lines = content.split('\n')
        import_lines = [line for line in lines if line.strip().startswith('import')]
        
        # Check for too many parent directory traversals
        for line in import_lines:
            if "../../../" in line:
                self.warnings.append(f"Excessive parent directory traversal: {line.strip()}")
                self.warnings.append("Consider using absolute imports or restructuring")
        
        # Check for internal package imports that should be relative
        for line in import_lines:
            if "package:journeyman_jobs/" in line:
                self.warnings.append(f"Internal package import should be relative: {line.strip()}")
                self.warnings.append("Use relative imports for internal files")
    
    def _validate_electrical_theme(self, file_path: str, content: str):
        """Ensure electrical theme compliance for screens"""
        if "_screen.dart" in file_path:
            screen_name = Path(file_path).stem.replace("_screen", "")
            mandatory_screens = self.config.get("electrical_theme", {}).get("mandatory_backgrounds", {}).get("screens", [])
            
            if screen_name in mandatory_screens:
                # Check for electrical background components
                electrical_patterns = [
                    "CircuitPatternBackground",
                    "ElectricalBackground",
                    "circuit_pattern_painter.dart"
                ]
                
                has_electrical_bg = any(pattern in content for pattern in electrical_patterns)
                if not has_electrical_bg:
                    self.warnings.append(f"Screen {screen_name} missing electrical background")
                    self.warnings.append("Add CircuitPatternBackground() or ElectricalBackground() component")
    
    def _validate_widget_structure(self, file_path: str, content: str):
        """Validate widget structure patterns"""
        # Check RichText usage pattern
        if "RichText" in content:
            # Look for proper Label: Value pattern
            if not re.search(r"TextSpan.*text:\s*['\"].*:['\"]", content):
                self.warnings.append("RichText usage may not follow Label: Value pattern")
                self.warnings.append("Use format: TextSpan(text: 'Label: ', style: ...), TextSpan(text: value)")
    
    def _report_results(self, file_path: str):
        """Report validation results"""
        if self.errors or self.warnings:
            print(f"\n🔍 Pre-Edit Validation Results for: {file_path}")
            print("=" * 60)
            
            if self.errors:
                print("❌ BLOCKING ERRORS:")
                for error in self.errors:
                    print(f"  • {error}")
                
            if self.warnings:
                print("\n⚠️  WARNINGS:")
                for warning in self.warnings:
                    print(f"  • {warning}")
            
            print("\n" + "=" * 60)
        else:
            print(f"✅ Pre-Edit validation passed for: {file_path}")

def main():
    """Main entry point for the pre-edit validation hook"""
    if len(sys.argv) < 4:
        print("Usage: pre_edit_validation.py <file_path> <old_content> <new_content>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    old_content = sys.argv[2] if len(sys.argv) > 2 else ""
    new_content = sys.argv[3] if len(sys.argv) > 3 else ""
    
    # For Claude Code hooks, content might be passed via stdin
    if not new_content and not old_content:
        # Read from stdin if available
        try:
            stdin_data = sys.stdin.read().strip()
            if stdin_data:
                # Parse JSON if it's hook data
                try:
                    hook_data = json.loads(stdin_data)
                    file_path = hook_data.get('file_path', file_path)
                    old_content = hook_data.get('old_content', '')
                    new_content = hook_data.get('new_content', '')
                except json.JSONDecodeError:
                    new_content = stdin_data
        except:
            pass
    
    validator = PreEditValidator()
    
    # If we have a real file path, read the current content
    if os.path.exists(file_path) and not old_content:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                old_content = f.read()
        except Exception as e:
            print(f"Warning: Could not read file {file_path}: {e}")
    
    # Validate the edit operation
    validation_passed = validator.validate_edit_operation(file_path, old_content, new_content)
    
    # Exit with appropriate code
    sys.exit(0 if validation_passed else 1)

if __name__ == "__main__":
    main()