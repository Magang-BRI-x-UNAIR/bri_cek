import 'dart:math';
import 'package:bri_cek/screens/choose_bank_screen.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/user_model.dart';
import 'package:bri_cek/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
                  _buildPerformanceChart(),
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
      initialChildSize: 0.05, // Starting size (just the handle showing)
      minChildSize: 0.05, // Minimum size when collapsed
      maxChildSize: 0.25, // Maximum size when expanded (25% of screen)
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
          child: Column(
            children: [
              // Handle indicator
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: AppSize.widthPercent(10),
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.paddingHorizontal,
                  ),
                  children: [
                    // Row with image and text
                    Row(
                      children: [
                        // Image
                        Container(
                          width: AppSize.widthPercent(32),
                          height: AppSize.heightPercent(20),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/assess_bank_person.png',
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSize.widthPercent(3)),
                        // Penilaian text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Beri Penilaian Kantor Kas',
                              style: AppSize.getTextStyle(
                                fontSize: AppSize.bodyFontSize,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),

                            SizedBox(height: AppSize.widthPercent(3)),

                            ElevatedButton(
                              onPressed: () {
                                // Navigate to ChooseBankScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ChooseBankScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor:
                                    Colors
                                        .transparent, // Make transparent to show gradient
                                elevation: 0, // Remove shadow
                              ).copyWith(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.transparent,
                                ),
                                foregroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
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
                                    horizontal: AppSize.widthPercent(5),
                                    vertical: AppSize.heightPercent(1.2),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Mulai',
                                        style: AppSize.getTextStyle(
                                          fontSize: AppSize.bodyFontSize,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: AppSize.widthPercent(25)),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: AppSize.iconSize,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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

            // Bank icon
            Positioned(
              right: AppSize.widthPercent(8),
              top: AppSize.heightPercent(3),
              child: Container(
                width: AppSize.widthPercent(45),
                height: AppSize.heightPercent(20),
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
              right: AppSize.widthPercent(2),
              top: AppSize.heightPercent(7),
              child: Container(
                width: AppSize.widthPercent(35),
                height: AppSize.heightPercent(15),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/images/female_character.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Male Characters
            Positioned(
              right: AppSize.widthPercent(23),
              top: AppSize.heightPercent(4),
              child: Container(
                width: AppSize.widthPercent(35),
                height: AppSize.heightPercent(18),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/images/male_character.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Greeting text
            Positioned(
              top: AppSize.heightPercent(7),
              left: AppSize.widthPercent(6),
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
                    _isLoading ? 'User' : _getFirstName(_currentUser?.fullName),
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.titleFontSize,
                      fontWeight: FontWeight.bold,
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

  Widget _buildPerformanceChart() {
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
              'Tren Performa Kantor BRI Surabaya',
              style: AppSize.getTextStyle(
                fontSize: AppSize.subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: AppSize.heightPercent(1)),

            // Dropdown filters
            _buildChartFilters(),

            SizedBox(height: AppSize.heightPercent(2)),

            // Chart takes full width
            Container(
              height: AppSize.heightPercent(18),
              width: double.infinity,
              child:
                  _shouldShowWeeklyChart()
                      ? _buildWeeklyChart()
                      : _buildLineChart(),
            ),

            // Space between chart and legend
            SizedBox(height: AppSize.heightPercent(1.5)),

            // Legend now placed below the chart
            _shouldShowWeeklyChart()
                ? _buildWeeklyChartLegend()
                : _buildMonthlyChartLegend(),
          ],
        ),
      ),
    );
  }

  // Helper method to determine which chart to show
  bool _shouldShowWeeklyChart() {
    return (_selectedBank != null &&
            _selectedBank != 'Semua Bank' &&
            _selectedMonth != null &&
            _selectedMonth != 'Semua Bulan') ||
        (_selectedBank == 'Semua Bank' &&
            _selectedMonth != null &&
            _selectedMonth != 'Semua Bulan');
  }

  // Add these properties to your state class - update the existing ones
  String? _selectedBank = 'Semua Bank';
  String? _selectedMonth = 'Semua Bulan';
  final List<String> _banks = [
    'Semua Bank',
    'KK Bulog',
    'KK Gubeng',
    'KK Kadam',
    'KK Genteng',
  ];
  final List<String> _months = [
    'Semua Bulan',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  Widget _buildChartFilters() {
    return Row(
      children: [
        // Bank dropdown
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBank,
                hint: Text('Pilih Kantor KK'),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down),
                items:
                    _banks.map((String bank) {
                      return DropdownMenuItem<String>(
                        value: bank,
                        child: Text(bank),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBank = newValue;
                  });
                },
              ),
            ),
          ),
        ),

        SizedBox(width: AppSize.widthPercent(3)),

        // Month dropdown
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMonth,
                hint: Text('Pilih Bulan'),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down),
                items:
                    _months.map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMonth = newValue;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Also update the MonthlyChartLegend to show all banks when both "Semua Bank" and "Semua Bulan" are selected
  Widget _buildMonthlyChartLegend() {
    bool showAllBanksAndMonths =
        _selectedBank == 'Semua Bank' && _selectedMonth == 'Semua Bulan';

    if (_selectedBank == 'Semua Bank' && !showAllBanksAndMonths) {
      // Show legend for average line only
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.paddingHorizontal / 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildChartLegend('Rata-rata Semua Kantor', Colors.red)],
        ),
      );
    } else {
      // Show legends for all banks (for both case: single bank selected or all banks + all months)
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.paddingHorizontal / 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChartLegend('KK Bulog', Colors.blue),
                  _buildChartLegend('KK Gubeng', Colors.orange),
                  _buildChartLegend('KK Kadam', Colors.green),
                  _buildChartLegend('KK Genteng', Colors.purple),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildWeeklyChartLegend() {
    // Check if we're showing all banks with a specific month
    bool showAllBanks = _selectedBank == 'Semua Bank';

    if (showAllBanks) {
      // Return legend for all banks
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.paddingHorizontal / 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChartLegend('KK Bulog', Colors.blue),
                  _buildChartLegend('KK Gubeng', Colors.orange),
                  _buildChartLegend('KK Kadam', Colors.green),
                  _buildChartLegend('KK Genteng', Colors.purple),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Return legend for weekly performance of a single bank
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.paddingHorizontal / 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChartLegend('Minggu 1', Colors.blue),
                  _buildChartLegend('Minggu 2', Colors.orange),
                  _buildChartLegend('Minggu 3', Colors.green),
                  _buildChartLegend('Minggu 4', Colors.purple),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildWeeklyChart() {
    // Get month index (0-based)
    int monthIndex = _months.indexOf(_selectedMonth!);

    // Check if we're showing all banks with a specific month
    bool showAllBanks = _selectedBank == 'Semua Bank';

    // If showing specific bank
    if (!showAllBanks) {
      // Get color based on selected bank
      Color bankColor;
      switch (_selectedBank) {
        case 'KK Bulog':
          bankColor = Colors.blue;
          break;
        case 'KK Gubeng':
          bankColor = Colors.orange;
          break;
        case 'KK Kadam':
          bankColor = Colors.green;
          break;
        case 'KK Genteng':
          bankColor = Colors.purple;
          break;
        default:
          bankColor = Colors.blue;
      }

      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  );

                  if (value >= 0 && value <= 3) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 4,
                      child: Text(
                        'Minggu ${(value + 1).toInt()}',
                        style: style,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                interval: 25,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value % 25 == 0 && value >= 0 && value <= 100) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 4,
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.black26, width: 1),
              left: BorderSide(color: Colors.black26, width: 1),
            ),
          ),
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            // Weekly performance data for selected bank and month
            LineChartBarData(
              spots: _getWeeklyData(_selectedBank!, monthIndex),
              isCurved: true,
              color: bankColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: bankColor,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: bankColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      );
    } else {
      // Show weekly data for all banks
      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  );

                  if (value >= 0 && value <= 3) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 4,
                      child: Text(
                        'Minggu ${(value + 1).toInt()}',
                        style: style,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                interval: 25,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value % 25 == 0 && value >= 0 && value <= 100) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 4,
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.black26, width: 1),
              left: BorderSide(color: Colors.black26, width: 1),
            ),
          ),
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            // KK Bulog
            LineChartBarData(
              spots: _getWeeklyData('KK Bulog', monthIndex),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.blue,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
            // KK Gubeng
            LineChartBarData(
              spots: _getWeeklyData('KK Gubeng', monthIndex),
              isCurved: true,
              color: Colors.orange,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.orange,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
            // KK Kadam
            LineChartBarData(
              spots: _getWeeklyData('KK Kadam', monthIndex),
              isCurved: true,
              color: Colors.green,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.green,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
            // KK Genteng
            LineChartBarData(
              spots: _getWeeklyData('KK Genteng', monthIndex),
              isCurved: true,
              color: Colors.purple,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.purple,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  List<FlSpot> _getWeeklyData(String bank, int monthIndex) {
    // This would ideally come from a data source
    // For demonstration, we'll generate different patterns for each bank/month

    // Use the bank name and month index to create somewhat predictable but different values
    final random = Random(bank.length * (monthIndex + 1));

    // Base value depending on the bank (matches the monthly trend somewhat)
    double baseValue; // Change from int to double
    switch (bank) {
      case 'KK Bulog':
        baseValue = 60.0; // Add .0 to make it a double
        break;
      case 'KK Gubeng':
        baseValue = 50.0;
        break;
      case 'KK Kadam':
        baseValue = 75.0;
        break;
      case 'KK Genteng':
        baseValue = 40.0;
        break;
      default:
        baseValue = 50.0;
    }

    // Generate weekly data with explicit conversion to double
    return [
      FlSpot(0, (baseValue - 10 + random.nextInt(20)).toDouble()),
      FlSpot(1, (baseValue - 5 + random.nextInt(15)).toDouble()),
      FlSpot(2, (baseValue + random.nextInt(25)).toDouble()),
      FlSpot(3, (baseValue + 5 + random.nextInt(20)).toDouble()),
    ];
  }

  Widget _buildLineChart() {
    // Determine if we need to highlight a specific bank or month
    bool showSingleBank =
        _selectedBank != null && _selectedBank != 'Semua Bank';
    bool showSingleMonth =
        _selectedMonth != null && _selectedMonth != 'Semua Bulan';
    bool showAllBanksAndMonths =
        _selectedBank == 'Semua Bank' && _selectedMonth == 'Semua Bulan';

    // Determine which month to highlight if a specific month is selected
    double highlightedMonthX = -1;
    if (showSingleMonth) {
      highlightedMonthX = _months.indexOf(_selectedMonth!) - 1.0;
    }

    // Data for all banks
    final List<LineChartBarData> allBanksData = [
      // KK Bulog (Blue)
      LineChartBarData(
        spots: [
          FlSpot(0, 20),
          FlSpot(1, 40),
          FlSpot(2, 45),
          FlSpot(3, 75),
          FlSpot(4, 65),
          FlSpot(5, 70),
          FlSpot(6, 60),
          FlSpot(7, 80),
          FlSpot(8, 75),
          FlSpot(9, 85),
          FlSpot(10, 70),
          FlSpot(11, 90),
        ],
        isCurved: true,
        color:
            showSingleBank && _selectedBank != 'KK Bulog'
                ? Colors.blue.withOpacity(0.3)
                : Colors.blue,
        barWidth: showSingleBank && _selectedBank == 'KK Bulog' ? 3.5 : 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: showSingleBank && _selectedBank == 'KK Bulog' ? 4 : 3,
              color:
                  showSingleBank && _selectedBank != 'KK Bulog'
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.blue,
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: showSingleBank && _selectedBank == 'KK Bulog',
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
      // KK Gubeng (Orange)
      LineChartBarData(
        spots: [
          FlSpot(0, 35),
          FlSpot(1, 30),
          FlSpot(2, 55),
          FlSpot(3, 65),
          FlSpot(4, 50),
          FlSpot(5, 60),
          FlSpot(6, 70),
          FlSpot(7, 55),
          FlSpot(8, 60),
          FlSpot(9, 75),
          FlSpot(10, 80),
          FlSpot(11, 70),
        ],
        isCurved: true,
        color:
            showSingleBank && _selectedBank != 'KK Gubeng'
                ? Colors.orange.withOpacity(0.3)
                : Colors.orange,
        barWidth: showSingleBank && _selectedBank == 'KK Gubeng' ? 3.5 : 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: showSingleBank && _selectedBank == 'KK Gubeng' ? 4 : 3,
              color:
                  showSingleBank && _selectedBank != 'KK Gubeng'
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.orange,
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: showSingleBank && _selectedBank == 'KK Gubeng',
          color: Colors.orange.withOpacity(0.2),
        ),
      ),
      // KK Kadam (Green)
      LineChartBarData(
        spots: [
          FlSpot(0, 50),
          FlSpot(1, 45),
          FlSpot(2, 60),
          FlSpot(3, 80),
          FlSpot(4, 75),
          FlSpot(5, 65),
          FlSpot(6, 85),
          FlSpot(7, 90),
          FlSpot(8, 80),
          FlSpot(9, 85),
          FlSpot(10, 75),
          FlSpot(11, 95),
        ],
        isCurved: true,
        color:
            showSingleBank && _selectedBank != 'KK Kadam'
                ? Colors.green.withOpacity(0.3)
                : Colors.green,
        barWidth: showSingleBank && _selectedBank == 'KK Kadam' ? 3.5 : 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: showSingleBank && _selectedBank == 'KK Kadam' ? 4 : 3,
              color:
                  showSingleBank && _selectedBank != 'KK Kadam'
                      ? Colors.green.withOpacity(0.3)
                      : Colors.green,
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: showSingleBank && _selectedBank == 'KK Kadam',
          color: Colors.green.withOpacity(0.2),
        ),
      ),
      // KK Genteng (Purple)
      LineChartBarData(
        spots: [
          FlSpot(0, 5),
          FlSpot(1, 10),
          FlSpot(2, 15),
          FlSpot(3, 25),
          FlSpot(4, 30),
          FlSpot(5, 40),
          FlSpot(6, 35),
          FlSpot(7, 45),
          FlSpot(8, 50),
          FlSpot(9, 55),
          FlSpot(10, 60),
          FlSpot(11, 65),
        ],
        isCurved: true,
        color:
            showSingleBank && _selectedBank != 'KK Genteng'
                ? Colors.purple.withOpacity(0.3)
                : Colors.purple,
        barWidth: showSingleBank && _selectedBank == 'KK Genteng' ? 3.5 : 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: showSingleBank && _selectedBank == 'KK Genteng' ? 4 : 3,
              color:
                  showSingleBank && _selectedBank != 'KK Genteng'
                      ? Colors.purple.withOpacity(0.3)
                      : Colors.purple,
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: showSingleBank && _selectedBank == 'KK Genteng',
          color: Colors.purple.withOpacity(0.2),
        ),
      ),
    ];

    // If a specific month is selected, we'll modify the data to highlight that month
    if (showSingleMonth && highlightedMonthX >= 0) {
      // Modify each bank's data to highlight the selected month
      for (int i = 0; i < allBanksData.length; i++) {
        // Get the spot for the selected month
        final selectedSpot = allBanksData[i].spots.firstWhere(
          (spot) => spot.x == highlightedMonthX,
          orElse: () => FlSpot(highlightedMonthX, 0),
        );

        // Create a new spots list with dimmed points except for the selected month
        final newSpots =
            allBanksData[i].spots.map((spot) {
              if (spot.x == highlightedMonthX) {
                // Keep the selected month spot as is, maybe make it slightly larger
                return spot;
              } else {
                // For other months, keep the data but make it dimmed
                return spot;
              }
            }).toList();

        // Update the spots in the bank data
        allBanksData[i] = allBanksData[i].copyWith(
          spots: newSpots,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              // Make dots for selected month larger and brighter
              bool isSelectedMonth = spot.x == highlightedMonthX;

              return FlDotCirclePainter(
                radius: isSelectedMonth ? 5 : 3,
                color:
                    isSelectedMonth
                        ? (barData.color ?? Colors.black)
                        : (barData.color ?? Colors.grey).withOpacity(0.5),
                strokeWidth: isSelectedMonth ? 2 : 1,
                strokeColor: Colors.white,
              );
            },
          ),
        );
      }
    }

    // Average data for all banks combined
    final List<double> averageData = List.generate(12, (monthIndex) {
      double sum = 0;
      int count = 0;

      // For each bank, add its value for this month to the sum
      allBanksData.forEach((bankData) {
        // Find the spot for this month
        final spot = bankData.spots.firstWhere(
          (spot) =>
              spot.x == monthIndex.toDouble(), // Convert monthIndex to double
          orElse:
              () => FlSpot(monthIndex.toDouble(), 0), // Convert to double here
        );
        sum += spot.y;
        count++;
      });

      // Return the average value
      return count > 0 ? sum / count : 0;
    });

    // Aggregate line data for all banks
    final LineChartBarData aggregateData = LineChartBarData(
      spots:
          averageData
              .asMap()
              .entries
              .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
              .toList(),
      isCurved: true,
      color: Colors.red,
      barWidth: 3.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.red,
            strokeWidth: 1,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.2)),
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );

                if (value == value.roundToDouble() &&
                    value >= 0 &&
                    value <= 11) {
                  String month;
                  switch (value.toInt()) {
                    case 0:
                      month = 'Jan';
                      break;
                    case 1:
                      month = 'Feb';
                      break;
                    case 2:
                      month = 'Mar';
                      break;
                    case 3:
                      month = 'Apr';
                      break;
                    case 4:
                      month = 'Mei';
                      break;
                    case 5:
                      month = 'Jun';
                      break;
                    case 6:
                      month = 'Jul';
                      break;
                    case 7:
                      month = 'Ags';
                      break;
                    case 8:
                      month = 'Sep';
                      break;
                    case 9:
                      month = 'Okt';
                      break;
                    case 10:
                      month = 'Nov';
                      break;
                    case 11:
                      month = 'Des';
                      break;
                    default:
                      month = '';
                  }

                  // Highlight the selected month
                  final bool isSelected =
                      showSingleMonth && value == highlightedMonthX;

                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: Text(
                      month,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.blue.shade800 : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25,
              interval: 25,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value % 25 == 0 && value >= 0 && value <= 100) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.black26, width: 1),
            left: BorderSide(color: Colors.black26, width: 1),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.white,
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(color: Colors.grey.shade300),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final bankIndex = barSpot.barIndex;
                String bankName;

                if (!showAllBanksAndMonths &&
                    _selectedBank == 'Semua Bank' &&
                    bankIndex == 0) {
                  bankName = 'Rata-rata';
                } else if (bankIndex < _banks.length - 1) {
                  bankName =
                      _banks[bankIndex +
                          1]; // +1 because first item is "All Banks"
                } else {
                  bankName = 'Bank';
                }

                return LineTooltipItem(
                  '$bankName: ${barSpot.y.toStringAsFixed(1)}',
                  TextStyle(
                    color: barSpot.bar.color,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 100,
        lineBarsData:
            _selectedBank == 'Semua Bank'
                ? (showAllBanksAndMonths
                    ? allBanksData // Show all banks when both "Semua Bank" and "Semua Bulan" selected
                    : (showSingleMonth
                        ? allBanksData // Show all banks with month highlight
                        : [
                          aggregateData,
                        ])) // Show only aggregate when no month selected but not both "Semua"
                : [
                  allBanksData.firstWhere(
                    (data) =>
                        _banks.indexOf(_selectedBank!) - 1 ==
                        allBanksData.indexOf(data),
                    orElse: () => allBanksData[0],
                  ),
                ], // Show only selected bank
      ),
    );
  }

  Widget _buildChartLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSize.widthPercent(2.5),
          height: AppSize.widthPercent(2.5),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSize.widthPercent(1)),
        Text(
          text,
          style: AppSize.getTextStyle(
            fontSize: AppSize.smallFontSize,
            color: Colors.black87,
          ),
        ),
      ],
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
                padding: EdgeInsets.all(AppSize.paddingHorizontal / 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAssessmentItem(Icons.people, 'Pelayanan'),
                    _buildAssessmentItem(Icons.assignment, 'Kerapihan'),
                    _buildAssessmentItem(
                      Icons.cleaning_services,
                      'Kebersihan Kantor',
                    ),
                    _buildAssessmentItem(Icons.business, 'Kelengkapan Kantor'),
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
                  'Aspek Penilaian',
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
      width: AppSize.widthPercent(18), // Set a consistent width for alignment
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add padding at the top of the column
          SizedBox(height: AppSize.heightPercent(2.5)),

          // Icon container
          Container(
            padding: EdgeInsets.all(AppSize.widthPercent(3)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Icon(icon, color: Colors.orange, size: AppSize.iconSize),
          ),

          SizedBox(height: AppSize.heightPercent(1)),

          // Text container with top alignment
          Container(
            height: AppSize.heightPercent(5), // Fixed height for text container
            width: double.infinity,
            child: Align(
              alignment: Alignment.topCenter, // Align text to top-center
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize,
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
