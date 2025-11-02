# auth-flow-implementation

**Skill Type**: Technical Pattern | **Domain**: Backend Development | **Complexity**: Advanced

## Purpose

Master OAuth provider integration and authentication flows for Google, Apple, and email authentication with secure session management and user experience optimization.

## Core Capabilities

### 1. OAuth Provider Integration
```typescript
OAuth Providers:
  - Google OAuth 2.0 (popup and redirect flows)
  - Apple Sign In (web and native)
  - Email/Password authentication
  - Custom token authentication
  - Anonymous authentication

Provider Configuration:
  - OAuth scopes and permissions
  - Redirect URL configuration
  - Provider-specific settings
  - Error handling strategies
```

### 2. Authentication Flow Patterns

```typescript
// Google OAuth implementation
class GoogleAuthService {
  private provider: GoogleAuthProvider;

  constructor(private auth: Auth) {
    this.provider = new GoogleAuthProvider();
    this.configureProvider();
  }

  private configureProvider(): void {
    // Request specific scopes
    this.provider.addScope('profile');
    this.provider.addScope('email');

    // Custom parameters
    this.provider.setCustomParameters({
      prompt: 'select_account'
    });
  }

  async signInWithPopup(): Promise<UserCredential> {
    try {
      const result = await signInWithPopup(this.auth, this.provider);

      // Extract additional user info
      const credential = GoogleAuthProvider.credentialFromResult(result);
      const token = credential?.accessToken;

      return result;
    } catch (error: any) {
      throw this.handleAuthError(error);
    }
  }

  async signInWithRedirect(): Promise<void> {
    await signInWithRedirect(this.auth, this.provider);
  }

  async getRedirectResult(): Promise<UserCredential | null> {
    const result = await getRedirectResult(this.auth);
    return result;
  }

  private handleAuthError(error: FirebaseError): AuthenticationError {
    const errorMessages: Record<string, string> = {
      'auth/popup-closed-by-user': 'Sign-in was cancelled',
      'auth/cancelled-popup-request': 'Another popup is already open',
      'auth/popup-blocked': 'Popup was blocked by browser',
      'auth/account-exists-with-different-credential':
        'An account already exists with this email'
    };

    return new AuthenticationError(
      errorMessages[error.code] || 'Authentication failed',
      error.code
    );
  }
}

// Apple Sign In implementation
class AppleAuthService {
  private provider: OAuthProvider;

  constructor(private auth: Auth) {
    this.provider = new OAuthProvider('apple.com');
    this.configureProvider();
  }

  private configureProvider(): void {
    this.provider.addScope('email');
    this.provider.addScope('name');
  }

  async signIn(): Promise<UserCredential> {
    try {
      const result = await signInWithPopup(this.auth, this.provider);

      // Apple provides user info only on first sign-in
      const credential = OAuthProvider.credentialFromResult(result);

      return result;
    } catch (error: any) {
      throw this.handleAuthError(error);
    }
  }

  private handleAuthError(error: FirebaseError): AuthenticationError {
    // Similar error handling as Google
    return new AuthenticationError(error.message, error.code);
  }
}

// Email/Password authentication
class EmailAuthService {
  constructor(private auth: Auth) {}

  async signUp(email: string, password: string): Promise<UserCredential> {
    try {
      const result = await createUserWithEmailAndPassword(
        this.auth,
        email,
        password
      );

      // Send email verification
      await this.sendEmailVerification(result.user);

      return result;
    } catch (error: any) {
      throw this.handleAuthError(error);
    }
  }

  async signIn(email: string, password: string): Promise<UserCredential> {
    try {
      const result = await signInWithEmailAndPassword(
        this.auth,
        email,
        password
      );

      // Check if email is verified
      if (!result.user.emailVerified) {
        throw new EmailNotVerifiedError('Please verify your email');
      }

      return result;
    } catch (error: any) {
      throw this.handleAuthError(error);
    }
  }

  async sendPasswordReset(email: string): Promise<void> {
    await sendPasswordResetEmail(this.auth, email);
  }

  async sendEmailVerification(user: User): Promise<void> {
    await sendEmailVerification(user, {
      url: `${window.location.origin}/auth/verify`,
      handleCodeInApp: true
    });
  }

  async confirmPasswordReset(code: string, newPassword: string): Promise<void> {
    await confirmPasswordReset(this.auth, code, newPassword);
  }

  private handleAuthError(error: FirebaseError): AuthenticationError {
    const errorMessages: Record<string, string> = {
      'auth/email-already-in-use': 'Email is already registered',
      'auth/invalid-email': 'Invalid email address',
      'auth/weak-password': 'Password must be at least 6 characters',
      'auth/user-not-found': 'No account found with this email',
      'auth/wrong-password': 'Incorrect password'
    };

    return new AuthenticationError(
      errorMessages[error.code] || 'Authentication failed',
      error.code
    );
  }
}

class AuthenticationError extends Error {
  constructor(message: string, public code: string) {
    super(message);
    this.name = 'AuthenticationError';
  }
}

class EmailNotVerifiedError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'EmailNotVerifiedError';
  }
}
```

