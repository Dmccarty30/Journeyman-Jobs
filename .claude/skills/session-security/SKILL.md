# session-security

**Skill Type**: Security Pattern | **Domain**: Backend Development | **Complexity**: Advanced

## Purpose

Master secure session management, token lifecycle, multi-factor authentication, and cross-tab synchronization for robust authentication security.

## Core Capabilities

### 1. Token Management
```typescript
Token Lifecycle:
  - Access Token: 1 hour expiration, JWT format
  - Refresh Token: 30-day expiration, secure storage
  - ID Token: User claims and profile data
  - Custom Claims: Role-based access control

Token Operations:
  - Automatic refresh before expiration
  - Secure storage (HttpOnly cookies preferred)
  - Token validation on each request
  - Revocation on logout or security events
```

### 2. Session Management Implementation

```typescript
// Session manager
class SessionManager {
  private refreshTimer?: NodeJS.Timeout;
  private readonly REFRESH_BUFFER = 5 * 60 * 1000; // 5 minutes before expiry

  constructor(private auth: Auth) {
    this.setupAuthListener();
  }

  private setupAuthListener(): void {
    onAuthStateChanged(this.auth, async (user) => {
      if (user) {
        await this.initializeSession(user);
      } else {
        this.cleanupSession();
      }
    });
  }

  private async initializeSession(user: User): Promise<void> {
    try {
      // Get ID token
      const idToken = await user.getIdToken();
      const idTokenResult = await user.getIdTokenResult();

      // Store token metadata
      this.storeTokenMetadata({
        expirationTime: idTokenResult.expirationTime,
        issuedAtTime: idTokenResult.issuedAtTime,
        claims: idTokenResult.claims
      });

      // Schedule token refresh
      this.scheduleTokenRefresh(user, idTokenResult.expirationTime);

      // Setup cross-tab synchronization
      this.setupCrossTabSync();

      console.log('Session initialized');
    } catch (error) {
      console.error('Failed to initialize session:', error);
      throw error;
    }
  }

  private scheduleTokenRefresh(user: User, expirationTime: string): void {
    const expiryMs = new Date(expirationTime).getTime();
    const now = Date.now();
    const refreshAt = expiryMs - this.REFRESH_BUFFER;
    const delay = refreshAt - now;

    if (delay > 0) {
      this.refreshTimer = setTimeout(async () => {
        await this.refreshToken(user);
      }, delay);

      console.log(`Token refresh scheduled in ${Math.round(delay / 1000)}s`);
    } else {
      // Token already expired or about to expire, refresh immediately
      this.refreshToken(user);
    }
  }

  private async refreshToken(user: User): Promise<void> {
    try {
      const newToken = await user.getIdToken(true); // Force refresh
      const newTokenResult = await user.getIdTokenResult();

      this.storeTokenMetadata({
        expirationTime: newTokenResult.expirationTime,
        issuedAtTime: newTokenResult.issuedAtTime,
        claims: newTokenResult.claims
      });

      // Schedule next refresh
      this.scheduleTokenRefresh(user, newTokenResult.expirationTime);

      console.log('Token refreshed successfully');
    } catch (error) {
      console.error('Token refresh failed:', error);
      // Force re-authentication if refresh fails
      await this.auth.signOut();
    }
  }

  private storeTokenMetadata(metadata: TokenMetadata): void {
    sessionStorage.setItem('token_metadata', JSON.stringify(metadata));
  }

  private getTokenMetadata(): TokenMetadata | null {
    const stored = sessionStorage.getItem('token_metadata');
    return stored ? JSON.parse(stored) : null;
  }

  private setupCrossTabSync(): void {
    // Listen for storage events (cross-tab communication)
    window.addEventListener('storage', (event) => {
      if (event.key === 'auth_state') {
        // Another tab changed auth state
        if (event.newValue === 'signed_out') {
          this.cleanupSession();
        }
      }
    });
  }

  private cleanupSession(): void {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = undefined;
    }

    sessionStorage.removeItem('token_metadata');
    localStorage.setItem('auth_state', 'signed_out');

    console.log('Session cleaned up');
  }

  async signOut(): Promise<void> {
    await this.auth.signOut();
    this.cleanupSession();
  }
}

interface TokenMetadata {
  expirationTime: string;
  issuedAtTime: string;
  claims: Record<string, any>;
}
```

### 3. Multi-Factor Authentication (MFA)

