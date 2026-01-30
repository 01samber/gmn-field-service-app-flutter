import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../data/files_repository.dart';
import '../data/models/file_model.dart';

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  return FilesRepository(apiClient: ref.watch(apiClientProvider));
});

// Filter state
final filesFilterProvider = StateProvider<FilesFilter>((ref) {
  return FilesFilter();
});

// Files list
final filesProvider = FutureProvider.autoDispose<List<FileModel>>((ref) async {
  final repository = ref.watch(filesRepositoryProvider);
  final filter = ref.watch(filesFilterProvider);
  return repository.getFiles(filter: filter);
});

// Upload progress
final uploadProgressProvider = StateProvider<double?>((ref) => null);

// Files operations notifier
class FilesNotifier extends StateNotifier<AsyncValue<void>> {
  final FilesRepository _repository;
  final Ref _ref;

  FilesNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<FileModel?> upload(File file, {String? workOrderId}) async {
    state = const AsyncValue.loading();
    _ref.read(uploadProgressProvider.notifier).state = 0;

    try {
      final fileModel = await _repository.uploadFile(
        file: file,
        workOrderId: workOrderId,
        onProgress: (sent, total) {
          _ref.read(uploadProgressProvider.notifier).state = sent / total;
        },
      );
      _ref.invalidate(filesProvider);
      _ref.read(uploadProgressProvider.notifier).state = null;
      state = const AsyncValue.data(null);
      return fileModel;
    } catch (e, st) {
      _ref.read(uploadProgressProvider.notifier).state = null;
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteFile(id);
      _ref.invalidate(filesProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  String getFileUrl(String path) {
    return _repository.getFileUrl(path);
  }
}

final filesNotifierProvider =
    StateNotifierProvider<FilesNotifier, AsyncValue<void>>((ref) {
      return FilesNotifier(ref.watch(filesRepositoryProvider), ref);
    });
