import 'package:flutter/material.dart';
import 'package:lets_chat/core/constants.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLogout;

  const ChatAppBar({
    Key? key,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: kPrimaryColor,
      shadowColor: kPrimaryColor.withValues(alpha: .5),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            kLogo,
            height: 45,
          ),
          const Text(
            appName,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Lobster',
            ),
          ),
        ],
      ),
      actions: [
        if (onLogout != null)
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogout,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
