import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/providers/product_provider.dart';
import 'package:saarflex_app/screens/simulation/simulation_screen.dart';
import '../../constants/colors.dart';
import '../../models/product_model.dart';

class InfoAssureScreen extends StatefulWidget {
  final Product produit;

  const InfoAssureScreen({super.key, required this.produit});

  @override
  State<InfoAssureScreen> createState() => _InfoAssureScreenState();
}

class _InfoAssureScreenState extends State<InfoAssureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final Map<String, dynamic> _formData = {};

  final List<String> _typesPiece = [
    'Carte d\'identité',
    'Passeport', 
    'Permis de conduire',
  ];

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informations de l\'assuré'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('nom_complet', 'Nom complet', true),
              _buildDateField('date_naissance', 'Date de naissance'),
              _buildDropdown('type_piece_identite', 'Type de pièce'),
              _buildTextField('numero_piece_identite', 'Numéro de pièce', true),
              _buildTextField('telephone', 'Téléphone', true),
              _buildTextField('adresse', 'Adresse', true),
              _buildTextField('email', 'Email', false),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validateAndSubmit,
                child: Text('Continuer vers la simulation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String field, String label, bool required) {
    return TextFormField(
      decoration: InputDecoration(labelText: '$label ${required ? '*' : ''}'),
      validator: required ? (value) => value!.isEmpty ? 'Obligatoire' : null : null,
      onChanged: (value) => _formData[field] = value,
    );
  }

  Widget _buildDropdown(String field, String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: '$label *'),
      items: _typesPiece.map((type) => 
        DropdownMenuItem(value: type, child: Text(type))
      ).toList(),
      validator: (value) => value == null ? 'Obligatoire' : null,
      onChanged: (value) => _formData[field] = value,
    );
  }

  Widget _buildDateField(String field, String label) {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: '$label *',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) => value!.isEmpty ? 'Obligatoire' : null,
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      
      setState(() {
        _formData['date_naissance'] = formattedDate;
        _dateController.text = formattedDate;
      });
    }
  }

  void _validateAndSubmit() {
  if (_formKey.currentState!.validate()) {
    if (_formData['date_naissance'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une date de naissance')),
      );
      return;
    }
    
    print('✅ InfoAssureScreen VALID - returning data: $_formData');
    
    // ✅ SOLUTION: Naviguer DIRECTEMENT depuis InfoAssureScreen
    _ouvrirSimulationDirectement(_formData);
  }
}

Future<void> _ouvrirSimulationDirectement(Map<String, dynamic> infos) async {
  try {
    print('🚀 Navigation directe depuis InfoAssureScreen');
    
    // Récupérer le productProvider directement
    final productProvider = context.read<ProductProvider>();
    final grilleId = await productProvider.getDefaultGrilleTarifaireId(widget.produit.id);
    
    if (grilleId != null) {
      // Navigator.pushReplacement pour éviter le retour à InfoAssureScreen
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => SimulationScreen(
          produit: widget.produit,
          grilleTarifaireId: grilleId,
          assureEstSouscripteur: false,
          informationsAssure: infos,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucune grille tarifaire disponible')),
      );
    }
  } catch (e) {
    print('❌ Erreur navigation directe: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  }
}
}