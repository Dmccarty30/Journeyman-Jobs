/**
 * Stream Chat Token Generation Cloud Function
 *
 * Securely generates Stream Chat user tokens using Firebase Authentication.
 *
 * Security Features:
 * - Requires Firebase authentication (unauthenticated users rejected)
 * - API secret never exposed to client
 * - User profile synced to Stream Chat (name, email, photo)
 * - Token scoped to authenticated user
 *
 * Environment Variables Required:
 * - STREAM_API_KEY: Stream Chat API key
 * - STREAM_API_SECRET: Stream Chat API secret (keep secure!)
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { StreamChat } from 'stream-chat';

// Initialize Stream Chat server client with credentials from environment
const streamApiKey = functions.config().stream?.api_key;
const streamApiSecret = functions.config().stream?.api_secret;

if (!streamApiKey || !streamApiSecret) {
  throw new Error('Stream Chat credentials not configured. Run: firebase functions:config:set stream.api_key="YOUR_KEY" stream.api_secret="YOUR_SECRET"');
}

const serverClient = StreamChat.getInstance(streamApiKey, streamApiSecret);

/**
 * Callable Cloud Function: getStreamUserToken
 *
 * Generates a Stream Chat user token for the authenticated Firebase user.
 *
 * @returns {Object} Response object containing:
 *   - success: boolean - Indicates if operation succeeded
 *   - token: string - Stream Chat user token
 *   - userId: string - Firebase user ID (same as Stream user ID)
 *
 * @throws {functions.https.HttpsError} If user is not authenticated
 *
 * Usage from Flutter:
 * ```dart
 * final functions = FirebaseFunctions.instance;
 * final result = await functions.httpsCallable('getStreamUserToken').call();
 * final token = result.data['token'] as String;
 * ```
 */
export const getStreamUserToken = functions.https.onCall(
  async (data, context) => {
    // Verify user is authenticated with Firebase
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated with Firebase to generate Stream Chat token'
      );
    }

    try {
      const userId = context.auth.uid;

      // Get Firebase user profile data
      const userRecord = await admin.auth().getUser(userId);

      // Upsert user to Stream Chat (create if new, update if exists)
      await serverClient.upsertUser({
        id: userId,
        name: userRecord.displayName || 'Anonymous User',
        image: userRecord.photoURL || '',
        email: userRecord.email || '',
        // Additional metadata can be added here
        // role: 'user', // Can be 'admin', 'moderator', etc.
      });

      // Generate Stream Chat token scoped to this user
      const token = serverClient.createToken(userId);

      functions.logger.info(`Stream Chat token generated for user: ${userId}`, {
        userId,
        userName: userRecord.displayName,
      });

      return {
        success: true,
        token,
        userId,
      };
    } catch (error) {
      functions.logger.error('Error generating Stream Chat token:', error);

      throw new functions.https.HttpsError(
        'internal',
        'Failed to generate Stream Chat token. Please try again.',
        { originalError: error instanceof Error ? error.message : String(error) }
      );
    }
  }
);

/**
 * Callable Cloud Function: updateUserTeam
 *
 * Updates the user's team assignment in Stream Chat.
 * Used when user switches between crews for team isolation.
 *
 * @param {Object} data - Request data
 * @param {string} data.teamId - Crew ID to assign user to
 *
 * @returns {Object} Response object containing:
 *   - success: boolean - Indicates if operation succeeded
 *   - userId: string - User ID
 *   - teamId: string - New team ID assigned
 *
 * @throws {functions.https.HttpsError} If user is not authenticated or teamId missing
 *
 * Usage from Flutter:
 * ```dart
 * await functions.httpsCallable('updateUserTeam').call({
 *   'teamId': crewId,
 * });
 * ```
 */
export const updateUserTeam = functions.https.onCall(
  async (data, context) => {
    // Verify user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated to update team'
      );
    }

    const { teamId } = data;

    if (!teamId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'teamId is required'
      );
    }

    try {
      const userId = context.auth.uid;

      // Update user's team in Stream Chat
      await serverClient.partialUpdateUser({
        id: userId,
        set: {
          teams: [teamId], // Assign user to single team (crew)
        },
      });

      functions.logger.info(`Updated user team assignment`, {
        userId,
        teamId,
      });

      return {
        success: true,
        userId,
        teamId,
      };
    } catch (error) {
      functions.logger.error('Error updating user team:', error);

      throw new functions.https.HttpsError(
        'internal',
        'Failed to update user team. Please try again.',
        { originalError: error instanceof Error ? error.message : String(error) }
      );
    }
  }
);