### 3. Unified Authentication Service

```typescript
// Central authentication service
class AuthenticationService {
  private googleAuth: GoogleAuthService;
  private appleAuth: AppleAuthService;
  private emailAuth: EmailAuthService;

  constructor(auth: Auth) {
    this.googleAuth = new GoogleAuthService(auth);
    this.appleAuth = new AppleAuthService(auth);
    this.emailAuth = new EmailAuthService(auth);
  }

  // Unified sign-in interface
  async signIn(
    provider: 'google' | 'apple' | 'email',
    credentials?: { email: string; password: string }
  ): Promise<UserCredential> {
    switch (provider) {
      case 'google':
        return this.googleAuth.signInWithPopup();

      case 'apple':
        return this.appleAuth.signIn();

      case 'email':
        if (!credentials) {
          throw new Error('Email and password required');
        }
        return this.emailAuth.signIn(credentials.email, credentials.password);

      default:
        throw new Error(`Unsupported provider: ${provider}`);
    }
  }

  async signUp(email: string, password: string): Promise<UserCredential> {
    return this.emailAuth.signUp(email, password);
  }

  async signOut(): Promise<void> {
    await signOut(this.auth);
  }

  async resetPassword(email: string): Promise<void> {
    return this.emailAuth.sendPasswordReset(email);
  }

  // Get current user
  getCurrentUser(): User | null {
    return this.auth.currentUser;
  }

  // Listen to auth state changes
  onAuthStateChange(callback: (user: User | null) => void): () => void {
    return onAuthStateChanged(this.auth, callback);
  }
}
```

## Best Practices

### Security
- **Password Strength**: Enforce minimum 8 characters with complexity requirements
- **Email Verification**: Require verification before granting full access
- **Rate Limiting**: Implement client-side rate limiting for sign-in attempts
- **HTTPS Only**: Always use HTTPS for authentication flows
- **Token Security**: Store tokens securely, never in localStorage for sensitive apps

### User Experience
- **Clear Error Messages**: User-friendly error messages without exposing security details
- **Loading States**: Show appropriate loading indicators during authentication
- **Remember Me**: Implement session persistence appropriately
- **Social Login Priority**: Offer social login as primary option when appropriate

## Quality Standards

- **Response Time**: Authentication <2s for popup flows, <3s for redirect flows
- **Error Recovery**: Graceful handling of all error scenarios
- **Accessibility**: Keyboard navigation and screen reader support
- **Mobile Support**: Touch-friendly UI with appropriate input types

## Related Skills
- `session-security` - Token management and session persistence
- `firebase-integration-architecture` - Auth service integration
- `serverless-architecture` - Cloud Functions auth triggers
