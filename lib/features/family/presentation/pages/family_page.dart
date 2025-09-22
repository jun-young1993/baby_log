import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/models/user_group/user_group.dart';
import 'package:flutter_common/state/user_group/user_group_bloc.dart';
import 'package:flutter_common/state/user_group/user_group_event.dart';
import 'package:flutter_common/state/user_group/user_group_selector.dart';
import 'package:flutter_common/widgets/error_view.dart';
import 'package:flutter_common/widgets/fields/card_field.dart';
import 'package:share_plus/share_plus.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  UserGroupBloc get userGroupBloc => context.read<UserGroupBloc>();

  @override
  void initState() {
    super.initState();
    userGroupBloc.add(UserGroupEvent.findAll());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _shareInviteCode(String inviteCode) {
    Share.share(
      'Baby Log 가족 그룹에 초대합니다!\n\n초대 코드: $inviteCode\n\nBaby Log 앱에서 위 코드를 입력하여 가족 그룹에 참여하세요.',
      subject: 'Baby Log 가족 그룹 초대',
    );
  }

  void _showInviteCodeDialog(BuildContext context, String inviteCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('초대 코드'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                inviteCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('이 코드를 가족들에게 공유해주세요'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareInviteCode(inviteCode);
            },
            child: const Text('공유하기'),
          ),
        ],
      ),
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
        title: const Text('가족 공유'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: UserGroupErrorSelector((error) {
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
                      ? '가족과 함께하는\n소중한 순간들'
                      : '${userGroup.name ?? 'no name'}',
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
                      title: '가족 그룹 이름',
                      hintText: '가족 그룹 이름을 입력해주세요.',
                      initialValue: userGroup?.name ?? '',
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
                      ? '가족 그룹을 만들어 아기의 성장을 함께 기록해보세요'
                      : '${userGroup.description ?? 'no description'}',
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
                      title: '가족 그룹 설명',
                      hintText: '가족 그룹 설명을 입력해주세요.',
                      initialValue: userGroup?.description ?? '',
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
              '초대 코드',
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
          const Text(
            '어떤 방법으로 시작하시겠어요?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          // 초대 코드 만들기
          _buildOptionCard(
            context: context,
            icon: Icons.group_add,
            title: '초대 코드 만들기',
            subtitle: '사진을 올리는 사람이에요\n가족 그룹을 만들고 초대해주세요',
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
            title: '초대 코드가 있어요',
            subtitle: '가족 그룹에 입장할래요\n초대 코드를 입력해주세요',
            onTap: () => _showJoinCodeDialog(context),
            isPrimary: false,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _shareInviteCode(userGroup.number.toString()),
            icon: const Icon(Icons.share),
            label: const Text('초대 코드 공유하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
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
                '가족 멤버 (${members.length}명)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...members
              .map((member) => _buildMemberItem(context, member))
              .toList(),
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
                  member.isAdmin ? '그룹장' : '멤버',
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
                const SizedBox(width: 4),
                Text(
                  '온라인',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('가족 그룹 참여'), centerTitle: true),
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
                    '초대 코드 입력',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 400
                          ? 20
                          : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '가족이 공유한 6자리 초대 코드를\n입력해주세요',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '초대 코드: ${_code.join('')}로 가족 그룹에 참여합니다',
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
                child: const Text(
                  '가족 그룹 참여하기',
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
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '초대 코드를 받지 못했나요? 가족에게 Baby Log 앱에서 초대 코드를 요청해보세요.',
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

class JoinCodeField extends StatelessWidget {
  List<String> codes;
  List<TextEditingController>? controllers;
  List<FocusNode>? focusNodes;
  Function(String, int)? onChanged;
  Function(String, int)? onSubmitted;
  bool isReadOnly = false;
  JoinCodeField({
    super.key,
    required this.codes,
    this.controllers,
    this.focusNodes,
    this.onChanged,
    this.onSubmitted,
    this.isReadOnly = false,
  });

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(codes.length, (index) {
        final isSmallScreen = MediaQuery.of(context).size.width < 400;

        return Container(
          width: isSmallScreen ? 32 : 36,
          height: isSmallScreen ? 40 : 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: codes[index].isNotEmpty
                  ? Colors.blue
                  : Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
            color: codes[index].isNotEmpty
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
          ),
          child: TextField(
            controller: isReadOnly ? null : controllers?[index],
            focusNode: isReadOnly ? null : focusNodes?[index],
            decoration: isReadOnly
                ? InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 8 : 10,
                      horizontal: 4,
                    ),
                    hintText: isReadOnly
                        ? codes[index]
                        : null, // ReadOnly일 때만 코드 표시
                    hintStyle: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // 진한 색상으로 명확하게 표시
                      height: 1.0,
                    ),
                  )
                : InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 8 : 10,
                      horizontal: 4,
                    ),
                  ),
            textAlign: TextAlign.center,
            readOnly: isReadOnly,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
            keyboardType: TextInputType.text,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            onChanged: (value) => onChanged?.call(value, index),
            onSubmitted: (value) {
              if (value.isNotEmpty && index < 5) {
                focusNodes?[index + 1].requestFocus();
              }
            },
            onTap: () {
              if (codes[index].isEmpty) {
                controllers?[index].selection = TextSelection.fromPosition(
                  TextPosition(offset: controllers?[index].text.length ?? 0),
                );
              }
            },
          ),
        );
      }),
    );
  }
}
