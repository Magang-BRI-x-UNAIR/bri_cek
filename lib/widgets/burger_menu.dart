import 'package:flutter/material.dart';
import 'package:bri_cek/screens/admin_dashboard_screen.dart';
import 'package:bri_cek/screens/manage_questions_screen.dart';
import 'package:bri_cek/screens/login_screen.dart';
import 'package:bri_cek/services/auth_service.dart';
import 'package:bri_cek/utils/app_size.dart';

class BurgerMenu extends StatefulWidget {
  final bool isAdmin;

  const BurgerMenu({super.key, required this.isAdmin});

  @override
  State<BurgerMenu> createState() => _BurgerMenuState();
}

class _BurgerMenuState extends State<BurgerMenu> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _menuButtonKey = GlobalKey();
  final AuthService _authService = AuthService();

  void _showBurgerMenu() {
    final RenderBox? renderBox =
        _menuButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildBurgerMenuOverlay(position, size),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideBurgerMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildBurgerMenuOverlay(Offset position, Size buttonSize) {
    return GestureDetector(
      onTap: _hideBurgerMenu,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              top: position.dy + buttonSize.height + AppSize.heightPercent(1),
              right:
                  MediaQuery.of(context).size.width -
                  position.dx -
                  buttonSize.width,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
                child: Container(
                  width: AppSize.widthPercent(55), // Responsive width
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppSize.cardBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: AppSize.heightPercent(1.2),
                        offset: Offset(0, AppSize.heightPercent(0.5)),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(AppSize.paddingHorizontal),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppSize.cardBorderRadius),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.isAdmin
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: Colors.white,
                              size: AppSize.iconSize,
                            ),
                            SizedBox(width: AppSize.widthPercent(2)),
                            Text(
                              widget.isAdmin ? 'Admin Menu' : 'User Menu',
                              style: AppSize.getTextStyle(
                                fontSize: AppSize.bodyFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menu items
                      if (widget.isAdmin) ...[
                        _buildMenuItem(
                          icon: Icons.people,
                          title: 'Manage Users',
                          onTap: () {
                            _hideBurgerMenu();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const AdminDashboardScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.quiz,
                          title: 'Manage Questions',
                          onTap: () {
                            _hideBurgerMenu();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ManageQuestionsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuDivider(),
                      ],

                      // Logout option (for both admin and user)
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        textColor: Colors.red.shade600,
                        iconColor: Colors.red.shade600,
                        onTap: () {
                          _hideBurgerMenu();
                          _showLogoutDialog();
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.cardBorderRadius * 0.7),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.paddingHorizontal,
          vertical: AppSize.paddingVertical * 0.8,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSize.iconSize,
              color: iconColor ?? Colors.grey.shade700,
            ),
            SizedBox(width: AppSize.widthPercent(3)),
            Expanded(
              child: Text(
                title,
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.grey.shade800,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: AppSize.smallIconSize,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: AppSize.paddingHorizontal),
      color: Colors.grey.shade200,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.red.shade600,
                size: AppSize.largeIconSize,
              ),
              SizedBox(width: AppSize.widthPercent(2)),
              Expanded(
                child: Text(
                  'Konfirmasi Logout',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.paddingHorizontal,
                  vertical: AppSize.paddingVertical * 0.7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSize.cardBorderRadius * 0.7,
                  ),
                ),
              ),
              child: Text(
                'Batal',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: AppSize.widthPercent(2)),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.paddingHorizontal,
                  vertical: AppSize.paddingVertical * 0.7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSize.cardBorderRadius * 0.7,
                  ),
                ),
                elevation: 2,
              ),
              child: Text(
                'Logout',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _hideBurgerMenu(); // Clean up overlay if it exists
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _menuButtonKey,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppSize.heightPercent(0.5),
            offset: Offset(0, AppSize.heightPercent(0.25)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showBurgerMenu,
          borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          child: Container(
            padding: EdgeInsets.all(AppSize.paddingVertical * 0.8),
            child: Icon(
              Icons.menu,
              color: Colors.white,
              size: AppSize.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
