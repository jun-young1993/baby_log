import 'package:baby_log/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/state/user_group/user_group_selector.dart';
import 'package:flutter_common/widgets/error_view.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_common/state/user_group/user_group_bloc.dart';
import 'package:flutter_common/state/user_group/user_group_event.dart';
import 'package:flutter_common/flutter_common.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  UserBloc get userBloc => context.read<UserBloc>();
  UserGroupBloc get userGroupBloc => context.read<UserGroupBloc>();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    userBloc.add(UserEvent.initialize());
    userGroupBloc.add(UserGroupEvent.findAll());
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
          return UserGroupFindSelector((userGroup) {
            return UserInfoSelector((user) {
              if (userGroup != null && user != null) {
                return DashboardPage(user: user);
              }
              return _buildBody();
            });
          });
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
                child: Text(Tr.common.skip.tr()),
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
            children: [
              _OnboardingStep(
                icon: Icons.photo_camera,
                title: Tr.baby.onBoardingTitle.tr(),
                description: Tr.baby.onBoardingDescription.tr(),
              ),
              _OnboardingStep(
                icon: Icons.auto_awesome,
                title: Tr.baby.aiDescription.tr(),
                description: Tr.baby.aiDescription.tr(),
              ),
              _OnboardingStep(
                icon: Icons.family_restroom,
                title: Tr.baby.shareDescription.tr(),
                description: Tr.baby.shareDescription.tr(),
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
                        child: Text(Tr.common.previous.tr()),
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
                      child: Text(
                        _currentPage < 2
                            ? Tr.common.next.tr()
                            : Tr.common.start.tr(),
                      ),
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
