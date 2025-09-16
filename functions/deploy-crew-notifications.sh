#!/bin/bash

# Firebase Cloud Functions Deployment Script for Crew Notifications
# Journeyman Jobs - IBEW Platform

echo "🚀 Deploying Firebase Cloud Functions for Crew Notifications..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if we're in the functions directory
if [ ! -f "package.json" ]; then
    echo "❌ Please run this script from the functions directory"
    exit 1
fi

echo "📦 Installing dependencies..."
npm install

echo "🔍 Running lint checks..."
npm run lint

if [ $? -ne 0 ]; then
    echo "❌ Lint checks failed. Please fix the issues and try again."
    exit 1
fi

echo "🧪 Running syntax validation..."
node -c src/index.js
node -c src/crews.js
node -c src/notifications.js
node -c src/sms.js
node -c src/quickSignup.js
node -c src/analytics.js

if [ $? -ne 0 ]; then
    echo "❌ Syntax validation failed."
    exit 1
fi

echo "✅ All checks passed! Deploying functions..."

# Deploy functions with specific targeting for crew features
echo "🚀 Deploying crew notification functions..."

firebase deploy --only functions:onJobSharedToCrewEnhanced,functions:onCrewMemberAddedEnhanced,functions:onCrewMessageSentEnhanced,functions:updateFCMToken,functions:sendEmergencyStormAlert,functions:cleanupInvalidFCMTokens

if [ $? -eq 0 ]; then
    echo "✅ Crew notification functions deployed successfully!"
    echo ""
    echo "📋 Deployed Functions:"
    echo "  • onJobSharedToCrewEnhanced - Enhanced job sharing notifications"
    echo "  • onCrewMemberAddedEnhanced - Enhanced member join notifications" 
    echo "  • onCrewMessageSentEnhanced - Enhanced crew message notifications"
    echo "  • updateFCMToken - FCM token management"
    echo "  • sendEmergencyStormAlert - Emergency storm work alerts"
    echo "  • cleanupInvalidFCMTokens - Automated token cleanup"
    echo ""
    echo "🔧 Next Steps:"
    echo "  1. Update your Flutter app to use the enhanced notification functions"
    echo "  2. Configure FCM notification channels in your mobile app"
    echo "  3. Set up Firestore security rules for crew collections"
    echo "  4. Test notifications with crew creation and job sharing flows"
    echo ""
    echo "📱 FCM Integration:"
    echo "  • Call updateFCMToken when user logs in or token refreshes"
    echo "  • Use crew topic subscriptions: crew_{crewId}"
    echo "  • Handle deep links from notification data"
    echo ""
else
    echo "❌ Deployment failed. Please check the error messages above."
    exit 1
fi
