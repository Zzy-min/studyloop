# StudyLoop Production Console Configuration

This document is an approval-gated runbook. Do not perform any of its console
writes or purchases until the owner confirms the exact target account.

## Google Play

1. Enroll the app package `com.zzy.studyloop` in Google Play App Signing and
   register the upload certificate generated from the local upload keystore.
2. Create the subscription product `studyloop_pro_monthly` only if no compatible
   production subscription already exists. Set the first base plan to monthly,
   CNY 12.00, with no free trial or annual plan.
3. Link the Play application to the Google Cloud project used by the gateway,
   enable Play Integrity API, then copy the production App Signing SHA-256
   certificate digest into the Cloud Run environment variable
   `PLAY_APP_CERT_SHA256`.
4. Upload the signed AAB to an internal or closed testing track before production.
   Do not use RevenueCat Test Store purchase evidence as proof of this step.

## RevenueCat

1. Preserve existing Test Store products, offerings, and entitlement history.
   Do not delete legacy `studyloop_pro` or `pro` configuration.
2. Add the Google Play app and its service-account credentials through the
   RevenueCat Dashboard. Map `studyloop_pro_monthly` to entitlement `pro`,
   offering `default`, package `$rc_monthly`.
3. Verify in a Play testing build: purchase, cold-start entitlement refresh,
   explicit restore, and RevenueCat customer event. Record the console evidence
   without exposing keys or purchase tokens.

## Cloud Run

1. Create two Secret Manager secrets: `studyloop-deepseek-api-key` and
   `studyloop-session-signing-secret`. Grant only the gateway runtime service
   account `roles/secretmanager.secretAccessor`.
2. Give that service account only the Google Play Integrity decoding permission
   required by the linked project and Firestore access to
   `studyloop_rate_limits`.
3. Deploy `services/ai-gateway` with the required non-secret variables from its
   `.env.example`; mount both secrets as runtime environment variables. Configure
   Firestore TTL on `expiresAt`.
4. Put the resulting HTTPS base URL into the release build with
   `--dart-define=STUDYLOOP_AI_GATEWAY_URL=https://YOUR_CLOUD_RUN_URL`.

## Website

Build and deploy the `nextjs` site after verifying that
`/studyloop/privacy/` and `/studyloop/support/` resolve directly over HTTPS.
The application defaults to these public URLs on `https://qling.it.com`.
