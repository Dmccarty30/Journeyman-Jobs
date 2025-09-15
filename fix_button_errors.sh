#!/bin/bash

# Fix Flutter compilation errors for missing button size parameters
# This script adds the required 'size' parameter to all JJPrimaryButton and JJSecondaryButton instances

echo "Fixing button compilation errors..."

# Create backup directory
mkdir -p backup_before_button_fix
cp -r lib backup_before_button_fix/

# Function to add size parameter to buttons in a file
fix_buttons_in_file() {
    local file="$1"
    local size="$2"

    echo "Fixing buttons in $file with size: $size"

    # Fix JJPrimaryButton instances
    sed -i "s/JJPrimaryButton(/JJPrimaryButton(\n            size: ButtonSize.$size,/g" "$file"

    # Fix JJSecondaryButton instances
    sed -i "s/JJSecondaryButton(/JJSecondaryButton(\n            size: ButtonSize.$size,/g" "$file"
}

# Fix welcome screen (use large buttons for main CTAs)
fix_buttons_in_file "lib/screens/onboarding/welcome_screen.dart" "large"

# Fix auth screens (use medium buttons for forms)
fix_buttons_in_file "lib/screens/auth/forgot_password_screen.dart" "medium"

# Fix settings screens (use medium buttons for standard actions)
fix_buttons_in_file "lib/screens/settings/feedback/feedback_screen.dart" "medium"
fix_buttons_in_file "lib/screens/settings/notification_settings_screen.dart" "medium"
fix_buttons_in_file "lib/screens/settings/app_settings_screen.dart" "medium"

# Fix tools screen (use medium buttons for forms)
fix_buttons_in_file "lib/screens/tools/electrical_calculators_screen.dart" "medium"

# Fix notifications screen (use medium buttons)
fix_buttons_in_file "lib/screens/notifications/notifications_screen.dart" "medium"

# Fix notification service (use small buttons for dialogs)
fix_buttons_in_file "lib/services/notification_permission_service.dart" "small"

echo "Button fixes complete!"
echo "Backup created in backup_before_button_fix/"
echo ""
echo "Please run 'flutter pub get' and then 'flutter build' to test the fixes."
echo ""
echo "If there are formatting issues, run 'dart format lib/' to clean up the code."