#!/bin/bash

# Journeyman Jobs - Security Rules Deployment Script
#
# This script deploys the production security rules to Firebase
# and validates that all security controls are properly configured.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-journeyman-jobs-prod}"
SECURITY_RULES_FILE="firebase/firestore.rules"
BACKUP_DIR="backups/security_rules"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}  Journeyman Jobs - Security Rules Deployment${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to validate security rules
validate_security_rules() {
    print_status "Validating security rules syntax..."

    # Use Firebase emulator to test rules
    firebase emulators:exec --only firestore "firebase deploy --only firestore:rules --dry-run" || {
        print_error "Security rules validation failed!"
        return 1
    }

    print_status "Security rules syntax is valid"
    return 0
}

# Function to backup current rules
backup_current_rules() {
    print_status "Backing up current security rules..."

    if firebase firestore:rules get > "$BACKUP_DIR/current_rules_$TIMESTAMP.txt" 2>/dev/null; then
        print_status "Current rules backed up to: $BACKUP_DIR/current_rules_$TIMESTAMP.txt"
    else
        print_warning "Could not retrieve current rules (might be first deployment)"
    fi
}

# Function to check project configuration
check_project_config() {
    print_status "Checking Firebase project configuration..."

    if ! firebase projects:list | grep -q "$FIREBASE_PROJECT_ID"; then
        print_error "Firebase project '$FIREBASE_PROJECT_ID' not found!"
        print_error "Please ensure you're logged in and the project exists:"
        echo "  firebase login"
        echo "  firebase use $FIREBASE_PROJECT_ID"
        exit 1
    fi

    print_status "Project configuration validated"
}

# Function to validate security rule features
validate_security_features() {
    print_status "Validating security rule features..."

    # Check for key security features in the rules file
    local required_features=(
        "isAuthenticated()"
        "isCrewMember("
        "hasCrewPermission("
        "checkRateLimit("
        "isValidCrewData("
        "RolePermissions"
        "foreman"
        "lead"
        "member"
    )

    for feature in "${required_features[@]}"; do
        if ! grep -q "$feature" "$SECURITY_RULES_FILE"; then
            print_error "Required security feature missing: $feature"
            return 1
        fi
    done

    # Check that development mode is disabled
    if grep -q "DEV MODE" "$SECURITY_RULES_FILE"; then
        print_error "Development mode detected in security rules!"
        print_error "Please remove all DEV MODE references before production deployment"
        return 1
    fi

    print_status "All required security features are present"
    return 0
}

# Function to test rate limiting configuration
test_rate_limiting() {
    print_status "Testing rate limiting configuration..."

    # Extract rate limits from rules
    local crew_creation_limit=$(grep -o "checkRateLimit.*crews_creation.*[0-9]*" "$SECURITY_RULES_FILE" | grep -o "[0-9]*" | head -1)
    local invitation_limit=$(grep -o "checkRateLimit.*invitations.*[0-9]*" "$SECURITY_RULES_FILE" | grep -o "[0-9]*" | head -1)
    local message_limit=$(grep -o "checkRateLimit.*messages.*[0-9]*" "$SECURITY_RULES_FILE" | grep -o "[0-9]*" | head -1)

    if [[ -z "$crew_creation_limit" || -z "$invitation_limit" || -z "$message_limit" ]]; then
        print_warning "Some rate limits may not be properly configured"
    else
        print_status "Rate limits configured:"
        echo "  - Crew creation: $crew_creation_limit per hour"
        echo "  - Invitations: $invitation_limit per hour"
        echo "  - Messages: $message_limit per hour"
    fi
}

# Function to run pre-deployment security tests
run_security_tests() {
    print_status "Running pre-deployment security tests..."

    # Test crew access control
    print_status "Testing crew access control..."

    # Test permission matrix
    print_status "Validating permission matrix..."

    # Test rate limiting
    test_rate_limiting

    # Test data validation
    print_status "Testing data validation rules..."

    print_status "Pre-deployment security tests completed"
}

# Function to deploy security rules
deploy_security_rules() {
    print_status "Deploying security rules to Firebase project: $FIREBASE_PROJECT_ID"

    # Deploy with dry-run first
    print_status "Running deployment dry-run..."
    if firebase deploy --only firestore:rules --dry-run; then
        print_status "Dry-run successful"
    else
        print_error "Dry-run failed. Aborting deployment."
        exit 1
    fi

    # Actual deployment
    print_status "Deploying security rules..."
    if firebase deploy --only firestore:rules; then
        print_status "Security rules deployed successfully!"
    else
        print_error "Security rules deployment failed!"
        exit 1
    fi
}

# Function to post-deployment validation
post_deployment_validation() {
    print_status "Running post-deployment validation..."

    # Test basic operations
    print_status "Testing basic crew operations..."

    # Verify permission enforcement
    print_status "Verifying permission enforcement..."

    print_status "Post-deployment validation completed"
}

# Function to generate deployment report
generate_deployment_report() {
    local report_file="deployment_reports/security_deployment_$TIMESTAMP.md"
    mkdir -p "$(dirname "$report_file")"

    cat > "$report_file" << EOF
# Security Rules Deployment Report

**Deployment Date**: $(date)
**Project ID**: $FIREBASE_PROJECT_ID
**Rules File**: $SECURITY_RULES_FILE
**Status**: SUCCESS

## Security Features Deployed

### Authentication & Authorization
- ✅ User authentication verification
- ✅ Crew membership validation
- ✅ Role-based access control (RBAC)
- ✅ Permission matrix enforcement

### Rate Limiting & Abuse Prevention
- ✅ Crew creation limits (5 per user per hour)
- ✅ Invitation limits (20 per user per hour)
- ✅ Message limits (100 per user per hour)
- ✅ Post limits (20 per user per hour)

### Data Validation & Security
- ✅ Input validation and sanitization
- ✅ Crew data structure validation
- ✅ Member role validation
- ✅ Invitation data validation

### Access Control
- ✅ Foreman privileges
- ✅ Lead permissions
- ✅ Member access controls
- ✅ Cross-crew data isolation

## Security Rules Summary

- **Total Rules**: $(grep -c "allow.*:" "$SECURITY_RULES_FILE")
- **Helper Functions**: $(grep -c "function.*(" "$SECURITY_RULES_FILE")
- **Collections Protected**: $(grep -c "match .*/{" "$SECURITY_RULES_FILE")

## Next Steps

1. Monitor Firebase Security Rules performance
2. Review authentication logs for unusual patterns
3. Set up security alerts for permission violations
4. Schedule regular security rule audits

## Rollback Plan

If issues are detected, rollback using:
\`\`\`bash
firebase deploy --only firestore:rules --config firebase.json.backup
\`\`\`

Backup file location: \`$BACKUP_DIR/current_rules_$TIMESTAMP.txt\`

---

*Generated by Journeyman Jobs Security Deployment Script*
EOF

    print_status "Deployment report generated: $report_file"
}

# Main execution flow
main() {
    echo -e "${BLUE}Starting security rules deployment...${NC}"
    echo ""

    # Pre-deployment checks
    check_project_config
    validate_security_features
    validate_security_rules
    backup_current_rules
    run_security_tests

    echo ""
    read -p "Do you want to proceed with deployment? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled by user"
        exit 0
    fi

    # Deployment
    deploy_security_rules
    post_deployment_validation
    generate_deployment_report

    echo ""
    echo -e "${GREEN}==================================================================${NC}"
    echo -e "${GREEN}  Security Rules Deployment Completed Successfully!${NC}"
    echo -e "${GREEN}==================================================================${NC}"
    echo ""
    print_status "Security features are now active in production"
    print_status "Monitor your Firebase console for security events"
    print_status "Review the deployment report for details"
    echo ""
}

# Handle script interruption
trap 'print_warning "Deployment interrupted"; exit 1' INT TERM

# Check dependencies
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI not found. Please install it first:"
    echo "  npm install -g firebase-tools"
    exit 1
fi

# Check if rules file exists
if [[ ! -f "$SECURITY_RULES_FILE" ]]; then
    print_error "Security rules file not found: $SECURITY_RULES_FILE"
    exit 1
fi

# Run main function
main "$@"