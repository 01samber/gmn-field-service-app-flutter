import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../data/files_repository.dart';
import '../data/models/file_model.dart';

const bool _useMockData = true;

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  return FilesRepository(apiClient: ref.watch(apiClientProvider));
});

// Filter state
final filesFilterProvider = StateProvider<FilesFilter>((ref) {
  return FilesFilter();
});

// Mock files data
final _mockFiles = [
  FileModel(
    id: 'file-1',
    name: 'invoice_alpha_corp.pdf',
    type: 'application/pdf',
    size: 245000,
    path: '/uploads/invoice_alpha_corp.pdf',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    workOrderId: 'wo-1',
  ),
  FileModel(
    id: 'file-2',
    name: 'hvac_repair_photo.jpg',
    type: 'image/jpeg',
    size: 1850000,
    path: '/uploads/hvac_repair_photo.jpg',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    workOrderId: 'wo-1',
  ),
  FileModel(
    id: 'file-3',
    name: 'water_heater_receipt.pdf',
    type: 'application/pdf',
    size: 156000,
    path: '/uploads/water_heater_receipt.pdf',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    workOrderId: 'wo-2',
  ),
  FileModel(
    id: 'file-4',
    name: 'electrical_panel.jpg',
    type: 'image/jpeg',
    size: 2100000,
    path: '/uploads/electrical_panel.jpg',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    workOrderId: 'wo-3',
  ),
  FileModel(
    id: 'file-5',
    name: 'work_completion_form.pdf',
    type: 'application/pdf',
    size: 320000,
    path: '/uploads/work_completion_form.pdf',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    workOrderId: 'wo-6',
  ),
];

// Files list
final filesProvider = FutureProvider.autoDispose<List<FileModel>>((ref) async {
  if (_useMockData) {
    await Future.delayed(const Duration(milliseconds: 300));
    final filter = ref.watch(filesFilterProvider);
    var files = _mockFiles;

    if (filter.type != null && filter.type!.isNotEmpty) {
      files = files.where((f) => f.type.contains(filter.type!)).toList();
    }

    return files;
  }

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
