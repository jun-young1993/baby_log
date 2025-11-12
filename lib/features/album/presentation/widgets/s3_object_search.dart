import 'package:flutter/material.dart';
import 'package:flutter_common/extensions/app_exception.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/aws/s3/s3_object_tag.dart';
import 'package:flutter_common/widgets/error_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Reusable bottom sheet for searching and selecting S3ObjectTag
class S3ObjectSearch extends StatefulWidget {
  final List<S3ObjectTag> emotionTags;
  final ValueChanged<S3ObjectTag>? onSelected;
  final ValueChanged<List<S3ObjectTag>>? onConfirm;
  final String? title;
  final String? initialQuery;
  final bool isLoading;
  final List<S3ObjectTag>? initialSelected;

  const S3ObjectSearch({
    super.key,
    required this.emotionTags,
    this.onSelected,
    this.onConfirm,
    this.title,
    this.initialQuery,
    this.isLoading = false,
    this.initialSelected,
  });

  @override
  State<S3ObjectSearch> createState() => _S3ObjectSearchState();
}

class _S3ObjectSearchState extends State<S3ObjectSearch> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery ?? '',
  );
  String _query = '';
  late final Set<String> _selectedNames = {
    ...(widget.initialSelected?.map((e) => e.name) ?? const Iterable.empty()),
  };

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.emotionTags
        .where((t) => t.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title ?? Tr.common.search.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.onConfirm != null)
                    TextButton(
                      onPressed: _selectedNames.isEmpty
                          ? null
                          : () {
                              final selected = widget.emotionTags
                                  .where((t) => _selectedNames.contains(t.name))
                                  .toList(growable: false);
                              widget.onConfirm?.call(selected);
                              Navigator.of(context).maybePop();
                            },
                      child: Text(Tr.app.confirm.tr()),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: Tr.common.inputSearchKeyword.tr(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.isLoading
                    ? Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24,
                        ),
                      )
                    : filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 32,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 36,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Tr.common.noSearchResult.tr(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final tag in filtered)
                              _EmotionChip(
                                tag: tag,
                                selected: _selectedNames.contains(tag.name),
                                onTap: () {
                                  if (widget.onConfirm == null) {
                                    widget.onSelected?.call(tag);
                                    Navigator.of(context).maybePop();
                                    return;
                                  }
                                  setState(() {
                                    final key = tag.name;
                                    if (_selectedNames.contains(key)) {
                                      _selectedNames.remove(key);
                                    } else {
                                      _selectedNames.add(key);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  final S3ObjectTag tag;
  final bool selected;
  final VoidCallback onTap;
  const _EmotionChip({
    required this.tag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color base = tag.emotionColorValue;
    final Color bg = selected ? base : base.withOpacity(0.12);
    final Color fg = selected ? Colors.white : base;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: base.withOpacity(0.7), width: 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: base.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tag.icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              tag.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_rounded, size: 16, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showS3ObjectSearchBottomSheet({
  required BuildContext context,
  required List<S3ObjectTag> emotionTags,
  ValueChanged<S3ObjectTag>? onSelected,
  ValueChanged<List<S3ObjectTag>>? onConfirm,
  List<S3ObjectTag>? initialSelected,
  String? title,
  String? initialQuery,
  bool isLoading = false,
  AppException? error,
  VoidCallback? onRetry,
}) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          if (error != null) {
            return ErrorView(error: error, onRetry: onRetry);
          }
          return S3ObjectSearch(
            isLoading: isLoading,
            emotionTags: emotionTags,
            onSelected: onSelected,
            onConfirm: onConfirm,
            title: title,
            initialQuery: initialQuery,
          );
        },
      );
    },
  );
}
