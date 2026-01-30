import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/formatters.dart';
import '../providers/files_provider.dart';
import '../data/models/file_model.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(filesProvider);
    final uploadProgress = ref.watch(uploadProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() => _selectedType = type);
              ref.read(filesFilterProvider.notifier).state = FilesFilter(
                type: type,
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Files')),
              const PopupMenuItem(value: 'image', child: Text('Images')),
              const PopupMenuItem(value: 'pdf', child: Text('PDFs')),
              const PopupMenuItem(value: 'video', child: Text('Videos')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Upload progress
          if (uploadProgress != null)
            LinearProgressIndicator(
              value: uploadProgress,
              backgroundColor: AppColors.surfaceVariant,
            ),

          // Filter chip
          if (_selectedType != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Chip(
                    label: Text(Formatters.capitalize(_selectedType!)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() => _selectedType = null);
                      ref.read(filesFilterProvider.notifier).state =
                          FilesFilter();
                    },
                  ),
                ],
              ),
            ),

          // Files grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(filesProvider);
              },
              child: filesAsync.when(
                data: (files) {
                  if (files.isEmpty) {
                    return EmptyState(
                      icon: Icons.folder_outlined,
                      title: 'No Files',
                      message: 'Upload files to get started',
                      actionLabel: 'Upload File',
                      onAction: _showUploadOptions,
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      return _FileCard(
                        file: files[index],
                        onTap: () => _showFilePreview(files[index]),
                        onDelete: () => _deleteFile(files[index]),
                      );
                    },
                  );
                },
                loading: () => PageLoader(),
                error: (error, stack) => ErrorMessage(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(filesProvider),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadOptions,
        icon: const Icon(Icons.upload),
        label: const Text('Upload'),
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Choose File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _uploadFile(File(image.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _uploadFile(File(image.path));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      await _uploadFile(File(result.files.single.path!));
    }
  }

  Future<void> _uploadFile(File file) async {
    final result = await ref.read(filesNotifierProvider.notifier).upload(file);
    if (result != null && mounted) {
      showSnackBar(context, message: 'File uploaded successfully');
    } else if (mounted) {
      showSnackBar(context, message: 'Failed to upload file', isError: true);
    }
  }

  void _showFilePreview(FileModel file) {
    final fileUrl = ref
        .read(filesNotifierProvider.notifier)
        .getFileUrl(file.path);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file.isImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: fileUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    height: 200,
                    child: Center(child: LoadingSpinner()),
                  ),
                  errorWidget: (context, url, error) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.error, size: 48)),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getFileIcon(file.iconType),
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${file.formattedSize} • ${Formatters.date(file.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (file.workOrder != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Work Order: ${file.workOrder!.woNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteFile(FileModel file) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete File',
      message: 'Are you sure you want to delete "${file.name}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      final success = await ref
          .read(filesNotifierProvider.notifier)
          .delete(file.id);
      if (success && mounted) {
        showSnackBar(context, message: 'File deleted');
      }
    }
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class _FileCard extends StatelessWidget {
  final FileModel file;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FileCard({
    required this.file,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: file.isImage
                ? Consumer(
                    builder: (context, ref, _) {
                      final fileUrl = ref
                          .read(filesNotifierProvider.notifier)
                          .getFileUrl(file.path);
                      return CachedNetworkImage(
                        imageUrl: fileUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(child: LoadingSpinner(size: 20)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(child: Icon(Icons.error)),
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.surfaceVariant,
                    child: Center(
                      child: Icon(
                        _getFileIcon(file.iconType),
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
          ),

          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(179)],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    file.formattedSize,
                    style: TextStyle(
                      color: Colors.white.withAlpha(179),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black.withAlpha(128),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }
}
