import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import '../../providers.dart';

class HistoryController extends Notifier<AsyncValue<List<StudyRecord>>> {
  @override
  AsyncValue<List<StudyRecord>> build() {
    return ref.watch(recordsProvider);
  }

  Future<void> deleteRecord(String id) async {
    await ref.read(databaseProvider).deleteRecord(id);
    ref.invalidate(recordsProvider);
  }
}

final historyControllerProvider =
    NotifierProvider<HistoryController, AsyncValue<List<StudyRecord>>>(
      HistoryController.new,
    );
