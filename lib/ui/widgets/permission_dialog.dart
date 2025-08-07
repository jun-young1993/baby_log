import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String description;
  final String permissionType;
  final VoidCallback? onGranted;
  final VoidCallback? onDenied;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.permissionType,
    this.onGranted,
    this.onDenied,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            _getIconForPermission(permissionType),
            color: Colors.blue[600],
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '이 권한은 아기의 감정을 분석하기 위해 필요합니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDenied?.call();
          },
          child: const Text(
            '나중에',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            
            // 권한 요청
            final status = await Permission.camera.request();
            
            if (status.isGranted) {
              onGranted?.call();
            } else {
              // 권한이 거부된 경우 설정으로 이동하는 다이얼로그 표시
              if (context.mounted) {
                _showSettingsDialog(context);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('권한 허용'),
        ),
      ],
    );
  }

  IconData _getIconForPermission(String permissionType) {
    switch (permissionType) {
      case 'camera':
        return Icons.camera_alt;
      case 'microphone':
        return Icons.mic;
      case 'storage':
        return Icons.folder;
      default:
        return Icons.security;
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한이 필요합니다'),
        content: const Text(
          '카메라 권한이 거부되었습니다. 앱 설정에서 권한을 허용해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }
} 