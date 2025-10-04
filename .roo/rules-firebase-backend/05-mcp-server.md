# MCP server recommendations (for running emulators, migrators, and integration tests):

      Recommended MCP server capabilities:
      - Node 16/18+ runtime with npm/yarn installed
      - Docker & docker-compose (for reproducible emulator environments)
      - Firebase CLI (firebase-tools) pinned to the project's supported version
      - gcloud SDK if project integrates with GCP services
      - Enough CPU/memory for emulators (recommend 4GB+ RAM, swap)
      - Expose only required emulator ports to Roo's MCP process (do not expose production ports)

      Recommended minimal docker-compose for MCP (example - place under repo or MCP config):

      version: "3.8"
      services:
        firebase-emulator:
          image: node:18-buster
          working_dir: /workspace
          volumes:
            - ./:/workspace:cached
          command: >
            /bin/sh -c "npm install -g firebase-tools@latest &&
                        npm ci || true &&
                        firebase emulators:start --project $FIREBASE_PROJECT_ID --only firestore,functions,auth,hosting --import=./emulator-import --export-on-exit"
          environment:
            - FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}
          ports:
            - "4000:4000"  # functions emulator
            - "8080:8080"  # firestore emulator
            - "9099:9099"  # auth emulator
          shm_size: '1gb'

      MCP usage patterns:
      - Use MCP for: running emulator suite, executing migration scripts that touch many documents, running integration tests that talk to local emulators.
      - Do not use MCP to access production credentials. Use service account with restricted rights for migration/testing.
      - For large data migrations, produce a dry-run report first (counts, estimated cost), then run patchable batches with idempotent operations and checkpointing.
