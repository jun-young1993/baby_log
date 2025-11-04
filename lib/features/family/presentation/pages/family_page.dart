import 'dart:io';

import 'package:baby_log/features/family/presentation/pages/widgets/join_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/user_group/user_group.dart';
import 'package:flutter_common/state/user_group/user_group_bloc.dart';
import 'package:flutter_common/state/user_group/user_group_event.dart';
import 'package:flutter_common/state/user_group/user_group_selector.dart';
import 'package:flutter_common/widgets/error_view.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  UserGroupBloc get userGroupBloc => context.read<UserGroupBloc>();
  UserBloc get userBloc => context.read<UserBloc>();
  AppConfigBloc get appConfigBloc => context.read<AppConfigBloc>();

  @override
  void initState() {
    super.initState();
    userBloc.add(UserEvent.clearError());
    userBloc.add(UserEvent.initialize());
    userBloc.stream.listen((state) {
      if (state.user != null) {
        userGroupBloc.add(UserGroupEvent.findAll());
        appConfigBloc.add(AppConfigEvent.initialize(AppKeys.babyLog, null));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _shareInviteCodeWithPosition(
    BuildContext context,
    String inviteCode,
    String storeUrl,
  ) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final Offset position = box != null
        ? box.localToGlobal(Offset.zero)
        : const Offset(0, 0);
    final Size size = box?.size ?? const Size(0, 0);

    Share.share(
      '${Tr.family.familyJoinCodeDescription4.tr(namedArgs: {'code': inviteCode})}\n\n${Tr.family.familyJoinCodeDescription5.tr()}\n\n$storeUrl',
      subject: Tr.family.familyJoinCodeDescription5.tr(),
      sharePositionOrigin: Platform.isIOS
          ? Rect.fromLTWH(position.dx, position.dy, size.width, size.height)
          : null,
    );
  }

  void _showJoinCodeDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinCodePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tr.family.familyShare.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: UserGroupErrorSelector((error) {
          debugPrint('family page error: $error');
          if (error != null) {
            return ErrorView(
              error: error,
              onRetry: () {
                userGroupBloc.add(UserGroupEvent.clearError());
                userGroupBloc.add(UserGroupEvent.findAll());
              },
            );
          }
          return UserGroupFindSelector((userGroup) {
            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // 헤더 섹션
                  _buildGroupHeader(context, userGroup),
                  const SizedBox(height: 20),
                  // 선택 옵션들
                  _buildGroupBody(context, userGroup),
                ],
              ),
            );
          });
        }),
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, UserGroup? userGroup) {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width < 400 ? 16 : 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 400 ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.family_restroom,
              size: MediaQuery.of(context).size.width < 400 ? 36 : 48,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width < 400 ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  userGroup == null
                      ? Tr.family.familyWithPreciousMoments.tr()
                      : userGroup.name ?? 'no name',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
              if (userGroup != null) const Spacer(),
              if (userGroup != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    InputDialog.show(
                      title: Tr.family.familyGroupName.tr(),
                      hintText: Tr.family.familyGroupNameHintText.tr(),
                      initialValue: userGroup.name ?? '',
                      onConfirm: (value) {
                        userGroupBloc.add(UserGroupEvent.updateName(value));
                      },
                      context: context,
                    );
                  },
                  color: Colors.grey,
                  iconSize: 20,
                ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  userGroup == null
                      ? Tr.family.familyShareDescription2.tr()
                      : userGroup.description ?? 'no description',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: MediaQuery.of(context).size.width < 400 ? 12 : 14,
                  ),
                ),
              ),
              if (userGroup != null) const Spacer(),
              if (userGroup != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    InputDialog.show(
                      title: Tr.family.familyShareDescription3.tr(),
                      hintText: Tr.family.familyShareDescription3HintText.tr(),
                      initialValue: userGroup.description ?? '',
                      onConfirm: (value) {
                        userGroupBloc.add(
                          UserGroupEvent.updateDescription(value),
                        );
                      },
                      context: context,
                    );
                  },
                  color: Colors.grey,
                  iconSize: 18,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (userGroup != null)
            Text(
              Tr.family.inviteCode.tr(),
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
          if (userGroup != null)
            JoinCodeField(
              codes: userGroup.number.toString().split(''),
              isReadOnly: true,
            ),
        ],
      ),
    );
  }

  Widget _buildGroupBody(BuildContext context, UserGroup? userGroup) {
    if (userGroup == null) {
      return Column(
        children: [
          Text(
            Tr.family.familyStartDescription.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          // 초대 코드 만들기
          _buildOptionCard(
            context: context,
            icon: Icons.group_add,
            title: Tr.family.familyCodeCreate.tr(),
            subtitle: Tr.family.familyCodeCreateDescription.tr(),
            onTap: () {
              userGroupBloc.add(UserGroupEvent.create(null, null));
            },
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          // 초대 코드 입력하기
          _buildOptionCard(
            context: context,
            icon: Icons.group,
            title: Tr.family.familyCodeCreateDescription2.tr(),
            subtitle: Tr.family.familyCodeCreateDescription3.tr(),
            onTap: () => _showJoinCodeDialog(context),
            isPrimary: false,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          RemoteAppConfigSelector((appConfig) {
            return Builder(
              builder: (buttonContext) => ElevatedButton.icon(
                onPressed: () => _shareInviteCodeWithPosition(
                  buttonContext,
                  userGroup.number.toString(),
                  appConfig?.redirectUrl ?? '',
                ),
                icon: const Icon(Icons.share),
                label: Text(Tr.family.familyCodeShare.tr()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          // 가족 멤버 리스트
          _buildFamilyMembersList(context, userGroup),
          const SizedBox(height: 20),
        ],
      );
    }
  }

  Widget _buildFamilyMembersList(BuildContext context, UserGroup userGroup) {
    // 임시 멤버 데이터 (실제로는 userGroup에서 가져와야 함)
    final List<User> members = userGroup.users ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                Tr.family.familyMemberCountFormat.tr(
                  namedArgs: {'count': members.length.toString()},
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...members.map((member) => _buildMemberItem(context, member)),
        ],
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context, User member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              member.isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // 이름과 역할
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.username ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.isAdmin
                      ? Tr.common.groupLeader.tr()
                      : Tr.common.member.tr(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // 상태 표시 (온라인/오프라인)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                // const SizedBox(width: 4),
                // Text(
                //   '온라인',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.green[700],
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPrimary
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// 초대 코드 입력 페이지
class JoinCodePage extends StatefulWidget {
  const JoinCodePage({super.key});

  @override
  State<JoinCodePage> createState() => _JoinCodePageState();
}

class _JoinCodePageState extends State<JoinCodePage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<String> _code = List.filled(6, '');

  UserGroupBloc get userGroupBloc => context.read<UserGroupBloc>();

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    setState(() {
      _code[index] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.family.familyJoin.tr()), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // 헤더
            Container(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 400 ? 20 : 32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width < 400 ? 16 : 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.group,
                      size: MediaQuery.of(context).size.width < 400 ? 48 : 60,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 400 ? 16 : 20,
                  ),
                  Text(
                    Tr.family.familyJoinCode.tr(),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 400
                          ? 20
                          : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Tr.family.familyJoinCodeDescription.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: MediaQuery.of(context).size.width < 400
                          ? 14
                          : 16,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // 코드 입력 필드들
            JoinCodeField(
              codes: _code,
              controllers: _controllers,
              focusNodes: _focusNodes,
              onChanged: _onCodeChanged,
              onSubmitted: (value, index) {
                if (value.isNotEmpty && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                }
              },
            ),
            const SizedBox(height: 40),
            // 참여하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _code.join('').length == 6
                    ? () {
                        // 가족 그룹 참여 로직
                        userGroupBloc.add(
                          UserGroupEvent.addUserByNumber(_code.join('')),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              Tr.family.familyJoinCodeDescription2.tr(
                                namedArgs: {'code': _code.join('')},
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _code.join('').length == 6
                      ? Colors.blue
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  Tr.family.familyJoin.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 도움말
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Tr.family.familyJoinCodeDescription3.tr(),
                      style: TextStyle(color: Colors.orange, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
