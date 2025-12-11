import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/presentation/features/contracts/viewmodels/contract_viewmodel.dart';
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
      backgroundColor: AppColors.background,
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
    final titleFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final tabFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final iconSize = screenWidth < 360 ? 20 : 24;
    
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.white,
          size: iconSize.toDouble(),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Mes Contrats',
        style: GoogleFonts.poppins(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w600,
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
        labelStyle: GoogleFonts.poppins(
          fontSize: tabFontSize,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
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
        IconButton(
          icon: Icon(
            Icons.refresh,
            size: iconSize.toDouble(),
          ),
          onPressed: () {
            Provider.of<ContractViewModel>(context, listen: false).refresh();
          },
        ),
      ],
    );
  }
}
