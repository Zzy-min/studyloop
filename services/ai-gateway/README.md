# StudyLoop AI Gateway

This Cloud Run service protects DeepSeek from mobile clients. It accepts only
minimal StudyLoop context after a verified Google Play Integrity assertion and
returns a short, schema-validated companion reply.

## Required production configuration

- Enable Play Integrity API, link the Play app `com.zzy.studyloop` to its Google Cloud project, and grant the Cloud Run service account permission to decode integrity tokens.
- Put `DEEPSEEK_API_KEY` and a high-entropy `SESSION_SIGNING_SECRET` in Secret Manager. Grant only the Cloud Run runtime service account `Secret Manager Secret Accessor`.
- Set `PLAY_APP_CERT_SHA256` to the Google Play App Signing certificate SHA-256 digest, `GOOGLE_CLOUD_PROJECT`, and optional `PLAY_PACKAGE_NAME`.
- Create the Firestore TTL policy for collection `studyloop_rate_limits`, using `expiresAt`; this keeps distributed rate-limit records bounded.
- Build with `npm ci && npm run build && npm test`. Deploy only after the owner approves the Cloud Run project, Secret Manager writes, IAM grants, and runtime URL.

The service logs request IDs, events, status categories, and latency only. It
does not log integrity tokens, authorization headers, model keys, messages, or
learning context.
