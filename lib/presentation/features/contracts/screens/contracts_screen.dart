import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/presentation/features/contracts/viewmodels/contract_viewmodel.dart';
import 'saved_quotes_tab.dart';
import 'contracts_tab.dart';

class ContractsScreen extends StatefulWidget {
  final int initialTab;

  const ContractsScreen({super.key, this.initialTab = 0});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContractViewModel>(context, listen: false).loadAllData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: _buildAppBar(screenWidth, textScaleFactor),
      body: TabBarView(
        controller: _tabController,
        children: [
          SavedQuotesTab(screenWidth: screenWidth, textScaleFactor: textScaleFactor),
          ContractsTab(
            tabController: _tabController,
            screenWidth: screenWidth,
            textScaleFactor: textScaleFactor,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double screenWidth, double textScaleFactor) {
    final titleFontSize = (22.0 / textScaleFactor).clamp(20.0, 26.0);
    final tabFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final iconSize = screenWidth < 360 ? 22 : 26;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.white,
      elevation: 0,
      toolbarHeight: 80,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[600]!,
              Colors.indigo[700]!,
            ],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.white,
            size: iconSize.toDouble(),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Mes Contrats',
        style: FontHelper.poppins(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.white,
        indicatorWeight: 3,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.white.withOpacity(0.7),
        labelStyle: FontHelper.poppins(
          fontSize: tabFontSize,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: FontHelper.poppins(
          fontSize: tabFontSize,
          fontWeight: FontWeight.w400,
        ),
        tabs: [
          Tab(
            icon: Icon(
              Icons.description_outlined,
              size: screenWidth < 360 ? 18 : 20,
            ),
            text: 'Devis simulés',
          ),
          Tab(
            icon: Icon(
              Icons.assignment_outlined,
              size: screenWidth < 360 ? 18 : 20,
            ),
            text: 'Contrats',
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Image.asset(
            'lib/assets/logoSaarCI.png',
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
