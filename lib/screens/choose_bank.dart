import 'package:flutter/material.dart';
import 'package:bri_cek/data/bank_branch_data.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:bri_cek/widgets/bank_branch_card.dart';

class ChooseBankScreen extends StatefulWidget {
  const ChooseBankScreen({super.key});

  @override
  State<ChooseBankScreen> createState() => _ChooseBankScreenState();
}

class _ChooseBankScreenState extends State<ChooseBankScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  List<BankBranch> _filteredBranches = [];
  final bool _isSearchFocused = false;

  // Controller untuk animasi
  late AnimationController _headerAnimationController;
  late AnimationController _searchBarAnimationController;
  late AnimationController _listAnimationController;

  late Animation<double> _headerAnimation;
  late Animation<double> _searchBarAnimation;

  @override
  void initState() {
    super.initState();
    _filteredBranches = branches;
    _searchController.addListener(_filterBranches);

    // Inisialisasi controller animasi
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _searchBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Konfigurasi animasi
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    );

    _searchBarAnimation = CurvedAnimation(
      parent: _searchBarAnimationController,
      curve: Curves.easeInOut,
    );

    // Mulai animasi dengan jeda bertahap
    _startAnimationsSequentially();
  }

  void _startAnimationsSequentially() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _searchBarAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _listAnimationController.forward();
  }

  void _filterBranches() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = branches;
      } else {
        _filteredBranches = branches.where((branch) {
          return branch.name.toLowerCase().contains(query) ||
              branch.address.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerAnimationController.dispose();
    _searchBarAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = AppSize.paddingHorizontal;
    final fontSize = AppSize.titleFontSize;
    final isSmallScreen = AppSize.isSmallScreen;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to go behind status bar
      body: SafeArea(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0,
                      (1 - _headerAnimation.value) * -AppSize.heightPercent(6)),
                  child: Opacity(
                    opacity: _headerAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: AppSize.getHeaderPadding(),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xFF2680C5),
                      Color(
                          0xFF3D91D1), // Intermediate color for smoother gradient
                      Color(0xFFF37021),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppSize.cardBorderRadius * 2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with app title and icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side - Title/Logo
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSize.widthPercent(2)),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    AppSize.cardBorderRadius),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: Colors.white,
                                size: AppSize.iconSize,
                              ),
                            ),
                            SizedBox(width: AppSize.widthPercent(2)),
                            Text(
                              "Bank BRI",
                              style: AppSize.getTextStyle(
                                fontSize: AppSize.subtitleFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: AppSize.heightPercent(4)),

                    // Main header text
                    Text(
                      "Pilih Bank yang",
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(0.5)),
                    Text(
                      "ingin dituju",
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSize.screenHeight * 0.02),
            // Bank Branch List dengan animasi
            Expanded(
              child: _filteredBranches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No banks found",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try a different search term",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _listAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _listAnimationController.value,
                          child: child,
                        );
                      },
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: paddingHorizontal),
                        itemCount: _filteredBranches.length,
                        itemBuilder: (context, index) {
                          final branch = _filteredBranches[index];

                          // Animasi staggered untuk setiap item dalam list
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BankBranchCard(branch: branch),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
