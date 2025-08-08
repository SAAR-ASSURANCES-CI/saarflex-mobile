import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/profile/edit_profile_screen.dart';
import '../../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, String> userProfile = {
    'firstName': 'Jean',
    'lastName': 'KOUAME',
    'birthDate': '15/03/1990',
    'birthPlace': 'Abidjan, Côte d\'Ivoire',
    'gender': 'Masculin',
    'nationality': 'Ivoirienne',
    'profession': 'Ingénieur Informatique',
    'phone': '+225 07 12 34 56 78',
    'email': 'jean.kouame@email.com',
    'address': '12 Rue des Cocotiers, Cocody, Abidjan',
    'idNumber': 'CI123456789',
    'idType': 'Carte Nationale d\'Identité',
    'idExpiry': '15/03/2030',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        _buildEditButton(),

                        const SizedBox(height: 24),

                        _buildSection(
                          title: "Informations personnelles",
                          icon: Icons.person_rounded,
                          fields: [
                            _buildInfoField(
                              "Prénom",
                              userProfile['firstName']!,
                            ),
                            _buildInfoField("Nom", userProfile['lastName']!),
                            _buildInfoField(
                              "Date de naissance",
                              userProfile['birthDate']!,
                            ),
                            _buildInfoField(
                              "Lieu de naissance",
                              userProfile['birthPlace']!,
                            ),
                            _buildInfoField("Sexe", userProfile['gender']!),
                            _buildInfoField(
                              "Nationalité",
                              userProfile['nationality']!,
                            ),
                            _buildInfoField(
                              "Profession",
                              userProfile['profession']!,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildSection(
                          title: "Coordonnées",
                          icon: Icons.contact_phone_rounded,
                          fields: [
                            _buildInfoField("Téléphone", userProfile['phone']!),
                            _buildInfoField("Email", userProfile['email']!),
                            _buildInfoField("Adresse", userProfile['address']!),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildSection(
                          title: "Pièce d'identité",
                          icon: Icons.badge_rounded,
                          fields: [
                            _buildInfoField(
                              "Type de pièce",
                              userProfile['idType']!,
                            ),
                            _buildInfoField("Numéro", userProfile['idNumber']!),
                            _buildInfoField(
                              "Date d'expiration",
                              userProfile['idExpiry']!,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        _buildActionButtons(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Mon Profil",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(56),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 50,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "${userProfile['firstName']} ${userProfile['lastName']}",
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            userProfile['profession']!,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
          print("Naviguer vers EditProfileScreen");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              "Modifier mon profil",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> fields,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: fields),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
          ),
          child: ElevatedButton(
            onPressed: () {
              print("Changer le mot de passe");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_reset_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Changer le mot de passe",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
          ),
          child: ElevatedButton(
            onPressed: () {
              _showLogoutDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Se déconnecter",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Déconnexion",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          content: Text(
            "Êtes-vous sûr de vouloir vous déconnecter ?",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.primary.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Annuler",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                print("Déconnexion");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Déconnecter",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
