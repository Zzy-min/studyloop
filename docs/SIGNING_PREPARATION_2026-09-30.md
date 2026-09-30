# Local upload signing preparation — September 30, 2026

The owner explicitly authorized generating a new StudyLoop upload key. This preparation is optional for the Next Gen competition, which requires neither a paid developer account nor a published store listing.

## Completed

- Generated a dedicated RSA 3072-bit upload key, alias `upload`, validity 10,000 days, outside the repository in the owner's private signing directory.
- Restricted the private directory and ignored `android/key.properties` to the current Windows user and SYSTEM. Keystore and passwords are not tracked or published.
- Created a separate local backup copy and confirmed its keystore SHA-256 matches the original. Both copies are on the same computer; an owner-managed offline backup remains recommended before future distribution.
- `flutter build appbundle --release --no-pub` succeeded. No RevenueCat API key or remote gateway URL was passed to this build.
- `jarsigner -verify` reports the JAR verified; `keytool -printcert -jarfile` confirms the expected signer certificate rather than the debug certificate.

## Public verification data

| Item | Value |
| --- | --- |
| Package | `com.zzy.studyloop` |
| Certificate SHA-256 | `FA:2F:C3:5B:0A:7F:35:47:DA:88:5D:55:64:37:CB:80:3B:EA:B4:B5:07:EF:CA:48:55:05:7E:BC:5E:2B:F4:CB` |
| Local artifact | `build/app/outputs/bundle/release/app-release.aab` |
| AAB size | 81,192,478 bytes |
| AAB SHA-256 | `5DCAB320EE39C228CE5D6E5106A53991B0CBBFAB1014E14D9F08D8235B1AC8CE` |

## Boundaries

This key is not enrolled in Google Play App Signing, and the AAB has not been uploaded or installed from Play. The verifier reports a self-signed certificate, absent timestamp, ignored POSIX attributes and JarInputStream metadata-order warnings; these are retained as validation limits, not a claim of Play Console acceptance. Future distribution must reuse this identity or deliberately reset the upload key through the store. Do not replace it silently.

This credential-free AAB runs local features without enabling RevenueCat checkout or a remote gateway. Existing Test Store evidence belongs to the separately configured competition demo. Production payment is outside the owner's current student-only competition scope.