```typescript
// MFA service
class MFAService {
  constructor(private auth: Auth) {}

  async enrollTOTP(user: User): Promise<{ secret: string; qrCode: string }> {
    try {
      // Get multi-factor session
      const multiFactorSession = await multiFactor(user).getSession();

      // Generate TOTP secret
      const totpSecret = await TotpMultiFactorGenerator.generateSecret(
        multiFactorSession
      );

      // Generate QR code URL for authenticator apps
      const qrCodeUrl = totpSecret.generateQrCodeUrl(
        user.email || 'user@example.com',
        'YourAppName'
      );

      return {
        secret: totpSecret.secretKey,
        qrCode: qrCodeUrl
      };
    } catch (error) {
      console.error('TOTP enrollment failed:', error);
      throw error;
    }
  }

  async verifyAndEnrollTOTP(
    user: User,
    totpSecret: TotpSecret,
    verificationCode: string,
    displayName: string = 'TOTP Device'
  ): Promise<void> {
    try {
      // Create assertion from verification code
      const multiFactorAssertion = TotpMultiFactorGenerator.assertionForEnrollment(
        totpSecret,
        verificationCode
      );

      // Enroll the MFA factor
      await multiFactor(user).enroll(multiFactorAssertion, displayName);

      console.log('TOTP enrolled successfully');
    } catch (error) {
      console.error('TOTP verification failed:', error);
      throw new Error('Invalid verification code');
    }
  }

  async signInWithMFA(
    resolver: MultiFactorResolver,
    verificationCode: string
  ): Promise<UserCredential> {
    try {
      // Get TOTP multi-factor info
      const totpInfo = resolver.hints.find(
        hint => hint.factorId === TotpMultiFactorGenerator.FACTOR_ID
      );

      if (!totpInfo) {
        throw new Error('TOTP not configured');
      }

      // Create assertion from code
      const multiFactorAssertion = TotpMultiFactorGenerator.assertionForSignIn(
        totpInfo.uid,
        verificationCode
      );

      // Complete sign-in with MFA
      const credential = await resolver.resolveSignIn(multiFactorAssertion);

      console.log('MFA sign-in successful');
      return credential;
    } catch (error) {
      console.error('MFA sign-in failed:', error);
      throw new Error('Invalid verification code');
    }
  }

  async unenrollMFA(user: User, factorUid: string): Promise<void> {
    try {
      const enrolledFactors = multiFactor(user).enrolledFactors;
      const factor = enrolledFactors.find(f => f.uid === factorUid);

      if (!factor) {
        throw new Error('MFA factor not found');
      }

      await multiFactor(user).unenroll(factor);

      console.log('MFA unenrolled successfully');
    } catch (error) {
      console.error('MFA unenrollment failed:', error);
      throw error;
    }
  }

  getEnrolledFactors(user: User): MultiFactorInfo[] {
    return multiFactor(user).enrolledFactors;
  }
}
```

### 4. Session Persistence Strategies

```typescript
// Session persistence manager
class SessionPersistence {
  async setPersistence(
    auth: Auth,
    type: 'local' | 'session' | 'none'
  ): Promise<void> {
    const persistenceMap = {
      local: browserLocalPersistence,    // Persists until explicit sign-out
      session: browserSessionPersistence, // Persists until tab close
      none: inMemoryPersistence          // Clears on page refresh
    };

    await setPersistence(auth, persistenceMap[type]);
    console.log(`Persistence set to: ${type}`);
  }

  // Handle "Remember Me" functionality
  async handleRememberMe(auth: Auth, rememberMe: boolean): Promise<void> {
    if (rememberMe) {
      await this.setPersistence(auth, 'local');
    } else {
      await this.setPersistence(auth, 'session');
    }
  }

  // Detect persistence type
  getPersistenceType(auth: Auth): string {
    // Firebase doesn't expose this directly, store in app state
    return sessionStorage.getItem('persistence_type') || 'session';
  }
}
```

## Best Practices

### Token Security
- **Secure Storage**: Use HttpOnly cookies or secure sessionStorage
- **Short Expiration**: Access tokens expire in 1 hour
- **Automatic Refresh**: Refresh tokens before expiration
- **Revocation**: Immediately revoke tokens on sign-out
- **HTTPS Only**: Never transmit tokens over HTTP

### Session Management
- **Inactivity Timeout**: Auto sign-out after 30 minutes of inactivity
- **Cross-Tab Sync**: Synchronize auth state across tabs
- **Single Sign-On**: Support SSO where appropriate
- **Secure Cookies**: Use Secure and SameSite flags

### MFA Implementation
- **TOTP Preferred**: Use TOTP (Google Authenticator) over SMS
- **Backup Codes**: Provide recovery codes for account recovery
- **Enrollment UX**: Clear instructions for MFA setup
- **Graceful Fallback**: Handle MFA failures gracefully

## Quality Standards

- **Token Refresh**: <500ms for token renewal
- **Session Check**: <100ms for auth state verification
- **MFA Verification**: <300ms for TOTP validation
- **Security**: Pass OWASP authentication requirements
- **Compliance**: Meet industry standards (PCI DSS, HIPAA if applicable)

## Related Skills
- `auth-flow-implementation` - Authentication flows
- `firebase-integration-architecture` - Auth service integration
- `serverless-architecture` - Auth triggers and custom claims
