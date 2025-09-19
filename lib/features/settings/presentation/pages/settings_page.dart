import 'package:flutter/material.dart';

import 'package:flutter_common/flutter_common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserBloc get userBloc => context.read<UserBloc>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tr.app.settings.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SettingScreenLayout(
        appKey: AppKeys.loanCountdown,
        onUserDeleted: (user) {
          userBloc.add(UserEvent.deleteUserData(user));
        },
      ),
    );
  }
}
