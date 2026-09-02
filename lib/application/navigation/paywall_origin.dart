const allowedPaywallOrigins = {'/insights', '/history', '/settings', '/'};

String normalizePaywallOrigin(Object? extra) {
  final value = extra is String ? extra : '/insights';
  return allowedPaywallOrigins.contains(value) ? value : '/insights';
}
