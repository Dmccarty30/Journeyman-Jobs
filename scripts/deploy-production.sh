#!/bin/bash

# Production Deployment Script for Journeyman Jobs
# This script handles the complete production deployment process
# including Firebase Functions, Firestore rules, and app configuration

set -e  # Exit on any error

echo "🚀 Starting Journeyman Jobs Production Deployment"
echo "=================================================="

# Configuration
PROJECT_ID="journeyman-jobs-prod"
REGION="us-central1"
ENVIRONMENT="production"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Firebase CLI
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI is not installed. Please install it first:"
        echo "npm install -g firebase-tools"
        exit 1
    fi
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed. Please install it first."
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install it first."
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Function to validate environment variables
validate_environment() {
    print_status "Validating environment configuration..."
    
    if [ ! -f ".env.production" ]; then
        print_error ".env.production file not found!"
        print_warning "Please create .env.production with all required environment variables"
        exit 1
    fi
    
    # Source production environment variables
    source .env.production
    
    # Check critical environment variables
    if [ -z "$FIREBASE_PROJECT_ID" ] || [ -z "$SENDGRID_API_KEY" ]; then
        print_error "Critical environment variables are missing in .env.production"
        exit 1
    fi
    
    print_success "Environment validation passed"
}

# Function to authenticate with Firebase
authenticate_firebase() {
    print_status "Authenticating with Firebase..."
    
    # Check if already logged in
    if firebase projects:list &> /dev/null; then
        print_success "Already authenticated with Firebase"
    else
        print_status "Please log in to Firebase..."
        firebase login
    fi
    
    # Set the project
    firebase use $PROJECT_ID
    print_success "Using Firebase project: $PROJECT_ID"
}

# Function to build and test Cloud Functions
build_cloud_functions() {
    print_status "Building and testing Cloud Functions..."
    
    cd functions
    
    # Install dependencies
    print_status "Installing function dependencies..."
    npm ci --production
    
    # Build TypeScript
    print_status "Building TypeScript..."
    npm run build
    
    # Run tests
    print_status "Running function tests..."
    npm test
    
    cd ..
    print_success "Cloud Functions built and tested successfully"
}

# Function to deploy Firestore security rules and indexes
deploy_firestore_config() {
    print_status "Deploying Firestore security rules and indexes..."
    
    # Use production-specific configuration
    cp firebase/firebase.prod.json firebase/firebase.json
    cp firebase/firestore.prod.rules firebase/firestore.rules
    
    # Deploy rules and indexes
    firebase deploy --only firestore:rules,firestore:indexes --project $PROJECT_ID
    
    # Restore development configuration
    git checkout firebase/firebase.json firebase/firestore.rules
    
    print_success "Firestore configuration deployed successfully"
}

# Function to deploy Cloud Functions
deploy_cloud_functions() {
    print_status "Deploying Cloud Functions..."
    
    # Set environment variables for functions
    print_status "Setting function environment variables..."
    firebase functions:config:set \
        sendgrid.api_key="$SENDGRID_API_KEY" \
        twilio.account_sid="$TWILIO_ACCOUNT_SID" \
        twilio.auth_token="$TWILIO_AUTH_TOKEN" \
        app.deep_link_scheme="$DEEP_LINK_SCHEME" \
        app.cors_origins="$CORS_ORIGIN" \
        --project $PROJECT_ID
    
    # Deploy functions
    firebase deploy --only functions --project $PROJECT_ID
    
    print_success "Cloud Functions deployed successfully"
}

# Function to deploy Storage rules
deploy_storage_rules() {
    print_status "Deploying Storage security rules..."
    
    firebase deploy --only storage --project $PROJECT_ID
    
    print_success "Storage rules deployed successfully"
}

# Function to build Flutter web app
build_flutter_web() {
    print_status "Building Flutter web application..."
    
    # Clean previous build
    flutter clean
    flutter pub get
    
    # Build web version with production configuration
    flutter build web --release \
        --dart-define=ENVIRONMENT=production \
        --dart-define=FIREBASE_PROJECT_ID=$PROJECT_ID
    
    print_success "Flutter web application built successfully"
}

# Function to deploy web hosting
deploy_web_hosting() {
    print_status "Deploying web hosting..."
    
    firebase deploy --only hosting --project $PROJECT_ID
    
    print_success "Web hosting deployed successfully"
}

# Function to run post-deployment health checks
run_health_checks() {
    print_status "Running post-deployment health checks..."
    
    # Wait a moment for deployment to settle
    sleep 10
    
    # Check Cloud Functions endpoints
    print_status "Checking Cloud Functions endpoints..."
    
    # Test health endpoint
    HEALTH_URL="https://$REGION-$PROJECT_ID.cloudfunctions.net/api/health"
    if curl -f -s $HEALTH_URL > /dev/null; then
        print_success "Health endpoint is responding"
    else
        print_warning "Health endpoint check failed"
    fi
    
    # Check Firestore connectivity
    print_status "Checking Firestore connectivity..."
    firebase firestore:databases:list --project $PROJECT_ID > /dev/null
    print_success "Firestore is accessible"
    
    print_success "Health checks completed"
}

# Function to create deployment summary
create_deployment_summary() {
    print_status "Creating deployment summary..."
    
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    DEPLOY_LOG="deployment-log-$(date '+%Y%m%d-%H%M%S').md"
    
    cat > $DEPLOY_LOG << EOF
# Production Deployment Summary

**Date:** $TIMESTAMP
**Environment:** Production
**Project ID:** $PROJECT_ID
**Region:** $REGION

## Deployed Components

- ✅ Firestore Security Rules
- ✅ Firestore Indexes
- ✅ Cloud Functions
- ✅ Storage Rules
- ✅ Web Hosting

## URLs

- **App URL:** https://$PROJECT_ID.web.app
- **API URL:** https://$REGION-$PROJECT_ID.cloudfunctions.net/api
- **Admin Console:** https://console.firebase.google.com/project/$PROJECT_ID

## Next Steps

1. Verify all functionality is working correctly
2. Monitor error logs and performance metrics
3. Test job sharing features end-to-end
4. Update mobile app configurations if needed

## Rollback Instructions

If issues occur, run:
\`\`\`bash
# Rollback to previous version
firebase functions:log --project $PROJECT_ID
firebase rollback --project $PROJECT_ID
\`\`\`

EOF
    
    print_success "Deployment summary created: $DEPLOY_LOG"
    
    # Display summary
    echo ""
    echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉"
    echo "======================================"
    echo "App URL: https://$PROJECT_ID.web.app"
    echo "API URL: https://$REGION-$PROJECT_ID.cloudfunctions.net/api"
    echo "Admin: https://console.firebase.google.com/project/$PROJECT_ID"
    echo ""
    echo "📋 Deployment log: $DEPLOY_LOG"
}

# Main execution
main() {
    echo "Starting deployment at $(date)"
    
    # Run all deployment steps
    check_prerequisites
    validate_environment
    authenticate_firebase
    build_cloud_functions
    deploy_firestore_config
    deploy_cloud_functions
    deploy_storage_rules
    build_flutter_web
    deploy_web_hosting
    run_health_checks
    create_deployment_summary
    
    print_success "🚀 Production deployment completed successfully!"
}

# Error handling
trap 'print_error "Deployment failed at line $LINENO"' ERR

# Execute main function
main "$@"