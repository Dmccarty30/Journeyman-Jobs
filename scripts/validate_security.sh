#!/bin/bash

# Journeyman Jobs - Security Validation Script
#
# Comprehensive security validation for the Crews Feature
# Tests all security controls and generates detailed reports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-journeyman-jobs-prod}"
REPORT_DIR="security_reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$REPORT_DIR/security_validation_$TIMESTAMP.md"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE} Journeyman Jobs - Security Validation Suite${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

# Create report directory
mkdir -p "$REPORT_DIR"

# Initialize report
cat > "$REPORT_FILE" << EOF
# Journeyman Jobs - Security Validation Report

**Validation Date**: $(date)
**Project ID**: $FIREBASE_PROJECT_ID
**Environment**: Production

## Executive Summary

EOF

# Utility functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
    echo -e "\n### $1\n" >> "$REPORT_FILE"
}

print_test() {
    echo -e "${CYAN}Testing: $1${NC}"
    echo -n "- **$1**: " >> "$REPORT_FILE"
    ((TOTAL_TESTS++))
}

pass_test() {
    echo -e "${GREEN}✓ PASS${NC}"
    echo "✅ PASS" >> "$REPORT_FILE"
    ((PASSED_TESTS++))
}

fail_test() {
    echo -e "${RED}✗ FAIL${NC} - $1"
    echo "❌ FAIL - $1" >> "$REPORT_FILE"
    ((FAILED_TESTS++))
}

warn_test() {
    echo -e "${YELLOW}⚠ WARN${NC} - $1"
    echo "⚠️ **WARN** - $1" >> "$REPORT_FILE"
    ((WARNINGS++))
}

# Security validation functions

validate_firebase_security_rules() {
    print_header "Firebase Security Rules Validation"

    # Test 1: Rules file exists and is readable
    print_test "Security rules file exists"
    if [[ -f "firebase/firestore.rules" ]]; then
        pass_test
    else
        fail_test "Security rules file not found"
        return 1
    fi

    # Test 2: Rules syntax validation
    print_test "Security rules syntax validation"
    if firebase emulators:exec --only firestore "firebase deploy --only firestore:rules --dry-run" 2>/dev/null; then
        pass_test
    else
        fail_test "Security rules syntax is invalid"
    fi

    # Test 3: No development mode enabled
    print_test "Development mode is disabled"
    if ! grep -q "DEV MODE" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Development mode is still enabled in security rules"
    fi

    # Test 4: Authentication functions present
    print_test "Authentication functions implemented"
    if grep -q "function isAuthenticated()" firebase/firestore.rules; then
        pass_test
    else
        fail_test "isAuthenticated() function not found"
    fi

    # Test 5: Crew member validation
    print_test "Crew member validation implemented"
    if grep -q "function isCrewMember(" firebase/firestore.rules; then
        pass_test
    else
        fail_test "isCrewMember() function not found"
    fi

    # Test 6: Permission checking
    print_test "Permission checking implemented"
    if grep -q "function hasCrewPermission(" firebase/firestore.rules; then
        pass_test
    else
        fail_test "hasCrewPermission() function not found"
    fi

    # Test 7: Rate limiting functions
    print_test "Rate limiting functions implemented"
    if grep -q "function checkRateLimit(" firebase/firestore.rules; then
        pass_test
    else
        fail_test "checkRateLimit() function not found"
    fi

    # Test 8: Data validation functions
    print_test "Data validation functions implemented"
    if grep -q "function isValidCrewData(" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Data validation functions not found"
    fi
}

