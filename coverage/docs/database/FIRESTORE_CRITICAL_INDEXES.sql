-- ===================================================================
-- FIRESTORE CRITICAL INDEXES FOR JOURNEYMAN JOBS APP
-- ===================================================================
-- This file contains the critical Firestore indexes needed for
-- optimal database performance. Execute these commands via:
-- firebase firestore:indexes:create --collection [collection] --field [field] --order [order] ...

-- ===================================================================
-- CRITICAL INDEX 1: SUGGESTED JOBS (PRIORITY 1 - BLOCKING CORE FEATURE)
-- ===================================================================
-- Collection: jobs
-- Purpose: Optimize suggested jobs query that filters by user locals
-- Error: FAILED_PRECONDITION: The query requires an index
-- Query: jobs where local in [84,111,222] and deleted==false order by -timestamp, -__name__

-- Command to create:
firebase firestore:indexes:create \
  --collection jobs \
  --field deleted --order ascending \
  --field local --order ascending \
  --field timestamp --order descending \
  --field __name__ --order descending

-- Index structure:
-- Collection: jobs
-- Fields:
--   - deleted (Ascending)
--   - local (Ascending)
--   - timestamp (Descending)
--   - __name__ (Descending)

-- ===================================================================
-- CRITICAL INDEX 2: JOBS BY LOCAL AND TIMESTAMP
-- ===================================================================
-- Collection: jobs
-- Purpose: Filter jobs by specific local union with timestamp ordering

-- Command to create:
firebase firestore:indexes:create \
  --collection jobs \
  --field local --order ascending \
  --field timestamp --order descending \
  --field __name__ --order descending

-- ===================================================================
-- CRITICAL INDEX 3: JOBS BY CLASSIFICATION AND TIMESTAMP
-- ===================================================================
-- Collection: jobs
-- Purpose: Filter jobs by electrical classification type

-- Command to create:
firebase firestore:indexes:create \
  --collection jobs \
  --field classification --order ascending \
  --field timestamp --order descending \
  --field __name__ --order descending

-- ===================================================================
-- CRITICAL INDEX 4: JOBS BY CONSTRUCTION TYPE AND TIMESTAMP
-- ===================================================================
-- Collection: jobs
-- Purpose: Filter jobs by construction type (commercial, industrial, etc.)

-- Command to create:
firebase firestore:indexes:create \
  --collection jobs \
  --field typeOfWork --order ascending \
  --field timestamp --order descending \
  --field __name__ --order descending

-- ===================================================================
-- PERFORMANCE INDEXES FOR OTHER FEATURES
-- ===================================================================

-- Locals Directory Performance
-- Collection: locals
-- Purpose: State filtering for 797+ IBEW locals
firebase firestore:indexes:create \
  --collection locals \
  --field state --order ascending \
  --field local_union --order ascending \
  --field __name__ --order ascending

-- Crew Messages Feed (Descending)
-- Collection Group: messages
-- Purpose: Real-time crew feed pagination (newest first)
firebase firestore:indexes:create \
  --collection-group messages \
  --field sentAt --order descending \
  --field __name__ --order descending

-- Crew Messages Chat (Ascending)
-- Collection Group: chat
-- Purpose: Real-time crew chat pagination (oldest first)
firebase firestore:indexes:create \
  --collection-group chat \
  --field sentAt --order ascending \
  --field __name__ --order ascending

-- ===================================================================
-- DEPLOYMENT COMMANDS
-- ===================================================================

-- Execute all critical indexes in order:
echo "Creating critical indexes for Journeyman Jobs..."

echo "1. Creating suggested jobs index (PRIORITY 1)..."
firebase firestore:indexes:create --collection jobs --field deleted --order ascending --field local --order ascending --field timestamp --order descending --field __name__ --order descending

echo "2. Creating jobs by local index..."
firebase firestore:indexes:create --collection jobs --field local --order ascending --field timestamp --order descending --field __name__ --order descending

echo "3. Creating jobs by classification index..."
firebase firestore:indexes:create --collection jobs --field classification --order ascending --field timestamp --order descending --field __name__ --order descending

echo "4. Creating jobs by construction type index..."
firebase firestore:indexes:create --collection jobs --field typeOfWork --order ascending --field timestamp --order descending --field __name__ --order descending

echo "5. Creating locals state filtering index..."
firebase firestore:indexes:create --collection locals --field state --order ascending --field local_union --order ascending --field __name__ --order ascending

echo "6. Creating crew messages feed index..."
firebase firestore:indexes:create --collection-group messages --field sentAt --order descending --field __name__ --order descending

echo "7. Creating crew messages chat index..."
firebase firestore:indexes:create --collection-group chat --field sentAt --order ascending --field __name__ --order ascending

echo "All indexes submitted. Wait 5-15 minutes for Firebase to build them."
echo "Monitor status in Firebase Console > Firestore > Indexes"

-- ===================================================================
-- VERIFICATION COMMANDS
-- ===================================================================

-- Check index creation status:
firebase firestore:indexes:list

-- Test queries after indexes are built:
# Use the Flutter app debug logs to verify queries execute without FAILED_PRECONDITION errors

-- ===================================================================
-- MONITORING PERFORMANCE
-- ===================================================================

-- Monitor these metrics in Firebase Console:
-- 1. Firestore > Usage tab > Read Operations
-- 2. Firestore > Usage tab > Query Time
-- 3. Firestore > Indexes tab (verify indexes are "Active")
-- 4. Check for any "Index Usage" warnings

-- Target performance metrics:
-- - Suggested jobs query: <500ms
-- - Jobs list loading: <300ms per page
-- - Locals filtering: <200ms
-- - Crew messages: <100ms real-time updates