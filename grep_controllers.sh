#!/bin/bash
# Find StatefulWidget files with controllers that need disposal
echo "=== Finding StatefulWidget files with controllers ==="
grep -r "Controller" lib/screens/ lib/features/ --include="*.dart" | grep -v "test" | head -20

echo "\n=== Finding StatefulWidget classes ==="
grep -r "class.*StatefulWidget" lib/screens/ lib/features/ --include="*.dart" | head -20

echo "\n=== Finding dispose methods ==="
grep -r "dispose()" lib/screens/ lib/features/ --include="*.dart" | head -10