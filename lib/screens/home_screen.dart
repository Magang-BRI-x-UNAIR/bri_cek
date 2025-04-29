import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:fl_chart/fl_chart.dart';

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

    // Start animations sequentially
    _startAnimationsSequentially();
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
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
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
                  color: Colors.grey.shade300,
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
                    // Add your swipeable content here
                    Text(
                      'Penilaian',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.subtitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(2)),
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Mulai',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.bodyFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Additional content can go here
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2680C5), Color(0xFF3D91D1), Color(0xFFF37021)],
            stops: [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Stack(
          children: [
            // Cloud decorations
            Positioned(
              top: AppSize.heightPercent(5),
              left: AppSize.widthPercent(5),
              child: Icon(
                Icons.cloud,
                color: Colors.white.withOpacity(0.3),
                size: AppSize.widthPercent(15),
              ),
            ),
            Positioned(
              top: AppSize.heightPercent(10),
              left: AppSize.widthPercent(15),
              child: Icon(
                Icons.cloud,
                color: Colors.white.withOpacity(0.2),
                size: AppSize.widthPercent(10),
              ),
            ),

            // Characters
            Positioned(
              right: AppSize.widthPercent(1),
              bottom: 0,
              child: Row(
                children: [
                  // Male character
                  Container(
                    width: AppSize.widthPercent(25),
                    height: AppSize.heightPercent(15),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                        image: AssetImage('assets/images/male_character.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Female character
                  Container(
                    width: AppSize.widthPercent(25),
                    height: AppSize.heightPercent(15),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                        image: AssetImage('assets/images/female_character.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Greeting text
            Positioned(
              top: AppSize.heightPercent(5),
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
                    'Admin',
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
            SizedBox(height: AppSize.heightPercent(2)),
            Container(
              height: AppSize.heightPercent(20),
              width: double.infinity,
              child: _buildBarChart(),
            ),
            SizedBox(height: AppSize.heightPercent(1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChartLegend('KK Bulak Surabaya', Colors.blue),
                _buildChartLegend('KK Gubeng Surabaya', Colors.orange),
                _buildChartLegend('KK Kadam Surabaya', Colors.green),
                _buildChartLegend('KK Genteng Kali Surabaya', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSize.widthPercent(3),
          height: AppSize.widthPercent(3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSize.widthPercent(1)),
        Text(
          text,
          style: AppSize.getTextStyle(
            fontSize: AppSize.isSmallScreen ? 8 : 10,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('Januari', style: style);
                    break;
                  case 1:
                    text = const Text('Februari', style: style);
                    break;
                  case 2:
                    text = const Text('Maret', style: style);
                    break;
                  case 3:
                    text = const Text('April', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                return SideTitleWidget(
                  // Replace 'axisSide: meta.axisSide' with 'meta: meta'
                  meta: meta,
                  space: 8,
                  child: text,
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == 0 ||
                    value == 25 ||
                    value == 50 ||
                    value == 75 ||
                    value == 100) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 8, // Add this parameter
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
        borderData: FlBorderData(show: false),
        barGroups: [
          // January
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: 35, color: Colors.orange),
              BarChartRodData(toY: 20, color: Colors.blue),
              BarChartRodData(toY: 50, color: Colors.green),
              BarChartRodData(toY: 5, color: Colors.purple),
            ],
          ),
          // February
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(toY: 30, color: Colors.orange),
              BarChartRodData(toY: 40, color: Colors.blue),
              BarChartRodData(toY: 45, color: Colors.green),
              BarChartRodData(toY: 10, color: Colors.purple),
            ],
          ),
          // March
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(toY: 55, color: Colors.orange),
              BarChartRodData(toY: 45, color: Colors.blue),
              BarChartRodData(toY: 60, color: Colors.green),
              BarChartRodData(toY: 15, color: Colors.purple),
            ],
          ),
          // April
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(toY: 65, color: Colors.orange),
              BarChartRodData(toY: 75, color: Colors.blue),
              BarChartRodData(toY: 80, color: Colors.green),
              BarChartRodData(toY: 25, color: Colors.purple),
            ],
          ),
        ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: AppSize.paddingVertical / 2,
                horizontal: AppSize.paddingHorizontal,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
              ),
              child: Text(
                'Aspek penilaian',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            SizedBox(height: AppSize.heightPercent(2)),
            Container(
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
                    'Kebersihan\nKantor',
                  ),
                  _buildAssessmentItem(Icons.business, 'Kelengkapan\nKantor'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentItem(IconData icon, String label) {
    return Column(
      children: [
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
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppSize.getTextStyle(
            fontSize: AppSize.smallFontSize,
            color: Colors.blue.shade800,
          ),
        ),
      ],
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
              'pengguna dapat geser kekatas.',
              Colors.blue,
            ),
            _buildInstructionStep(
              '2',
              'Lalu pengguna dapat klik "Mulai"',
              'untuk menjalankan fitur tersebut',
              Colors.blue,
            ),
            _buildInstructionStep(
              '3',
              'Untuk melakukan penilaian pengguna dapat',
              'menambahkan tempat untuk melakukan penilaian.',
              Colors.blue,
            ),
            _buildInstructionStep(
              '4',
              'Setelah itu pengguna dapat memilih tempat / divisi',
              'dan terdapat nama yang menjabat di divisi tersebut, pengguna dapat memilihnya untuk penilaian.',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
    String number,
    String title,
    String subtitle,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSize.heightPercent(1.5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: AppSize.widthPercent(2)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.bodyFontSize,
                        color: Colors.black87,
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
                Text(
                  subtitle,
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
