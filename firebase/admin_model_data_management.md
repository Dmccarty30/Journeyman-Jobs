# Conceptual Admin Interface for AI Model Training Data Management

This document outlines the necessary Firebase backend structures and conceptual API endpoints for an administrative interface to manage data pertinent to AI model training.

## 1. Proposed Firestore Collections for Training Data

To effectively manage training data, distinct Firestore collections will be used, potentially mirroring or deriving from user-facing data.

*   **`model_feedback`**: Stores processed or curated user feedback specifically for model training.
    *   Fields might include: `originalFeedbackId`, `jobId`, `userId`, `sentimentLabel` (human-assigned), `categoryLabels`, `reviewStatus`, `updatedAt`.
*   **`model_summaries`**: Stores original job descriptions and their human-validated summaries for training the summarization model.
    *   Fields might include: `jobId`, `originalDescription`, `humanSummary`, `reviewStatus`, `updatedAt`.
*   **`model_suggestions`**: Stores pairs of original jobs and suggested jobs, along with human-validated reasons for suggestions and relevance scores, for training the recommendation engine.
    *   Fields might include: `originalJobId`, `suggestedJobId`, `humanReason`, `humanRelevanceScore`, `reviewStatus`, `updatedAt`.
*   **`model_parameters`**: (Optional) Stores configurable parameters for the AI models, allowing admins to fine-tune aspects without code deployments.

## 2. Conceptual Firebase Functions / API Endpoints

These Cloud Functions would expose secure API endpoints for the admin interface to perform CRUD (Create, Read, Update, Delete) operations on the training data. Access to these functions must be strictly controlled (see Security Considerations).

### 2.1. `addTrainingData`

*   **Endpoint**: `POST /api/admin/trainingData/{collectionName}`
*   **Description**: Adds a new record to the specified training data collection.
*   **Payload**: JSON object representing the training data.
*   **Permissions**: Admin role required.

### 2.2. `updateTrainingData`

*   **Endpoint**: `PUT /api/admin/trainingData/{collectionName}/{documentId}`
*   **Description**: Updates an existing record in the specified training data collection.
*   **Payload**: JSON object with fields to update.
*   **Permissions**: Admin role required.

### 2.3. `deleteTrainingData`

*   **Endpoint**: `DELETE /api/admin/trainingData/{collectionName}/{documentId}`
*   **Description**: Deletes a record from the specified training data collection.
*   **Permissions**: Admin role required.

### 2.4. `getTrainingData`

*   **Endpoint**: `GET /api/admin/trainingData/{collectionName}`
*   **Description**: Retrieves records from the specified training data collection, with optional filtering and pagination.
*   **Query Parameters**: `?filterBy=field&filterValue=value&limit=X&offset=Y`
*   **Permissions**: Admin role required.

## 3. Security Considerations

*   **Authentication**: All admin API endpoints must require Firebase Authentication.
*   **Authorization**: Implement robust role-based access control (RBAC). Only users with an `admin` role (e.g., stored in their `users` document or a custom claim) should be able to call these functions.
*   **Input Validation**: Strict validation of all incoming data to prevent injection attacks and ensure data integrity.
*   **Logging**: All admin actions should be logged for auditing purposes.

## 4. Admin Frontend Interface (Conceptual)

The actual UI for the admin interface would be a separate web application (e.g., built with React, Vue, or a Flutter web app) that consumes these backend API endpoints. It would provide tables, forms, and tools for administrators to review, modify, and curate the training datasets.
