import 'package:flutter/material.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/services/bank_branch_service.dart';
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
  final BankBranchService _bankBranchService = BankBranchService();

  List<BankBranch> _allBranches = [];
  List<BankBranch> _filteredBranches = [];
  bool _isLoading = true;
  bool _isSearching = false;

  // Animation controllers (keep existing animation code)
  late AnimationController _headerAnimationController;
  late AnimationController _searchBarAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _searchBarAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterBranches);
    _initializeAnimations();
    _loadBranches();
  }

  void _initializeAnimations() {
    // Keep existing animation initialization code
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    );

    _searchBarAnimation = CurvedAnimation(
      parent: _searchBarAnimationController,
      curve: Curves.easeInOut,
    );

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

  Future<void> _loadBranches() async {
    try {
      setState(() => _isLoading = true);

      final branches = await _bankBranchService.getActiveBranches();

      setState(() {
        _allBranches = branches;
        _filteredBranches = branches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading branches: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterBranches() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = _allBranches;
      } else {
        _filteredBranches =
            _allBranches
                .where(
                  (branch) =>
                      branch.name.toLowerCase().contains(query) ||
                      branch.address.toLowerCase().contains(query),
                )
                .toList();
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildAnimatedHeader(),
            _buildSearchBar(),
            _buildBankBranchList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
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
        height: AppSize.heightPercent(20),
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
            _buildCloudDecoration(
              top: AppSize.heightPercent(10),
              left: AppSize.widthPercent(20),
              size: AppSize.widthPercent(13),
              opacity: 0.3,
            ),
            _buildCloudDecoration(
              top: AppSize.heightPercent(3),
              left: AppSize.widthPercent(42),
              size: AppSize.widthPercent(12),
              opacity: 0.2,
            ),
            _buildCloudDecoration(
              top: AppSize.heightPercent(8),
              left: AppSize.widthPercent(90),
              size: AppSize.widthPercent(15),
              opacity: 0.2,
            ),

            // Bank icon
            Positioned(
              right: AppSize.widthPercent(8),
              top: AppSize.heightPercent(5),
              child: Container(
                width: AppSize.widthPercent(40),
                height: AppSize.heightPercent(15),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bank_transparent.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Header content
            Padding(
              padding: EdgeInsets.only(
                left: AppSize.widthPercent(6),
                top: AppSize.heightPercent(2),
                right: AppSize.widthPercent(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App title and logo
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSize.widthPercent(2)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppSize.cardBorderRadius,
                          ),
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

                  SizedBox(height: AppSize.heightPercent(2)),

                  // Main header text
                  Text(
                    "Pilih Bank yang",
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppSize.heightPercent(0.2)),
                  Text(
                    "ingin dituju",
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildCloudDecoration({
    required double top,
    required double left,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(
        Icons.cloud,
        color: Colors.white.withOpacity(opacity),
        size: size,
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchBarAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            (1 - _searchBarAnimation.value) * AppSize.heightPercent(5),
          ),
          child: Opacity(opacity: _searchBarAnimation.value, child: child),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.paddingHorizontal,
          vertical: AppSize.heightPercent(2),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            onTap: () => setState(() => _isSearching = true),
            onSubmitted: (_) => setState(() => _isSearching = false),
            decoration: InputDecoration(
              hintText: 'Search Bank...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: AppSize.isSmallScreen ? 14 : 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[400],
                size: AppSize.iconSize * 0.8,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[400],
                          size: AppSize.iconSize * 0.7,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _isSearching = false);
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: AppSize.heightPercent(1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankBranchList() {
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
          ),
        ),
      );
    }

    return Expanded(
      child:
          _filteredBranches.isEmpty
              ? _buildEmptySearchResults()
              : AnimatedBuilder(
                animation: _listAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _listAnimationController.value,
                    child: child,
                  );
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.paddingHorizontal,
                  ),
                  itemCount: _filteredBranches.length,
                  itemBuilder: (context, index) {
                    final branch = _filteredBranches[index];
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: AppSize.heightPercent(1.5),
                        ),
                        child: BankBranchCard(branch: branch),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildEmptySearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: AppSize.iconSize * 2,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppSize.heightPercent(2)),
          Text(
            "No banks found",
            style: AppSize.getTextStyle(
              fontSize: AppSize.subtitleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600] ?? Colors.black,
            ),
          ),
          SizedBox(height: AppSize.heightPercent(1)),
          Text(
            "Try a different search term",
            style: AppSize.getTextStyle(
              fontSize: AppSize.isSmallScreen ? 12 : 14,
              color: Colors.grey[500] ?? Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
