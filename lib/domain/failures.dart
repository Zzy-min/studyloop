sealed class AppFailure {
  const AppFailure(this.userMessage);
  final String userMessage;
}

class DatabaseFailure extends AppFailure {
  const DatabaseFailure([String? message])
    : super(message ?? 'Local database operation failed. Please try again.');
}

class BillingUnavailableFailure extends AppFailure {
  const BillingUnavailableFailure([String? message])
    : super(message ?? 'Subscription service is temporarily unavailable.');
}

class SessionNotFoundFailure extends AppFailure {
  const SessionNotFoundFailure([String? message])
    : super(message ?? 'Study session was not found.');
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([String? message])
    : super(message ?? 'An unexpected error occurred.');
}
