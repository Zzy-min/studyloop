class AppEnvironment {
  const AppEnvironment._();
  static const revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');
  static const proEntitlementId = String.fromEnvironment(
    'REVENUECAT_ENTITLEMENT',
    defaultValue: 'pro',
  );
  static const aiGatewayBaseUrl = String.fromEnvironment(
    'STUDYLOOP_AI_GATEWAY_URL',
    defaultValue: '',
  );
  static const privacyPolicyUrl = String.fromEnvironment(
    'STUDYLOOP_PRIVACY_URL',
    defaultValue: 'https://qling.it.com/studyloop/privacy/',
  );
  static const supportUrl = String.fromEnvironment(
    'STUDYLOOP_SUPPORT_URL',
    defaultValue: 'https://qling.it.com/studyloop/support/',
  );
}
