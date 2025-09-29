import 'package:flutter/material.dart';

class StorageUsageWidget extends StatelessWidget {
  final double usedStorage; // 사용된 스토리지 (MB)
  final double totalStorage; // 전체 스토리지 (MB)
  final String? label;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final EdgeInsets padding;

  const StorageUsageWidget({
    super.key,
    required this.usedStorage,
    required this.totalStorage,
    this.label,
    this.progressColor,
    this.backgroundColor,
    this.height = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final usagePercentage = totalStorage > 0 ? usedStorage / totalStorage : 0.0;
    final theme = Theme.of(context);

    // 사용량에 따른 색상 결정
    final defaultProgressColor = _getProgressColor(usagePercentage, theme);
    final defaultBackgroundColor = theme.colorScheme.surfaceVariant.withOpacity(
      0.3,
    );

    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨과 사용량 텍스트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.storage_outlined, color: theme.colorScheme.onSurface),
              Text(
                label ?? 'storage usage',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${(usagePercentage * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: defaultProgressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 프로그레스 바
          Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              color: backgroundColor ?? defaultBackgroundColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: LinearProgressIndicator(
                value: usagePercentage,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? defaultProgressColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // 사용량 정보 텍스트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatBytes(usedStorage),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatBytes(totalStorage),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 사용량에 따른 색상 결정
  Color _getProgressColor(double percentage, ThemeData theme) {
    if (percentage >= 0.9) {
      return Colors.red; // 90% 이상 - 빨간색
    } else if (percentage >= 0.7) {
      return Colors.orange; // 70% 이상 - 주황색
    } else if (percentage >= 0.5) {
      return Colors.yellow.shade700; // 50% 이상 - 노란색
    } else {
      return theme.colorScheme.primary; // 50% 미만 - 기본 색상
    }
  }

  /// 바이트를 읽기 쉬운 형태로 포맷팅
  String _formatBytes(double bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(0)}MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)}KB';
    } else {
      return '${bytes.toStringAsFixed(0)}B';
    }
  }
}

/// 애니메이션이 있는 스토리지 사용량 위젯
class AnimatedStorageUsageWidget extends StatefulWidget {
  final double usedStorage;
  final double totalStorage;
  final String? label;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final EdgeInsets padding;
  final Duration animationDuration;

  const AnimatedStorageUsageWidget({
    super.key,
    required this.usedStorage,
    required this.totalStorage,
    this.label,
    this.progressColor,
    this.backgroundColor,
    this.height = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedStorageUsageWidget> createState() =>
      _AnimatedStorageUsageWidgetState();
}

class _AnimatedStorageUsageWidgetState extends State<AnimatedStorageUsageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation =
        Tween<double>(
          begin: 0.0,
          end: widget.totalStorage > 0
              ? widget.usedStorage / widget.totalStorage
              : 0.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedStorageUsageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.usedStorage != widget.usedStorage ||
        oldWidget.totalStorage != widget.totalStorage) {
      _animation =
          Tween<double>(
            begin: _animation.value,
            end: widget.totalStorage > 0
                ? widget.usedStorage / widget.totalStorage
                : 0.0,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return StorageUsageWidget(
          usedStorage: widget.usedStorage,
          totalStorage: widget.totalStorage,
          label: widget.label,
          progressColor: widget.progressColor,
          backgroundColor: widget.backgroundColor,
          height: widget.height,
          padding: widget.padding,
        );
      },
    );
  }
}
