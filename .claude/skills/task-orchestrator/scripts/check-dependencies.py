#!/usr/bin/env python3
"""
Hierarchical Task Orchestration - Dependency Checker

Analyzes task dependencies, detects circular dependencies, validates
dependency consistency, and provides visualization of task relationships.
"""

import argparse
import json
import sys
import yaml
from collections import defaultdict, deque
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional, Any
import networkx as nx


class DependencyAnalyzer:
    """Analyzes and validates task dependencies."""

    def __init__(self, strict_mode: bool = False, verbose: bool = False):
        self.strict_mode = strict_mode
        self.verbose = verbose
        self.tasks: Dict[str, Dict] = {}
        self.dependency_graph = nx.DiGraph()
        self.errors: List[str] = []
        self.warnings: List[str] = []

    def log(self, message: str, level: str = "info") -> None:
        """Log messages based on verbosity level."""
        if level == "error" or self.verbose:
            prefix = {
                "error": "❌ ERROR",
                "warning": "⚠️  WARNING",
                "info": "ℹ️  INFO",
                "debug": "🐛 DEBUG"
            }.get(level, "ℹ️  INFO")
            print(f"{prefix}: {message}")

    def load_task_file(self, file_path: Path) -> bool:
        """Load a single task file and extract dependency information."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                task_data = yaml.safe_load(f)

            task_id = task_data.get('task_id')
            if not task_id:
                self.log(f"No task_id found in {file_path}", "error")
                return False

            self.tasks[task_id] = {
                'data': task_data,
                'file_path': file_path,
                'dependencies': set(),
                'dependents': set()
            }

            # Extract hard dependencies
            hard_deps = task_data.get('dependencies', {}).get('hard_dependencies', [])
            for dep in hard_deps:
                if isinstance(dep, dict) and 'task_id' in dep:
                    self.tasks[task_id]['dependencies'].add(dep['task_id'])

            # Extract soft dependencies
            soft_deps = task_data.get('dependencies', {}).get('soft_dependencies', [])
            for dep in soft_deps:
                if isinstance(dep, dict) and 'task_id' in dep:
                    self.tasks[task_id]['dependencies'].add(dep['task_id'])

            self.log(f"Loaded task {task_id} with {len(self.tasks[task_id]['dependencies'])} dependencies")
            return True

        except yaml.YAMLError as e:
            self.log(f"Invalid YAML in {file_path}: {e}", "error")
            return False
        except Exception as e:
            self.log(f"Error loading {file_path}: {e}", "error")
            return False

    def build_dependency_graph(self) -> None:
        """Build the dependency graph from loaded tasks."""
        self.dependency_graph.clear()

        # Add nodes
        for task_id in self.tasks:
            self.dependency_graph.add_node(task_id)

        # Add edges (dependencies)
        for task_id, task_info in self.tasks.items():
            for dep_id in task_info['dependencies']:
                self.dependency_graph.add_edge(task_id, dep_id)
                # Track reverse dependencies
                if dep_id in self.tasks:
                    self.tasks[dep_id]['dependents'].add(task_id)

    def detect_circular_dependencies(self) -> List[List[str]]:
        """Detect circular dependencies using DFS."""
        try:
            cycles = list(nx.simple_cycles(self.dependency_graph))
            return cycles
        except Exception as e:
            self.log(f"Error detecting circular dependencies: {e}", "error")
            return []

    def validate_dependencies(self) -> None:
        """Validate all dependencies for consistency and completeness."""
        for task_id, task_info in self.tasks.items():
            task_data = task_info['data']
            file_path = task_info['file_path']

            # Check if all dependencies exist
            for dep_id in task_info['dependencies']:
                if dep_id not in self.tasks:
                    self.errors.append(
                        f"Task '{task_id}' in {file_path.name} depends on non-existent task '{dep_id}'"
                    )
                    continue

                # Validate dependency type consistency
                if dep_id in self.tasks:
                    dep_task = self.tasks[dep_id]

                    # Check for logical dependency issues
                    task_priority = task_data.get('priority', 'medium')
                    dep_priority = dep_task['data'].get('priority', 'medium')

                    priority_order = {'low': 1, 'medium': 2, 'high': 3, 'critical': 4}
                    task_prio_val = priority_order.get(task_priority, 2)
                    dep_prio_val = priority_order.get(dep_priority, 2)

                    if task_prio_val > dep_prio_val:
                        self.warnings.append(
                            f"Task '{task_id}' (priority: {task_priority}) depends on "
                            f"lower priority task '{dep_id}' (priority: {dep_priority})"
                        )

    def analyze_critical_path(self) -> List[str]:
        """Analyze the critical path through the dependency graph."""
        try:
            # Find tasks with no dependencies (roots)
            roots = [n for n in self.dependency_graph.nodes()
                    if self.dependency_graph.in_degree(n) == 0]

            if not roots:
                return []

            # Calculate longest path from any root to any node
            longest_path = []
            for root in roots:
                try:
                    paths = nx.all_simple_paths(self.dependency_graph, root,
                                              max(len(list(self.dependency_graph.nodes())), 20))
                    for path in paths:
                        if len(path) > len(longest_path):
                            longest_path = path
                except (nx.NetworkXNoPath, nx.NodeNotFound):
                    continue

            return longest_path

        except Exception as e:
            self.log(f"Error analyzing critical path: {e}", "error")
            return []

    def calculate_task_levels(self) -> Dict[str, int]:
        """Calculate the level (depth) of each task in the dependency hierarchy."""
        levels = {}

        # Topological sort to determine levels
        try:
            topo_order = list(nx.topological_sort(self.dependency_graph))
        except nx.NetworkXError:
            # Graph has cycles, can't determine levels
            self.log("Cannot calculate task levels due to circular dependencies", "error")
            return levels

        for task_id in topo_order:
            max_dep_level = -1
            for dep_id in self.tasks[task_id]['dependencies']:
                if dep_id in levels:
                    max_dep_level = max(max_dep_level, levels[dep_id])

            levels[task_id] = max_dep_level + 1

        return levels

    def identify_bottleneck_tasks(self) -> List[Tuple[str, int]]:
        """Identify tasks that are bottlenecks (many dependents)."""
        bottleneck_scores = []

        for task_id, task_info in self.tasks.items():
            dependent_count = len(task_info['dependents'])
            if dependent_count > 0:
                bottleneck_scores.append((task_id, dependent_count))

        # Sort by number of dependents (descending)
        bottleneck_scores.sort(key=lambda x: x[1], reverse=True)
        return bottleneck_scores

    def generate_dependency_matrix(self) -> Dict[str, Dict[str, str]]:
        """Generate a dependency matrix showing task relationships."""
        matrix = {}
        task_ids = sorted(self.tasks.keys())

        for task_id in task_ids:
            matrix[task_id] = {}
            for other_id in task_ids:
                if task_id == other_id:
                    matrix[task_id][other_id] = "self"
                elif other_id in self.tasks[task_id]['dependencies']:
                    matrix[task_id][other_id] = "depends_on"
                elif task_id in self.tasks[other_id]['dependencies']:
                    matrix[task_id][other_id] = "dependency_of"
                else:
                    matrix[task_id][other_id] = "independent"

        return matrix

    def visualize_dependencies_text(self) -> str:
        """Generate a text-based visualization of dependencies."""
        output = []
        output.append("Dependency Graph Visualization")
        output.append("=" * 40)

        levels = self.calculate_task_levels()
        if not levels:
            output.append("Unable to determine levels due to circular dependencies")
            return "\n".join(output)

        # Group tasks by level
        level_groups = defaultdict(list)
        for task_id, level in levels.items():
            level_groups[level].append(task_id)

        # Display by level
        max_level = max(level_groups.keys()) if level_groups else 0
        for level in range(max_level + 1):
            output.append(f"\nLevel {level}:")
            for task_id in sorted(level_groups[level]):
                task_data = self.tasks[task_id]['data']
                task_name = task_data.get('task_name', 'Unnamed')
                deps = self.tasks[task_id]['dependencies']

                if deps:
                    dep_list = ", ".join(sorted(deps))
                    output.append(f"  └── {task_id}: {task_name}")
                    output.append(f"      (depends on: {dep_list})")
                else:
                    output.append(f"  └── {task_id}: {task_name} (no dependencies)")

        return "\n".join(output)

    def generate_statistics(self) -> Dict[str, Any]:
        """Generate comprehensive statistics about the dependency structure."""
        stats = {
            'total_tasks': len(self.tasks),
            'total_dependencies': sum(len(task['dependencies']) for task in self.tasks.values()),
            'tasks_with_dependencies': sum(1 for task in self.tasks.values() if task['dependencies']),
            'tasks_without_dependencies': sum(1 for task in self.tasks.values() if not task['dependencies']),
            'max_dependency_depth': 0,
            'average_dependencies_per_task': 0,
            'circular_dependencies': 0,
            'bottleneck_tasks': []
        }

        if stats['total_tasks'] > 0:
            stats['average_dependencies_per_task'] = stats['total_dependencies'] / stats['total_tasks']

        levels = self.calculate_task_levels()
        if levels:
            stats['max_dependency_depth'] = max(levels.values()) + 1

        cycles = self.detect_circular_dependencies()
        stats['circular_dependencies'] = len(cycles)

        # Get top 5 bottleneck tasks
        bottlenecks = self.identify_bottleneck_tasks()[:5]
        stats['bottleneck_tasks'] = [{'task_id': task_id, 'dependents': count}
                                     for task_id, count in bottlenecks]

        return stats

    def analyze_task_files(self, file_paths: List[Path]) -> Dict[str, Any]:
        """Main analysis method for a list of task files."""
        self.log(f"Analyzing {len(file_paths)} task file(s)")

        # Load all task files
        loaded_count = 0
        for file_path in file_paths:
            if self.load_task_file(file_path):
                loaded_count += 1

        if loaded_count == 0:
            self.log("No valid task files loaded", "error")
            return {'success': False, 'errors': self.errors}

        self.log(f"Successfully loaded {loaded_count} task(s)")

        # Build dependency graph
        self.build_dependency_graph()

        # Perform analysis
        self.validate_dependencies()
        cycles = self.detect_circular_dependencies()
        critical_path = self.analyze_critical_path()
        bottlenecks = self.identify_bottleneck_tasks()
        stats = self.generate_statistics()

        # Report circular dependencies
        if cycles:
            self.log(f"Found {len(cycles)} circular dependency cycle(s):", "error")
            for i, cycle in enumerate(cycles, 1):
                cycle_str = " → ".join(cycle)
                self.log(f"  Cycle {i}: {cycle_str}", "error")
                self.errors.append(f"Circular dependency {i}: {cycle_str}")

        # Report warnings and errors
        for warning in self.warnings:
            self.log(warning, "warning")

        for error in self.errors:
            self.log(error, "error")

        # Return analysis results
        return {
            'success': len(self.errors) == 0,
            'tasks_loaded': loaded_count,
            'statistics': stats,
            'circular_dependencies': cycles,
            'critical_path': critical_path,
            'bottleneck_tasks': bottlenecks,
            'errors': self.errors,
            'warnings': self.warnings,
            'dependency_graph_viz': self.visualize_dependencies_text()
        }


def main():
    """Main entry point for the dependency checker."""
    parser = argparse.ArgumentParser(
        description="Analyze task dependencies for hierarchical task orchestration",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s tasks/*.yaml                    # Analyze all YAML task files
  %(prog)s --strict task1.yaml task2.yaml # Strict mode validation
  %(prog)s --verbose --format json *.yaml  # Verbose JSON output
  %(prog)s --output report.txt tasks/     # Save report to file
        """
    )

    parser.add_argument(
        'files',
        nargs='*',
        help='Task files to analyze (YAML format)'
    )

    parser.add_argument(
        '--strict',
        action='store_true',
        help='Enable strict validation mode'
    )

    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose output'
    )

    parser.add_argument(
        '--format', '-f',
        choices=['text', 'json', 'yaml'],
        default='text',
        help='Output format (default: text)'
    )

    parser.add_argument(
        '--output', '-o',
        help='Output file (default: stdout)'
    )

    parser.add_argument(
        '--max-depth',
        type=int,
        default=20,
        help='Maximum dependency depth to analyze (default: 20)'
    )

    args = parser.parse_args()

    # Find task files if none specified
    if not args.files:
        current_dir = Path('.')
        yaml_files = list(current_dir.glob('*.yaml')) + list(current_dir.glob('*.yml'))

        if not yaml_files:
            print("No task files found. Please specify task files or ensure *.yaml/*.yml files exist.", file=sys.stderr)
            sys.exit(1)

        args.files = yaml_files

    # Convert to Path objects
    file_paths = [Path(f) for f in args.files]

    # Validate file existence
    missing_files = [f for f in file_paths if not f.exists()]
    if missing_files:
        print(f"Error: The following files do not exist: {missing_files}", file=sys.stderr)
        sys.exit(1)

    # Run analysis
    analyzer = DependencyAnalyzer(strict_mode=args.strict, verbose=args.verbose)
    results = analyzer.analyze_task_files(file_paths)

    # Prepare output
    if args.format == 'json':
        output = json.dumps(results, indent=2)
    elif args.format == 'yaml':
        output = yaml.dump(results, default_flow_style=False)
    else:
        # Text format
        output_lines = []
        output_lines.append("Task Dependency Analysis Report")
        output_lines.append("=" * 40)

        if results['success']:
            output_lines.append("✅ Analysis completed successfully")
        else:
            output_lines.append("❌ Analysis found issues")

        output_lines.append(f"\n📊 Statistics:")
        stats = results['statistics']
        output_lines.append(f"  Total tasks: {stats['total_tasks']}")
        output_lines.append(f"  Total dependencies: {stats['total_dependencies']}")
        output_lines.append(f"  Tasks with dependencies: {stats['tasks_with_dependencies']}")
        output_lines.append(f"  Tasks without dependencies: {stats['tasks_without_dependencies']}")
        output_lines.append(f"  Max dependency depth: {stats['max_dependency_depth']}")
        output_lines.append(f"  Average dependencies per task: {stats['average_dependencies_per_task']:.2f}")

        if results['circular_dependencies']:
            output_lines.append(f"\n🔄 Circular Dependencies ({len(results['circular_dependencies'])}):")
            for i, cycle in enumerate(results['circular_dependencies'], 1):
                cycle_str = " → ".join(cycle)
                output_lines.append(f"  {i}. {cycle_str}")

        if results['critical_path']:
            output_lines.append(f"\n🎯 Critical Path ({len(results['critical_path'])} tasks):")
            critical_str = " → ".join(results['critical_path'])
            output_lines.append(f"  {critical_str}")

        if results['bottleneck_tasks']:
            output_lines.append(f"\n🍾 Bottleneck Tasks:")
            for task_id, count in results['bottleneck_tasks'][:5]:
                task_name = analyzer.tasks[task_id]['data'].get('task_name', 'Unnamed')
                output_lines.append(f"  {task_id}: {task_name} ({count} dependents)")

        if results['warnings']:
            output_lines.append(f"\n⚠️  Warnings ({len(results['warnings'])}):")
            for warning in results['warnings']:
                output_lines.append(f"  • {warning}")

        if results['errors']:
            output_lines.append(f"\n❌ Errors ({len(results['errors'])}):")
            for error in results['errors']:
                output_lines.append(f"  • {error}")

        if args.verbose:
            output_lines.append(f"\n{results['dependency_graph_viz']}")

        output = "\n".join(output_lines)

    # Write output
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(output)
        print(f"Report saved to: {args.output}")
    else:
        print(output)

    # Exit with appropriate code
    sys.exit(0 if results['success'] else 1)


if __name__ == "__main__":
    main()