import 'package:flutter/material.dart';
import 'package:flutter_common/widgets/error_view.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_common/flutter_common.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  UserBloc get userBloc => context.read<UserBloc>();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    userBloc.add(UserEvent.initialize());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: UserErrorSelector((userError) {
          if (userError != null) {
            return ErrorView(
              error: userError,
              onRetry: () {
                userBloc.add(UserEvent.clearError());
                userBloc.add(UserEvent.initialize());
              },
            );
          }
          return _buildBody();
        }),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Skip button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  context.go('/dashboard');
                },
                child: const Text('건너뛰기'),
              ),
            ],
          ),
        ),

        // Page view
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              _OnboardingStep(
                icon: Icons.photo_camera,
                title: '아기의 소중한 순간을 기록하세요',
                description: '매일매일의 특별한 순간들을 사진으로 남겨보세요.',
              ),
              _OnboardingStep(
                icon: Icons.auto_awesome,
                title: 'AI가 자동으로 의미있는 순간을 찾아드려요',
                description: '인공지능이 감정과 첫 순간들을 자동으로 분석합니다.',
              ),
              _OnboardingStep(
                icon: Icons.family_restroom,
                title: '가족과 함께 소중한 추억을 공유하세요',
                description: '안전하게 가족 구성원들과 사진을 공유할 수 있습니다.',
              ),
            ],
          ),
        ),

        // Page indicator and navigation
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Navigation buttons
              Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('이전'),
                      ),
                    ),

                  if (_currentPage > 0) const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < 2) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go('/dashboard');
                        }
                      },
                      child: Text(_currentPage < 2 ? '다음' : '시작하기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
