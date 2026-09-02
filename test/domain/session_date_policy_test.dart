import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/domain/policies/session_date_policy.dart';

void main() {
  const policy = SessionDatePolicy();

  test('cross-midnight sessions stay on the local start date', () {
    final started = DateTime(2026, 8, 14, 23, 50);
    expect(policy.startDate(started), DateTime(2026, 8, 14));
    expect(
      policy.startDate(started.add(const Duration(minutes: 20))),
      DateTime(2026, 8, 15),
    );
  });

  test('recent window is seven local calendar days', () {
    final now = DateTime(2026, 8, 21, 19);
    expect(policy.recentWindowStart(now), DateTime(2026, 8, 15));
  });
}
