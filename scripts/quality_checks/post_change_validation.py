#!/usr/bin/env python3
"""
Post-Change Validation Hook for Claude Code
Validates all file modifications after Edit/MultiEdit/Write operations

This hook provides post-operation validation including:
1. Flutter analyze for syntax errors
2. Rich Text formatting compliance
3. Architectural consistency checks
4. Import validation
5. Performance pattern validation
"""

import sys
import os
import json
import yaml
import re
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class PostChangeValidator:
    def __init__(self, config_path: str = None):
        """Initialize validator with quality configuration"""
        self.project_root = Path(__file__).parent.parent.parent
        self.config_path = config_path or self.project_root / "scripts/quality_checks/quality_config.yaml"
        self.config = self._load_config()
        self.errors = []
        self.warnings = []
        self.info = []
        
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
            "quality_gates": {
                "syntax_validation": {"enabled": True, "tool": "flutter analyze"},
                "import_validation": {"enabled": True},
                "theme_validation": {"enabled": True},
                "duplication_check": {"enabled": True}
            }
        }
    
    def validate_post_change(self, file_path: str, operation: str = "unknown") -> bool:
        """
        Validate file after modification
        
        Args:
            file_path: Path to the modified file
            operation: Type of operation (Edit, MultiEdit, Write)
            
        Returns:
            bool: True if validation passes, False if critical errors found
        """
        self.errors.clear()
        self.warnings.clear()
        self.info.clear()
        
        # Skip validation for non-Dart files
        if not file_path.endswith('.dart'):
            return True
        
        # Check if file exists
        if not os.path.exists(file_path):
            self.errors.append(f"File not found after {operation}: {file_path}")
            return False
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            self.errors.append(f"Could not read file: {e}")
            return False
        
        # Run validation checks
        self._validate_syntax(file_path)
        self._validate_rich_text_patterns(file_path, content)
        self._validate_import_consistency(file_path, content)
        self._validate_architectural_consistency(file_path, content)
        self._validate_performance_patterns(file_path, content)
        self._validate_electrical_theme_consistency(file_path, content)
        self._check_component_duplication(file_path, content)
        
        # Report results
        self._report_results(file_path, operation)
        
        # Return True if no critical errors (warnings are OK)
        return len(self.errors) == 0
    
    def _validate_syntax(self, file_path: str):
        """Run flutter analyze on the specific file"""
        if not self.config.get("quality_gates", {}).get("syntax_validation", {}).get("enabled", True):
            return
        
        try:
            # Change to project directory for flutter analyze
            os.chdir(self.project_root)
            
            # Run flutter analyze on specific file
            result = subprocess.run(
                ["flutter", "analyze", file_path],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode != 0:
                # Parse analyze output for errors
                output = result.stdout + result.stderr
                if "error" in output.lower() or "Error" in output:
                    self.errors.append("Flutter analyze found syntax errors")
                    # Extract specific errors
                    for line in output.split('\n'):
                        if 'error' in line.lower() and file_path in line:
                            self.errors.append(f"Syntax error: {line.strip()}")
                elif "warning" in output.lower():
                    self.warnings.append("Flutter analyze found warnings")
                    for line in output.split('\n'):
                        if 'warning' in line.lower() and file_path in line:
                            self.warnings.append(f"Warning: {line.strip()}")
            else:
                self.info.append("✅ Flutter analyze passed")
                
        except subprocess.TimeoutExpired:
            self.warnings.append("Flutter analyze timed out")
        except FileNotFoundError:
            self.warnings.append("Flutter CLI not found - skipping syntax validation")
        except Exception as e:
            self.warnings.append(f"Flutter analyze failed: {e}")
    
    def _validate_rich_text_patterns(self, file_path: str, content: str):
        """Validate RichText usage follows Label: Value pattern"""
        if "RichText" not in content:
            return
        
        # Look for RichText widgets
        richtext_matches = re.finditer(r'RichText\s*\(.*?children:\s*\[(.*?)\]', content, re.DOTALL)
        
        for match in richtext_matches:
            spans_content = match.group(1)
            
            # Check for proper Label: Value pattern
            if "TextSpan" in spans_content:
                # Look for label pattern
                label_pattern = r'TextSpan\s*\(.*?text:\s*[\'\"](.*?)[\'\"]'
                labels = re.findall(label_pattern, spans_content)
                
                has_proper_format = False
                for label in labels:
                    if ':' in label and (label.endswith(':') or label.endswith(': ')):
                        has_proper_format = True
                        break
                
                if not has_proper_format:
                    self.warnings.append("RichText may not follow Label: Value pattern")
                    self.warnings.append("Use format: TextSpan(text: 'Label: '), TextSpan(text: value)")
    
    def _validate_import_consistency(self, file_path: str, content: str):
        """Check import organization and consistency"""
        lines = content.split('\n')
        import_lines = [line for line in lines if line.strip().startswith('import')]
        
        if not import_lines:
            return
        
        # Check for unused imports (basic check)
        for import_line in import_lines:
            # Extract imported name/library
            if " as " in import_line:
                # Handle aliased imports
                alias = import_line.split(" as ")[1].split(";")[0].strip()
                if alias not in content.replace(import_line, ""):
                    self.warnings.append(f"Potentially unused import alias: {alias}")
            elif "'package:" in import_line:
                # Check if package is used
                package_match = re.search(r"'package:([^/]+)", import_line)
                if package_match:
                    package_name = package_match.group(1)
                    # Simple check - look for package usage
                    if package_name not in content.replace(import_line, ""):
                        # Skip common packages that might be used indirectly
                        if package_name not in ['flutter', 'dart']:
                            self.warnings.append(f"Potentially unused package: {package_name}")
        
        # Check import order
        self._check_import_order(import_lines)
    
    def _check_import_order(self, import_lines: List[str]):
        """Check if imports follow the expected order"""
        dart_imports = []
        flutter_imports = []
        package_imports = []
        relative_imports = []
        
        for line in import_lines:
            if 'dart:' in line:
                dart_imports.append(line)
            elif 'package:flutter' in line:
                flutter_imports.append(line)
            elif 'package:' in line:
                package_imports.append(line)
            else:
                relative_imports.append(line)
        
        # Expected order: dart, flutter, package, relative
        expected_order = dart_imports + flutter_imports + package_imports + relative_imports
        
        if import_lines != expected_order:
            self.warnings.append("Import order could be improved")
            self.warnings.append("Suggested order: dart:* → package:flutter/* → package:* → relative")
    
    def _validate_architectural_consistency(self, file_path: str, content: str):
        """Check architectural consistency after changes"""
        # Check for mixed state management patterns
        has_provider = any(pattern in content for pattern in ["Provider.of", "Consumer<", "ChangeNotifierProvider"])
        has_riverpod = any(pattern in content for pattern in ["ConsumerWidget", "ref.watch", "ref.read"])
        
        if has_provider and has_riverpod:
            self.warnings.append("Mixed state management patterns detected")
            self.warnings.append("Consistency: Use either Provider OR Riverpod, not both")
        
        # Check widget hierarchy
        if "Scaffold" in content and "AppBar" in content:
            # Ensure AppBar is not in body
            scaffold_matches = re.finditer(r'Scaffold\s*\((.*?)\)', content, re.DOTALL)
            for match in scaffold_matches:
                scaffold_content = match.group(1)
                if "body:" in scaffold_content and "AppBar(" in scaffold_content:
                    body_start = scaffold_content.find("body:")
                    appbar_pos = scaffold_content.find("AppBar(")
                    if appbar_pos > body_start:
                        self.errors.append("AppBar found in Scaffold body")
                        self.errors.append("Move AppBar to Scaffold.appBar property")
    
    def _validate_performance_patterns(self, file_path: str, content: str):
        """Check for performance anti-patterns"""
        # Check for setState in build method
        if "setState" in content and "build(" in content:
            # Look for setState calls within build method
            build_methods = re.finditer(r'Widget\s+build\s*\([^)]*\)\s*{(.*?)}', content, re.DOTALL)
            for build_match in build_methods:
                build_content = build_match.group(1)
                if "setState" in build_content:
                    self.warnings.append("setState called in build method")
                    self.warnings.append("Performance: Move setState to event handlers")
        
        # Check for expensive operations in build
        expensive_patterns = [
            "DateTime.now()",
            "Random(",
            "http.get(",
            "File(",
            "json.decode("
        ]
        
        if "build(" in content:
            for pattern in expensive_patterns:
                if pattern in content:
                    self.warnings.append(f"Expensive operation in widget: {pattern}")
                    self.warnings.append("Performance: Move to initState or use FutureBuilder")
    
    def _validate_electrical_theme_consistency(self, file_path: str, content: str):
        """Ensure electrical theme consistency is maintained"""
        # Check for hardcoded colors
        hardcoded_colors = re.findall(r'Color\(0x[0-9A-Fa-f]{8}\)', content)
        if hardcoded_colors:
            self.warnings.append(f"Hardcoded colors found: {len(hardcoded_colors)} instances")
            self.warnings.append("Consider using AppTheme constants for consistency")
        
        # Check for electrical theme usage
        if "_screen.dart" in file_path:
            electrical_indicators = ["CircuitPattern", "Electrical", "AppTheme.primaryNavy", "AppTheme.accentCopper"]
            has_electrical_theme = any(indicator in content for indicator in electrical_indicators)
            
            if not has_electrical_theme:
                self.warnings.append("Screen may be missing electrical theme elements")
                self.warnings.append("Consider adding electrical background or theme colors")
    
    def _check_component_duplication(self, file_path: str, content: str):
        """Check for component duplication after changes"""
        # Look for duplicate class definitions
        class_matches = re.findall(r'class\s+(\w+)\s+extends\s+StatelessWidget', content)
        
        # Check for common duplication patterns
        if "JobCard" in content and "_screen.dart" not in file_path:
            self.warnings.append("JobCard usage detected in component file")
            self.warnings.append("Ensure no duplicate JobCard implementations exist")
        
        # Check for multiple similar widgets in same file
        widget_classes = [match for match in class_matches if "Widget" in match or "Card" in match]
        if len(widget_classes) > 3:
            self.warnings.append(f"Many widget classes in single file: {len(widget_classes)}")
            self.warnings.append("Consider splitting into separate files for maintainability")
    
    def _report_results(self, file_path: str, operation: str):
        """Report validation results"""
        print(f"\n🔍 Post-{operation} Validation Results for: {file_path}")
        print("=" * 60)
        
        if self.errors:
            print("❌ CRITICAL ERRORS:")
            for error in self.errors:
                print(f"  • {error}")
        
        if self.warnings:
            print("\n⚠️  WARNINGS:")
            for warning in self.warnings:
                print(f"  • {warning}")
        
        if self.info:
            print("\n✅ INFO:")
            for info in self.info:
                print(f"  • {info}")
        
        if not self.errors and not self.warnings:
            print("✅ All post-change validations passed!")
        
        print("\n" + "=" * 60)

def main():
    """Main entry point for the post-change validation hook"""
    if len(sys.argv) < 2:
        print("Usage: post_change_validation.py <file_path> [operation]")
        sys.exit(1)
    
    file_path = sys.argv[1]
    operation = sys.argv[2] if len(sys.argv) > 2 else "Change"
    
    # For Claude Code hooks, data might be passed via stdin
    try:
        stdin_data = sys.stdin.read().strip()
        if stdin_data:
            try:
                hook_data = json.loads(stdin_data)
                file_path = hook_data.get('file_path', file_path)
                operation = hook_data.get('operation', operation)
            except json.JSONDecodeError:
                pass
    except:
        pass
    
    validator = PostChangeValidator()
    
    # Validate post-change
    validation_passed = validator.validate_post_change(file_path, operation)
    
    # Exit with appropriate code (0 for success, 1 for critical errors)
    # Note: Warnings don't cause failure in post-change validation
    sys.exit(0 if validation_passed else 1)

if __name__ == "__main__":
    main()