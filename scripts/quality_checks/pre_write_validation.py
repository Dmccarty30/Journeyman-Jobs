#!/usr/bin/env python3
"""
Pre-Write Validation Hook for Claude Code
Validates Write operations for architectural compliance and prevents technical debt

This hook ensures new files follow:
1. Proper Riverpod patterns for state management
2. Electrical background inclusion for screens
3. Correct file organization and naming
4. Import organization standards
5. Component architecture compliance
"""

import sys
import os
import json
import yaml
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class PreWriteValidator:
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
            "file_organization": {"screen_files": {"location": "lib/screens/", "suffix": "_screen.dart"}},
            "quality_gates": {"syntax_validation": {"blocking": True}}
        }
    
    def validate_write_operation(self, file_path: str, content: str) -> bool:
        """
        Validate a Write operation before file creation
        
        Args:
            file_path: Path where file will be written
            content: Content that will be written
            
        Returns:
            bool: True if validation passes, False if blocking errors found
        """
        self.errors.clear()
        self.warnings.clear()
        
        # Skip validation for non-Dart files
        if not file_path.endswith('.dart'):
            return True
            
        # Run validation checks
        self._validate_file_location(file_path, content)
        self._validate_file_naming(file_path, content)
        self._validate_screen_requirements(file_path, content)
        self._validate_riverpod_patterns(file_path, content)
        self._validate_import_organization(file_path, content)
        self._validate_component_architecture(file_path, content)
        self._validate_electrical_theme_new_file(file_path, content)
        self._validate_flutter_flow_legacy(file_path, content)
        
        # Report results
        self._report_results(file_path)
        
        # Return True if no blocking errors
        return len(self.errors) == 0
    
    def _validate_file_location(self, file_path: str, content: str):
        """Ensure files are placed in correct directories"""
        normalized_path = file_path.replace("\\", "/")
        
        # Screen files validation
        if "_screen.dart" in file_path:
            expected_location = self.config.get("file_organization", {}).get("screen_files", {}).get("location", "lib/screens/")
            if not normalized_path.startswith(expected_location.replace("\\", "/")):
                self.errors.append(f"Screen file in wrong location: {file_path}")
                self.errors.append(f"Move to: {expected_location}")
        
        # Widget files validation
        if "widget" in file_path.lower() and not any(loc in normalized_path for loc in ["lib/widgets/", "lib/design_system/components/"]):
            self.warnings.append(f"Widget file location: {file_path}")
            self.warnings.append("Consider placing in lib/widgets/ or lib/design_system/components/")
        
        # Service files validation
        if "_service.dart" in file_path:
            if not normalized_path.startswith("lib/services/"):
                self.errors.append(f"Service file in wrong location: {file_path}")
                self.errors.append("Move to: lib/services/")
    
    def _validate_file_naming(self, file_path: str, content: str):
        """Validate file naming conventions"""
        filename = Path(file_path).name
        
        # Check for forbidden prefixes
        forbidden_prefixes = self.config.get("file_organization", {}).get("widget_files", {}).get("forbidden_prefixes", [])
        for prefix in forbidden_prefixes:
            if filename.startswith(prefix):
                self.errors.append(f"Forbidden filename prefix: {prefix}")
                self.errors.append("Remove legacy/backup prefixes from filename")
        
        # Check naming convention (snake_case)
        if not re.match(r'^[a-z0-9_]+\.dart$', filename):
            self.warnings.append(f"Filename not in snake_case: {filename}")
            self.warnings.append("Use snake_case naming convention")
    
    def _validate_screen_requirements(self, file_path: str, content: str):
        """Validate requirements for screen files"""
        if "_screen.dart" not in file_path:
            return
            
        # Check for proper widget inheritance
        required_patterns = self.config.get("file_organization", {}).get("screen_files", {}).get("required_patterns", [])
        
        widget_patterns = ["StatelessWidget", "ConsumerWidget", "ConsumerStatefulWidget"]
        has_proper_widget = any(pattern in content for pattern in widget_patterns)
        
        if not has_proper_widget:
            self.errors.append("Screen must extend StatelessWidget, ConsumerWidget, or ConsumerStatefulWidget")
            self.errors.append("Use ConsumerWidget for Riverpod state access")
        
        # Check for electrical background inclusion
        screen_name = Path(file_path).stem.replace("_screen", "")
        mandatory_screens = self.config.get("electrical_theme", {}).get("mandatory_backgrounds", {}).get("screens", [])
        
        if screen_name in mandatory_screens:
            electrical_patterns = ["CircuitPatternBackground", "ElectricalBackground"]
            has_electrical_bg = any(pattern in content for pattern in electrical_patterns)
            
            if not has_electrical_bg:
                self.errors.append(f"Screen {screen_name} requires electrical background")
                self.errors.append("Add CircuitPatternBackground() or ElectricalBackground() component")
    
    def _validate_riverpod_patterns(self, file_path: str, content: str):
        """Ensure new files use Riverpod patterns correctly"""
        # Check for Provider imports (forbidden)
        forbidden_imports = self.config.get("state_management", {}).get("forbidden_imports", [])
        for forbidden in forbidden_imports:
            if forbidden in content:
                self.errors.append(f"Forbidden import in new file: {forbidden}")
                self.errors.append("Use flutter_riverpod instead")
        
        # If state management is used, ensure it's Riverpod
        if "Provider" in content and "flutter_riverpod" not in content:
            self.errors.append("State management detected without Riverpod")
            self.errors.append("Import flutter_riverpod and use ConsumerWidget")
        
        # Check for proper Riverpod patterns
        if "ConsumerWidget" in content or "ConsumerStatefulWidget" in content:
            if "ref.watch" not in content and "ref.read" not in content:
                self.warnings.append("ConsumerWidget without ref usage detected")
                self.warnings.append("Use ref.watch(provider) or ref.read(provider) to access state")
    
    def _validate_import_organization(self, file_path: str, content: str):
        """Validate import organization for new files"""
        lines = content.split('\n')
        import_lines = [line for line in lines if line.strip().startswith('import')]
        
        if not import_lines:
            return
        
        # Check import order
        dart_imports = [line for line in import_lines if 'dart:' in line]
        flutter_imports = [line for line in import_lines if 'package:flutter' in line]
        package_imports = [line for line in import_lines if 'package:' in line and 'package:flutter' not in line and 'package:journeyman_jobs' not in line]
        relative_imports = [line for line in import_lines if not line.strip().startswith('import \'package:') and not 'dart:' in line]
        
        # Warn about order if not following convention
        current_order = []
        if dart_imports: current_order.append('dart')
        if flutter_imports: current_order.append('flutter')
        if package_imports: current_order.append('package')
        if relative_imports: current_order.append('relative')
        
        expected_order = ['dart', 'flutter', 'package', 'relative']
        if current_order != expected_order[:len(current_order)]:
            self.warnings.append("Import order not optimal")
            self.warnings.append("Order: dart:* → package:flutter/* → package:* → relative imports")
    
    def _validate_component_architecture(self, file_path: str, content: str):
        """Validate component architecture patterns"""
        # Check for duplicate component creation
        if "job_card" in file_path.lower():
            self.errors.append("Job card component duplication detected")
            self.errors.append("Use existing JobCard with JobCardVariant.half or JobCardVariant.full")
        
        # Check for proper component structure
        if "class " in content and "extends StatelessWidget" in content:
            # Look for required component documentation
            if not re.search(r'///.*', content):
                self.warnings.append("Component missing documentation")
                self.warnings.append("Add /// documentation for the component class")
    
    def _validate_electrical_theme_new_file(self, file_path: str, content: str):
        """Validate electrical theme compliance for new files"""
        # Check for hardcoded colors in new files
        if re.search(r'Color\(0x[0-9A-Fa-f]{8}\)', content):
            self.warnings.append("Hardcoded colors in new file")
            self.warnings.append("Use AppTheme constants: AppTheme.primaryNavy, AppTheme.accentCopper")
        
        # Check for AppTheme import if colors are used
        if "Color(" in content or "Colors." in content:
            if "app_theme.dart" not in content and "AppTheme." not in content:
                self.warnings.append("Color usage without AppTheme import")
                self.warnings.append("Import '../design_system/app_theme.dart' and use AppTheme constants")
    
    def _validate_flutter_flow_legacy(self, file_path: str, content: str):
        """Check for FlutterFlow legacy patterns"""
        legacy_patterns = [
            "FlutterFlow",
            "FFLocalizations",
            "widget.parameter",  # Common FlutterFlow pattern
            "backend.dart"
        ]
        
        for pattern in legacy_patterns:
            if pattern in content:
                self.warnings.append(f"FlutterFlow legacy pattern detected: {pattern}")
                self.warnings.append("Convert to modern Flutter/Riverpod patterns")
    
    def _report_results(self, file_path: str):
        """Report validation results"""
        if self.errors or self.warnings:
            print(f"\n🔍 Pre-Write Validation Results for: {file_path}")
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
            print(f"✅ Pre-Write validation passed for: {file_path}")

def main():
    """Main entry point for the pre-write validation hook"""
    if len(sys.argv) < 3:
        print("Usage: pre_write_validation.py <file_path> <content>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    content = sys.argv[2] if len(sys.argv) > 2 else ""
    
    # For Claude Code hooks, content might be passed via stdin
    if not content:
        try:
            stdin_data = sys.stdin.read().strip()
            if stdin_data:
                # Parse JSON if it's hook data
                try:
                    hook_data = json.loads(stdin_data)
                    file_path = hook_data.get('file_path', file_path)
                    content = hook_data.get('content', '')
                except json.JSONDecodeError:
                    content = stdin_data
        except:
            pass
    
    validator = PreWriteValidator()
    
    # Validate the write operation
    validation_passed = validator.validate_write_operation(file_path, content)
    
    # Exit with appropriate code
    sys.exit(0 if validation_passed else 1)

if __name__ == "__main__":
    main()