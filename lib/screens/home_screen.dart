import 'package:bri_cek/screens/choose_bank_screen.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:bri_cek/widgets/burger_menu.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/user_model.dart';
import 'package:bri_cek/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;

  const HomeScreen({super.key, this.isAdmin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Configure animations
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeInOut,
    );

    // Fetch user data and then start animations
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getUserData();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
      // Start animations after user data is loaded
      _startAnimationsSequentially();
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
      // Start animations even if there's an error
      _startAnimationsSequentially();
    }
  }

  void _startAnimationsSequentially() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildInfoSection(),
                  _buildAssessmentAspects(),
                  _buildUsageInstructions(),
                  SizedBox(
                    height: AppSize.heightPercent(10),
                  ), // Add extra space at bottom for sheet
                ],
              ),
            ),
            _buildSwipeableBottomSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeableBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.08, // Increased from 0.05
      minChildSize: 0.08, // Increased from 0.05
      maxChildSize: 0.3, // Increased from 0.25
      snap: true,
      snapSizes: [0.08, 0.3], // Define snap points
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.blue.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 60, // Fixed height for header
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: AppSize.widthPercent(15),
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Text
                      Text(
                        "Swipe untuk melakukan penilaian",
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.smallFontSize,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.paddingHorizontal,
                  vertical: 16,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Row with image and text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Container(
                            width: AppSize.widthPercent(32),
                            height: AppSize.heightPercent(15),
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/assess_bank_person.png',
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSize.widthPercent(4)),
                          // Penilaian text and button
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: AppSize.heightPercent(1)),
                                Text(
                                  'Beri Penilaian Kantor Kas',
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.bodyFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const ChooseBankScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppSize.heightPercent(1),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF00529C),
                                          Color(0xFF0086FF),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSize.widthPercent(3),
                                        vertical: AppSize.heightPercent(1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Mulai',
                                            style: AppSize.getTextStyle(
                                              fontSize: AppSize.bodyFontSize,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            width: AppSize.widthPercent(18),
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Add extra content
                      SizedBox(height: AppSize.heightPercent(2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            (1 - _headerAnimation.value) * -AppSize.heightPercent(6),
          ),
          child: Opacity(opacity: _headerAnimation.value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        height: AppSize.heightPercent(22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF2680C5), Color(0xFF3D91D1), Color(0xFFF37021)],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Stack(
          children: [
            // Cloud decorations
            Positioned(
              top: AppSize.heightPercent(15),
              left: AppSize.widthPercent(6),
              child: Icon(
                Icons.cloud,
                color: Colors.white.withOpacity(0.3),
                size: AppSize.widthPercent(13),
              ),
            ),
            Positioned(
              top: AppSize.heightPercent(3),
              left: AppSize.widthPercent(42),
              child: Icon(
                Icons.cloud,
                color: Colors.white.withOpacity(0.2),
                size: AppSize.widthPercent(12),
              ),
            ),
            Positioned(
              top: AppSize.heightPercent(10),
              left: AppSize.widthPercent(89),
              child: Icon(
                Icons.cloud,
                color: Colors.white.withOpacity(0.2),
                size: AppSize.widthPercent(15),
              ),
            ),

            // Burger menu button
            Positioned(
              top: AppSize.heightPercent(2),
              left: AppSize.widthPercent(4),
              child: Container(
                width: 50,
                height: 50,
                child: BurgerMenu(isAdmin: widget.isAdmin),
              ),
            ),

            // Greeting text
            Positioned(
              top: AppSize.heightPercent(9),
              left: AppSize.widthPercent(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isLoading
                        ? (widget.isAdmin == true ? 'Admin' : 'User')
                        : (widget.isAdmin == true
                            ? 'Admin BRI'
                            : _getFirstName(_currentUser?.fullName)),
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Bank icon - adjust position untuk memberikan ruang lebih
            Positioned(
              right: AppSize.widthPercent(4),
              top: AppSize.heightPercent(2), // Naikkan sedikit
              child: Container(
                width: AppSize.widthPercent(50), // Perbesar width
                height: AppSize.heightPercent(20), // Perbesar height
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bank_transparent.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Female character
            Positioned(
              right: AppSize.widthPercent(1),
              top: AppSize.heightPercent(6),
              child: Container(
                width: AppSize.widthPercent(35), // Perbesar dari 27% ke 40%
                height: AppSize.heightPercent(18), // Perbesar dari 15% ke 18%
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/images/female_character.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Male Characters - PERBESAR UKURAN
            Positioned(
              right: AppSize.widthPercent(21), // Adjust position
              top: AppSize.heightPercent(4),
              child: Container(
                width: AppSize.widthPercent(37), // Perbesar dari 25% ke 35%
                height: AppSize.heightPercent(19), // Perbesar dari 15% ke 18%
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/images/male_character.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(opacity: _contentAnimation.value, child: child);
      },
      child: Padding(
        padding: EdgeInsets.all(AppSize.paddingHorizontal),
        child: Text(
          'Aplikasi ini adalah solusi inovatif untuk meningkatkan kemudahan penilaian layanan yang terstruktur dan mudah digunakan. Aplikasi ini digunakan untuk membantu memberikan evaluasi terhadap kinerja layanan, khususnya pada 4 kantor kas yang ada di Surabaya.',
          style: AppSize.getTextStyle(
            fontSize: AppSize.bodyFontSize,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentAspects() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(opacity: _contentAnimation.value, child: child);
      },
      child: Padding(
        padding: EdgeInsets.all(AppSize.paddingHorizontal),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // First, place the container with assessment items
            Padding(
              padding: EdgeInsets.only(top: AppSize.heightPercent(2)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.paddingHorizontal / 2,
                  vertical: AppSize.paddingVertical,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    // First row with 4 categories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAssessmentItem(Icons.security, 'Satpam'),
                        _buildAssessmentItem(Icons.account_balance, 'Teller'),
                        _buildAssessmentItem(Icons.support_agent, 'CS'),
                        _buildAssessmentItem(Icons.business, 'Banking Hall'),
                      ],
                    ),
                    // Second row with 4 categories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAssessmentItem(
                          Icons.computer,
                          'Gallery E-Channel',
                        ),
                        _buildAssessmentItem(
                          Icons.meeting_room,
                          'Ruang Brimen',
                        ),
                        _buildAssessmentItem(Icons.apartment, 'Fasad Gedung'),
                        _buildAssessmentItem(Icons.wc, 'Toilet'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Then, position the "Aspek penilaian" container to overlap
            Positioned(
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppSize.paddingVertical / 2,
                  horizontal: AppSize.paddingHorizontal * 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(
                    AppSize.cardBorderRadius / 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.blue.shade100, width: 1.5),
                ),
                child: Text(
                  'Kategori Penilaian',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.subtitleFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentItem(IconData icon, String label) {
    return Container(
      width: AppSize.widthPercent(20), // Adjusted width for 4 items per row
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add padding at the top of the column
          SizedBox(height: AppSize.heightPercent(2)),

          // Icon container
          Container(
            padding: EdgeInsets.all(AppSize.widthPercent(2.5)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Icon(
              icon,
              color: Colors.orange,
              size: AppSize.iconSize * 0.9,
            ),
          ),

          SizedBox(height: AppSize.heightPercent(0.8)),

          // Text container with top alignment
          Container(
            height: AppSize.heightPercent(
              4,
            ), // Fixed height for consistent layout
            width: double.infinity,
            child: Align(
              alignment: Alignment.topCenter, // Align text to top-center
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppSize.getTextStyle(
                  fontSize:
                      AppSize.smallFontSize * 0.85, // Slightly smaller text
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInstructions() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(opacity: _contentAnimation.value, child: child);
      },
      child: Padding(
        padding: EdgeInsets.all(AppSize.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alur Penggunaan Aplikasi',
              style: AppSize.getTextStyle(
                fontSize: AppSize.subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: AppSize.heightPercent(1)),
            _buildInstructionStep(
              '1',
              'Pada button',
              'Anda dapat geser keatas.',
            ),
            _buildInstructionStep(
              '2',
              'Lalu Anda dapat klik "Mulai"',
              'untuk menjalankan fitur tersebut',
            ),
            _buildInstructionStep(
              '3',
              'Untuk melakukan penilaian, Anda dapat',
              'memilih kantor untuk melakukan penilaian.',
            ),
            _buildInstructionStep(
              '4',
              'Setelah itu pilih aspek dan terdapat nama yang menjabat di divisi tersebut, Anda dapat',
              'memilihnya untuk penilaian.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String? subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSize.heightPercent(1.5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.widthPercent(5),
            child: Text(
              '$number.',
              style: AppSize.getTextStyle(
                fontSize: AppSize.bodyFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.bodyFontSize,
                          color: Colors.black87,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    if (number == '1') ...[
                      SizedBox(width: AppSize.widthPercent(2)),
                      Container(
                        width: AppSize.widthPercent(8),
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  subtitle ?? '',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    color: Colors.black87,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add this helper method to extract the first name
String _getFirstName(String? fullName) {
  if (fullName == null || fullName.isEmpty) {
    return 'User';
  }

  // Split the full name by spaces and get the first word
  final nameParts = fullName.trim().split(' ');
  if (nameParts.isEmpty) {
    return 'User';
  }

  // Return the first word of the full name
  return nameParts[0];
}
