import 'package:flutter/material.dart';
import '../../../../core/widgets/storage_usage_widget.dart';

class StorageUsageDemoPage extends StatefulWidget {
  const StorageUsageDemoPage({super.key});

  @override
  State<StorageUsageDemoPage> createState() => _StorageUsageDemoPageState();
}

class _StorageUsageDemoPageState extends State<StorageUsageDemoPage> {
  double _usedStorage = 200; // 200MB
  double _totalStorage = 1000; // 1GB

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스토리지 사용량 위젯 데모'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 위젯
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기본 스토리지 사용량 위젯',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StorageUsageWidget(
                      usedStorage: _usedStorage,
                      totalStorage: _totalStorage,
                      label: '앱 스토리지',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 애니메이션 위젯
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '애니메이션 스토리지 사용량 위젯',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedStorageUsageWidget(
                      usedStorage: _usedStorage,
                      totalStorage: _totalStorage,
                      label: '앱 스토리지 (애니메이션)',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 다양한 사용량 예제
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '다양한 사용량 예제',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 낮은 사용량 (20%)
                    StorageUsageWidget(
                      usedStorage: 200,
                      totalStorage: 1000,
                      label: '낮은 사용량 (20%)',
                    ),
                    const SizedBox(height: 12),

                    // 중간 사용량 (60%)
                    StorageUsageWidget(
                      usedStorage: 600,
                      totalStorage: 1000,
                      label: '중간 사용량 (60%)',
                    ),
                    const SizedBox(height: 12),

                    // 높은 사용량 (85%)
                    StorageUsageWidget(
                      usedStorage: 850,
                      totalStorage: 1000,
                      label: '높은 사용량 (85%)',
                    ),
                    const SizedBox(height: 12),

                    // 매우 높은 사용량 (95%)
                    StorageUsageWidget(
                      usedStorage: 950,
                      totalStorage: 1000,
                      label: '매우 높은 사용량 (95%)',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 사용량 조절 슬라이더
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사용량 조절',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('사용된 스토리지: ${_usedStorage.toStringAsFixed(0)}MB'),
                    Slider(
                      value: _usedStorage,
                      min: 0,
                      max: _totalStorage,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() {
                          _usedStorage = value;
                        });
                      },
                    ),
                    Text('전체 스토리지: ${_totalStorage.toStringAsFixed(0)}MB'),
                    Slider(
                      value: _totalStorage,
                      min: 500,
                      max: 2000,
                      divisions: 15,
                      onChanged: (value) {
                        setState(() {
                          _totalStorage = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
