import 'package:flutter_test/flutter_test.dart';
import 'package:overfood/core/services/in_app_update_service.dart';

void main() {
  tearDown(InAppUpdateService.resetForTesting);

  test('resetForTesting clears launch guard', () {
    InAppUpdateService.resetForTesting();
    expect(InAppUpdateService.isUpdateFlowActive, isFalse);
  });

  test('checkForUpdate skips on non-Android test host', () async {
    final result = await InAppUpdateService.checkForUpdate();
    expect(result, InAppUpdateStartupResult.skipped);
  });
}
