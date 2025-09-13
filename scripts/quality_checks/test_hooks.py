#!/usr/bin/env python3
"""
Test script for Claude Code quality enforcement hooks
Validates all hook functionality with representative scenarios
"""

import subprocess
import sys
import tempfile
from pathlib import Path

def run_test(description: str, command: list, expected_exit_code: int = 0) -> bool:
    """Run a test command and validate results"""
    print(f"\n🧪 Testing: {description}")
    print(f"Command: {' '.join(command)}")
    
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=10)
        
        print(f"Exit code: {result.returncode} (expected: {expected_exit_code})")
        if result.stdout:
            print("STDOUT:")
            print(result.stdout)
        if result.stderr:
            print("STDERR:")
            print(result.stderr)
        
        success = result.returncode == expected_exit_code
        print(f"Result: {'✅ PASS' if success else '❌ FAIL'}")
        return success
        
    except subprocess.TimeoutExpired:
        print("❌ TIMEOUT")
        return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def main():
    """Run comprehensive hook tests"""
    project_root = Path(__file__).parent.parent.parent
    scripts_dir = project_root / "scripts/quality_checks"
    
    # Change to project directory
    import os
    os.chdir(project_root)
    
    tests_passed = 0
    total_tests = 0
    
    print("🔬 Claude Code Quality Hooks Test Suite")
    print("=" * 50)
    
    # Test 1: Pre-Edit Validation - Provider Usage (should fail)
    total_tests += 1
    if run_test(
        "Pre-Edit: Provider usage detection",
        ["python3", str(scripts_dir / "pre_edit_validation.py"), 
         "lib/test.dart", 
         "old content", 
         "import 'package:provider/provider.dart';\nclass Test extends StatelessWidget {}"],
        expected_exit_code=1
    ):
        tests_passed += 1
    
    # Test 2: Pre-Edit Validation - Valid Riverpod (should pass)
    total_tests += 1
    if run_test(
        "Pre-Edit: Valid Riverpod usage",
        ["python3", str(scripts_dir / "pre_edit_validation.py"),
         "lib/test.dart",
         "old content",
         "import 'package:flutter_riverpod/flutter_riverpod.dart';\nclass Test extends ConsumerWidget {}"],
        expected_exit_code=0
    ):
        tests_passed += 1
    
    # Test 3: Pre-Write Validation - Screen without electrical background
    total_tests += 1
    if run_test(
        "Pre-Write: Screen validation",
        ["python3", str(scripts_dir / "pre_write_validation.py"),
         "lib/screens/home/home_screen.dart",
         "import 'package:flutter/material.dart';\nclass HomeScreen extends StatelessWidget {}"],
        expected_exit_code=1
    ):
        tests_passed += 1
    
    # Test 4: Pre-Write Validation - Valid screen with electrical background
    total_tests += 1
    if run_test(
        "Pre-Write: Valid screen with electrical background",
        ["python3", str(scripts_dir / "pre_write_validation.py"),
         "lib/screens/test_screen.dart",
         "import 'package:flutter/material.dart';\nimport '../electrical_components/circuit_pattern_painter.dart';\nclass TestScreen extends ConsumerWidget {\n Widget build(context, ref) => Scaffold(\n body: Stack(children: [CircuitPatternBackground(), Text('Test')]));}"],
        expected_exit_code=0
    ):
        tests_passed += 1
    
    # Test 5: Post-Change Validation - Check existing file
    total_tests += 1
    if run_test(
        "Post-Change: Validate existing file",
        ["python3", str(scripts_dir / "post_change_validation.py"),
         "lib/main.dart",
         "Edit"],
        expected_exit_code=0
    ):
        tests_passed += 1
    
    # Test 6: Prompt Enhancement - Job card creation
    total_tests += 1
    if run_test(
        "Prompt Enhancement: Job card guidance",
        ["python3", str(scripts_dir / "prompt_enhancement.py"),
         "Create a new job card component"],
        expected_exit_code=0
    ):
        tests_passed += 1
    
    # Test 7: Prompt Enhancement - Screen creation
    total_tests += 1
    if run_test(
        "Prompt Enhancement: Screen guidance",
        ["python3", str(scripts_dir / "prompt_enhancement.py"),
         "Build a new screen for displaying union locals"],
        expected_exit_code=0
    ):
        tests_passed += 1
    
    # Test 8: Prompt Enhancement - State management
    total_tests += 1
    if run_test(
        "Prompt Enhancement: State management guidance",
        ["python3", str(scripts_dir / "prompt_enhancement.py"),
         "Add provider for managing job state"],
        expected_exit_code=0
    ):
        tests_passed += 1
    
    # Summary
    print("\n" + "=" * 50)
    print(f"📊 Test Results: {tests_passed}/{total_tests} tests passed")
    
    if tests_passed == total_tests:
        print("🎉 All tests passed! Hook system is working correctly.")
        return 0
    else:
        print(f"⚠️  {total_tests - tests_passed} tests failed. Review hook implementation.")
        return 1

if __name__ == "__main__":
    sys.exit(main())