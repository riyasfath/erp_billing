import 'package:flutter/material.dart';
import 'package:pokakbilling/views/Screens/inbox/inbox.dart';
import 'package:pokakbilling/views/Screens/inbox/inbox_home.dart'; // ✅ renamed

class SentScreen extends StatelessWidget {
  const SentScreen({super.key});

  static const Color topBarColor = Color(0xFF2B2AA8);

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color iconColor = selected ? topBarColor : Colors.black87;
    final Color textColor = selected ? topBarColor : Colors.black45;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _centerSentButton() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: topBarColor, width: 2),
        boxShadow: const [
          BoxShadow(
              blurRadius: 12, offset: Offset(0, 6), color: Color(0x33000000))
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration:
            const BoxDecoration(color: topBarColor, shape: BoxShape.circle),
        child: const Center(
            child: Icon(Icons.send_outlined, color: Colors.white, size: 26)),
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 90,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: 18,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 10,
                        offset: Offset(0, -2),
                        color: Color(0x14000000))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // INBOX
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _navItem(
                          icon: Icons.inbox_outlined,
                          label: 'Inbox',
                          selected: false,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const InboxScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 92),
                    // HOME
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _navItem(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          selected: false,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const InboxHomeScreen()), // ✅
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Center button (selected)
            Positioned.fill(
                child: Align(
                    alignment: Alignment.topCenter,
                    child: _centerSentButton())),
            const Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Text('Sent',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: topBarColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sent'),
        backgroundColor: topBarColor,
      ),
      bottomNavigationBar: _bottomBar(context),
      body: const Center(
        child: Text('Sent Messages Page'),
      ),
    );
  }
}
