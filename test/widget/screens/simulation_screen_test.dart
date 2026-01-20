import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/presentation/features/simulation/screens/simulation_screen.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('SimulationScreen', () {
    testWidgets('affiche le formulaire de simulation', (WidgetTester tester) async {
      final viewModel = SimulationViewModel();
      final produit = Product(
        id: 'test-id',
        nom: 'Test Produit',
        description: 'Description test',
        type: ProductType.vie,
      );
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: SimulationScreen(
            produit: produit,
            assureEstSouscripteur: true,
          ),
          simulationViewModel: viewModel,
        ),
      );

      expect(find.byType(SimulationScreen), findsOneWidget);
    });

    testWidgets('affiche le bouton de simulation', (WidgetTester tester) async {
      final viewModel = SimulationViewModel();
      final produit = Product(
        id: 'test-id',
        nom: 'Test Produit',
        description: 'Description test',
        type: ProductType.vie,
      );
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: SimulationScreen(
            produit: produit,
            assureEstSouscripteur: true,
          ),
          simulationViewModel: viewModel,
        ),
      );

      expect(find.byType(SimulationScreen), findsOneWidget);
    });
  });
}