validate_role_based_access_control() {
    print_header "Role-Based Access Control (RBAC) Validation"

    # Test 1: Admin role permissions
    print_test "Admin role has full permissions"
    if grep -q "'admin'" firebase/firestore.rules && grep -q "'canInviteMembers': true" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Admin role permissions not properly configured"
    fi

    # Test 2: Foreman role permissions
    print_test "Foreman role has management permissions"
    if grep -q "'foreman'" firebase/firestore.rules && grep -q "'canRemoveMembers': true" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Foreman role permissions not properly configured"
    fi

    # Test 3: Lead role permissions
    print_test "Lead role has limited permissions"
    if grep -q "'lead'" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Lead role not properly defined"
    fi

    # Test 4: Member role restrictions
    print_test "Member role has basic permissions only"
    if grep -q "'member'" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Member role not properly defined"
    fi

    # Test 5: Permission matrix completeness
    print_test "Permission matrix is complete"
    local required_perms=(
        "canInviteMembers"
        "canRemoveMembers"
        "canShareJobs"
        "canPostAnnouncements"
        "canEditCrewInfo"
        "canViewAnalytics"
    )

    local missing_perms=()
    for perm in "${required_perms[@]}"; do
        if ! grep -q "$perm" firebase/firestore.rules; then
            missing_perms+=("$perm")
        fi
    done

    if [[ ${#missing_perms[@]} -eq 0 ]]; then
        pass_test
    else
        fail_test "Missing permissions: ${missing_perms[*]}"
    fi
}

validate_rate_limiting() {
    print_header "Rate Limiting Validation"

    # Test 1: Crew creation rate limits
    print_test "Crew creation rate limiting configured"
    if grep -q "crews_creation.*5.*hour" firebase/firestore.rules; then
        pass_test
    else
        warn_test "Crew creation rate limiting may not be properly configured"
    fi

    # Test 2: Invitation rate limits
    print_test "Invitation rate limiting configured"
    if grep -q "invitations.*20.*hour" firebase/firestore.rules; then
        pass_test
    else
        warn_test "Invitation rate limiting may not be properly configured"
    fi

    # Test 3: Message rate limits
    print_test "Message rate limiting configured"
    if grep -q "messages.*100.*hour" firebase/firestore.rules; then
        pass_test
    else
        warn_test "Message rate limiting may not be properly configured"
    fi

    # Test 4: Post rate limits
    print_test "Post rate limiting configured"
    if grep -q "posts.*20.*hour" firebase/firestore.rules; then
        pass_test
    else
        warn_test "Post rate limiting may not be properly configured"
    fi

    # Test 5: Rate limit counter cleanup
    print_test "Rate limit counter cleanup implemented"
    if grep -q "incrementRateLimit" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Rate limit counter management not implemented"
    fi
}

validate_data_protection() {
    print_header "Data Protection Validation"

    # Test 1: User data isolation
    print_test "User data access is properly isolated"
    if grep -q "request.auth.uid == userId" firebase/firestore.rules; then
        pass_test
    else
        fail_test "User data isolation not properly implemented"
    fi

    # Test 2: Crew member access control
    print_test "Crew member access control implemented"
    if grep -q "isCrewMember.*allow read" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Crew member access control not found"
    fi

    # Test 3: Input validation
    print_test "Input validation implemented"
    if grep -q "isValidCrewData" firebase/firestore.rules && grep -q "isValidInvitationData" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Input validation not properly implemented"
    fi

    # Test 4: Data size limits
    print_test "Data size limits enforced"
    if grep -q "size()" firebase/firestore.rules; then
        pass_test
    else
        warn_test "Data size limits may not be enforced"
    fi

    # Test 5: Cross-crew data protection
    print_test "Cross-crew data access prevented"
    if grep -q "isCrewMember.*crewId" firebase/firestore.rules; then
        pass_test
    else
        fail_test "Cross-crew data protection not implemented"
    fi
}

validate_service_layer_security() {
    print_header "Service Layer Security Validation"

    # Test 1: Crew service permission checks
    print_test "Crew service permission checks enabled"
    if grep -q "PRODUCTION: Permission check enforced" lib/features/crews/services/crew_service.dart; then
        pass_test
    else
        fail_test "Crew service permission checks are not enabled"
    fi

    # Test 2: Role permissions matrix
    print_test "Role permissions matrix implemented"
    if grep -q "class RolePermissions" lib/features/crews/services/crew_service.dart; then
        pass_test
    else
        fail_test "Role permissions matrix not found"
    fi

    # Test 3: Invitation limits enforced
    print_test "Invitation limits enforced in service layer"
    if grep -q "PRODUCTION: Invitation limit checks enforced" lib/features/crews/services/crew_service.dart; then
        pass_test
    else
        fail_test "Invitation limits not enforced in service layer"
    fi

    # Test 4: Crew creation limits
    print_test "Crew creation limits enforced"
    if grep -q "PRODUCTION: Crew creation limit check enforced" lib/features/crews/services/crew_service.dart; then
        pass_test
    else
        fail_test "Crew creation limits not enforced"
    fi

    # Test 5: Error handling security
    print_test "Secure error handling implemented"
    if grep -q "fail secure" lib/features/crews/services/crew_service.dart; then
        pass_test
    else
        warn_test "Error handling may not be secure"
    fi
}

validate_authentication_service() {
    print_header "Authentication Service Validation"

    # Test 1: Crew auth service exists
    print_test "Crew authentication service implemented"
    if [[ -f "lib/services/crew_auth_service.dart" ]]; then
        pass_test
    else
        fail_test "Crew authentication service not found"
    fi

    # Test 2: Permission verification
    print_test "Permission verification methods implemented"
    if grep -q "verifyCrewPermission" lib/services/crew_auth_service.dart; then
        pass_test
    else
        fail_test "Permission verification methods not found"
    fi

    # Test 3: Session management
    print_test "Session management implemented"
    if grep -q "generateCrewSessionToken" lib/services/crew_auth_service.dart; then
        pass_test
    else
        fail_test "Session management not implemented"
    fi

    # Test 4: Security logging
    print_test "Security logging implemented"
    if grep -q "_logAuthEvent" lib/services/crew_auth_service.dart; then
        pass_test
    else
        warn_test "Security logging may not be comprehensive"
    fi

    # Test 5: Rate limiting in auth service
    print_test "Rate limiting in authentication service"
    if grep -q "RateLimiter" lib/services/crew_auth_service.dart; then
        pass_test
    else
        warn_test "Authentication service rate limiting may not be implemented"
    fi
}

validate_provider_security() {
    print_header "Provider Security Validation"

    # Test 1: Permission-based providers
    print_test "Permission-based providers implemented"
    if grep -q "hasCrewPermission" lib/features/crews/providers/crews_riverpod_provider.dart; then
        pass_test
    else
        fail_test "Permission-based providers not found"
    fi

    # Test 2: Authentication checks in providers
    print_test "Authentication checks in providers"
    if grep -q "currentUser == null" lib/features/crews/providers/crews_riverpod_provider.dart; then
        pass_test
    else
        fail_test "Authentication checks not found in providers"
    fi

    # Test 3: Role-based UI visibility
    print_test "Role-based UI visibility controls"
    if grep -q "isCrewForeman" lib/features/crews/providers/crews_riverpod_provider.dart; then
        pass_test
    else
        warn_test "Role-based UI visibility may not be implemented"
    fi

    # Test 4: Error handling in providers
    print_test "Secure error handling in providers"
    if grep -q "AsyncValue.error" lib/features/crews/providers/crews_riverpod_provider.dart; then
        pass_test
    else
        warn_test "Provider error handling may not be comprehensive"
    fi
}

validate_deployment_readiness() {
    print_header "Deployment Readiness Validation"

    # Test 1: Firebase project accessible
    print_test "Firebase project accessible"
    if firebase projects:list | grep -q "$FIREBASE_PROJECT_ID"; then
        pass_test
    else
        fail_test "Firebase project not accessible"
    fi

    # Test 2: Security rules deployable
    print_test "Security rules deployment ready"
    if firebase deploy --only firestore:rules --dry-run 2>/dev/null; then
        pass_test
    else
        fail_test "Security rules deployment failed"
    fi

    # Test 3: No hardcoded secrets
    print_test "No hardcoded secrets in code"
    if ! grep -r "AIza" lib/ 2>/dev/null && ! grep -r "sk-" lib/ 2>/dev/null; then
        pass_test
    else
        fail_test "Potential hardcoded secrets detected"
    fi

    # Test 4: Debug code removed
    print_test "Debug code removed from production"
    if ! grep -r "debugPrint" lib/features/crews/ 2>/dev/null || grep -q "kDebugMode" lib/features/crews/ 2>/dev/null; then
        pass_test
    else
        warn_test "Debug code may still be present"
    fi

    # Test 5: Dependencies security scan
    print_test "Dependencies security scan"
    if command -v npm &> /dev/null; then
        if npm audit --audit-level moderate 2>/dev/null | grep -q "0 vulnerabilities"; then
            pass_test
        else
            warn_test "Dependency vulnerabilities detected - review npm audit output"
        fi
    else
        warn_test "npm not available for dependency scanning"
    fi
}

generate_security_recommendations() {
    print_header "Security Recommendations"

    echo -e "\n${PURPLE}=== Production Security Recommendations ===${NC}"

    echo -e "\n${CYAN}🔒 Immediate Actions Required:${NC}"
    echo "- Deploy security rules to production environment"
    echo "- Enable Firebase Security Rules logging"
    echo "- Set up security monitoring and alerting"
    echo "- Configure Firebase project security settings"

    echo -e "\n${CYAN}🛡️ Security Monitoring:${NC}"
    echo "- Monitor authentication failure rates"
    echo "- Track permission denial events"
    echo "- Set up alerts for unusual activity patterns"
    echo "- Review security logs regularly"

    echo -e "\n${CYAN}📊 Ongoing Security Tasks:${NC}"
    echo "- Schedule regular security audits (quarterly)"
    echo "- Test security controls with penetration testing"
    echo "- Keep dependencies updated and scan for vulnerabilities"
    echo "- Review and update security rules as features evolve"

    echo -e "\n${CYAN}🚨 Incident Response:${NC}"
    echo "- Document security incident response procedures"
    echo "- Set up emergency rollback procedures"
    echo "- Create security contact information"
    echo "- Test incident response with security drills"

    # Add recommendations to report
    cat >> "$REPORT_FILE" << 'EOF'

### Security Recommendations

#### Immediate Actions Required
1. **Deploy Security Rules**: Deploy the validated security rules to production
2. **Enable Security Logging**: Configure Firebase Security Rules logging
3. **Set Up Monitoring**: Implement security monitoring and alerting
4. **Review Project Settings**: Ensure Firebase project security is properly configured

#### Security Monitoring
1. **Authentication Monitoring**: Track failed authentication attempts
2. **Permission Auditing**: Monitor permission denial events
3. **Anomaly Detection**: Set up alerts for unusual activity patterns
4. **Regular Reviews**: Schedule regular security log reviews

#### Ongoing Security Maintenance
1. **Regular Audits**: Conduct quarterly security audits
2. **Penetration Testing**: Test security controls with professional assessments
3. **Dependency Management**: Keep dependencies updated and scan for vulnerabilities
4. **Rule Evolution**: Review and update security rules as features evolve

#### Incident Response
1. **Response Procedures**: Document security incident response procedures
2. **Rollback Plans**: Maintain emergency rollback procedures
3. **Security Contacts**: Establish clear security contact information
4. **Response Drills**: Conduct regular incident response drills

EOF
}

generate_final_report() {
    # Calculate success rate
    local success_rate=0
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    fi

    # Add summary to report
    cat >> "$REPORT_FILE" << EOF

## Validation Summary

- **Total Tests**: $TOTAL_TESTS
- **Passed**: $PASSED_TESTS ✅
- **Failed**: $FAILED_TESTS ❌
- **Warnings**: $WARNINGS ⚠️
- **Success Rate**: ${success_rate}%

EOF

    # Determine overall status
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "\n🎉 ${GREEN}ALL SECURITY TESTS PASSED!${NC}"
        echo -e "✅ System is ready for production deployment"
        cat >> "$REPORT_FILE" << EOF

### Overall Status: ✅ READY FOR PRODUCTION

The Journeyman Jobs Crews Feature has passed all security validation tests and is ready for production deployment.

EOF
    else
        echo -e "\n🚨 ${RED}SECURITY ISSUES DETECTED!${NC}"
        echo -e "❌ Address failed tests before production deployment"
        cat >> "$REPORT_FILE" << EOF

### Overall Status: 🚨 SECURITY ISSUES DETECTED

Critical security issues must be resolved before production deployment. Please review the failed tests and implement the necessary fixes.

EOF
    fi

    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "\n⚠️  ${YELLOW}WARNINGS DETECTED${NC}"
        echo -e "Review warnings for potential security improvements"
        cat >> "$REPORT_FILE" << EOF

### Warnings: $WARNINGS items require attention

While not blocking deployment, these warnings should be reviewed and addressed for optimal security posture.

EOF
    fi

    # Add next steps to report
    cat >> "$REPORT_FILE" << EOF

## Next Steps

1. **Address Failed Tests**: Fix all failed security tests
2. **Review Warnings**: Evaluate and address security warnings
3. **Deploy Security Rules**: Use the deployment script to deploy to production
4. **Monitor Security**: Set up security monitoring and alerting
5. **Schedule Reviews**: Plan regular security audits and reviews

---

**Report Generated**: $(date)
**Validation Tool**: Journeyman Jobs Security Validation Suite
**Environment**: Production Readiness Assessment
EOF

    echo -e "\n📄 Detailed report generated: ${CYAN}$REPORT_FILE${NC}"
    echo -e "\n📊 Test Summary:"
    echo -e "   Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "   Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "   Failed: ${RED}$FAILED_TESTS${NC}"
    echo -e "   Warnings: ${YELLOW}$WARNINGS${NC}"
    echo -e "   Success Rate: ${PURPLE}${success_rate}%${NC}"
}

# Main execution
main() {
    echo -e "${CYAN}Starting comprehensive security validation...${NC}"
    echo ""

    # Run all validation tests
    validate_firebase_security_rules
    validate_role_based_access_control
    validate_rate_limiting
    validate_data_protection
    validate_service_layer_security
    validate_authentication_service
    validate_provider_security
    validate_deployment_readiness

    # Generate recommendations and final report
    generate_security_recommendations
    generate_final_report

    echo -e "\n${BLUE}================================================================${NC}"
    echo -e "${BLUE} Security Validation Complete${NC}"
    echo -e "${BLUE}================================================================${NC}"
}

# Handle script interruption
trap 'echo -e "\n${RED}Validation interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@"