import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/core/utils/error_handler.dart';
import 'package:saarciflex_app/data/services/api_service.dart';
import 'dart:io';

void main() {
  group('ErrorHandler', () {
    group('handleAuthError', () {
      test('transforme ApiException 400 avec email en message utilisateur', () {
        final error = ApiException(
          'Email non trouvé',
          400,
        );
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Aucun compte associé à cet email.');
      });

      test('transforme ApiException 400 avec password en message utilisateur', () {
        final error = ApiException(
          'Mot de passe incorrect',
          400,
        );
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Mot de passe incorrect.');
      });

      test('transforme ApiException 401 en message utilisateur', () {
        final error = ApiException(
          'Unauthorized',
          401,
        );
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Email ou mot de passe incorrect.');
      });

      test('transforme ApiException 403 en message utilisateur', () {
        final error = ApiException(
          'Forbidden',
          403,
        );
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Accès interdit. Vérifiez vos permissions.');
      });

      test('transforme ApiException 409 en message utilisateur', () {
        final error = ApiException(
          'Conflict',
          409,
        );
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Un compte avec cet email existe déjà.');
      });

      test('transforme ApiException 500 en message utilisateur', () {
        final error = ApiException(
          'Internal Server Error',
          500,
        );
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Erreur serveur. Veuillez réessayer plus tard.');
      });

      test('gère SocketException (pas de connexion)', () {
        final error = SocketException('No Internet');
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Problème de connexion internet. Vérifiez votre réseau.');
      });

      test('gère FormatException', () {
        final error = FormatException('Invalid format');
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Erreur de format des données. Veuillez réessayer.');
      });

      test('gère HttpException', () {
        final error = HttpException('HTTP error');
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Erreur de communication avec le serveur.');
      });

      test('gère erreur inconnue', () {
        final error = Exception('Unknown error');
        final result = ErrorHandler.handleAuthError(error);
        expect(result, 'Une erreur inattendue est survenue.');
      });
    });

    group('handleUploadError', () {
      test('transforme ApiException 413 en message utilisateur', () {
        final error = ApiException(
          'File too large',
          413,
        );
        final result = ErrorHandler.handleUploadError(error);
        expect(result, 'Fichier trop volumineux. Taille maximum: 10MB.');
      });

      test('transforme ApiException 415 en message utilisateur', () {
        final error = ApiException(
          'Unsupported Media Type',
          415,
        );
        final result = ErrorHandler.handleUploadError(error);
        expect(result, 'Format de fichier non supporté.');
      });

      test('gère SocketException pour upload', () {
        final error = SocketException('No Internet');
        final result = ErrorHandler.handleUploadError(error);
        expect(result, 'Problème de connexion internet. Vérifiez votre réseau.');
      });

      test('gère erreur avec message "Fichier trop volumineux"', () {
        final error = Exception('Fichier trop volumineux');
        final result = ErrorHandler.handleUploadError(error);
        expect(result, 'Fichier trop volumineux. Taille maximum: 10MB.');
      });
    });

    group('handleProfileError', () {
      test('transforme ApiException 400 avec email en message utilisateur', () {
        final error = ApiException(
          'Email invalide',
          400,
        );
        final result = ErrorHandler.handleProfileError(error);
        expect(result, 'Email invalide.');
      });

      test('transforme ApiException 404 en message utilisateur', () {
        final error = ApiException(
          'Not Found',
          404,
        );
        final result = ErrorHandler.handleProfileError(error);
        expect(result, 'Profil non trouvé.');
      });
    });

    group('handleGenericError', () {
      test('retourne le message de ApiException', () {
        final error = ApiException(
          'Custom error message',
          500,
        );
        final result = ErrorHandler.handleGenericError(error);
        expect(result, 'Custom error message');
      });

      test('gère SocketException', () {
        final error = SocketException('No Internet');
        final result = ErrorHandler.handleGenericError(error);
        expect(result, 'Problème de connexion internet. Vérifiez votre réseau.');
      });
    });

    group('isRecoverableError', () {
      test('retourne true pour SocketException', () {
        final error = SocketException('No Internet');
        expect(ErrorHandler.isRecoverableError(error), true);
      });

      test('retourne true pour HttpException', () {
        final error = HttpException('HTTP error');
        expect(ErrorHandler.isRecoverableError(error), true);
      });

      test('retourne true pour ApiException 500', () {
        final error = ApiException('Server Error', 500);
        expect(ErrorHandler.isRecoverableError(error), true);
      });

      test('retourne true pour ApiException 429', () {
        final error = ApiException('Too Many Requests', 429);
        expect(ErrorHandler.isRecoverableError(error), true);
      });

      test('retourne false pour ApiException 400', () {
        final error = ApiException('Bad Request', 400);
        expect(ErrorHandler.isRecoverableError(error), false);
      });
    });

    group('getErrorType', () {
      test('retourne API_ERROR pour ApiException', () {
        final error = ApiException('Error', 400);
        expect(ErrorHandler.getErrorType(error), 'API_ERROR');
      });

      test('retourne NETWORK_ERROR pour SocketException', () {
        final error = SocketException('No Internet');
        expect(ErrorHandler.getErrorType(error), 'NETWORK_ERROR');
      });

      test('retourne FORMAT_ERROR pour FormatException', () {
        final error = FormatException('Invalid format');
        expect(ErrorHandler.getErrorType(error), 'FORMAT_ERROR');
      });

      test('retourne HTTP_ERROR pour HttpException', () {
        final error = HttpException('HTTP error');
        expect(ErrorHandler.getErrorType(error), 'HTTP_ERROR');
      });

      test('retourne UNKNOWN_ERROR pour erreur inconnue', () {
        final error = Exception('Unknown');
        expect(ErrorHandler.getErrorType(error), 'UNKNOWN_ERROR');
      });
    });

    group('validateName', () {
      test('retourne null pour nom valide', () {
        expect(ErrorHandler.validateName('John Doe'), null);
      });

      test('retourne erreur pour nom null', () {
        expect(ErrorHandler.validateName(null), 'Le nom est obligatoire');
      });

      test('retourne erreur pour nom vide', () {
        expect(ErrorHandler.validateName(''), 'Le nom est obligatoire');
      });

      test('retourne erreur pour nom trop court', () {
        expect(ErrorHandler.validateName('A'), 'Le nom doit contenir au moins 2 caractères');
      });
    });

    group('validateEmail', () {
      test('retourne null pour email valide', () {
        expect(ErrorHandler.validateEmail('test@test.com'), null);
      });

      test('retourne erreur pour email null', () {
        expect(ErrorHandler.validateEmail(null), 'L\'email est obligatoire');
      });

      test('retourne erreur pour email invalide', () {
        expect(ErrorHandler.validateEmail('invalid-email'), 'Format d\'email invalide');
      });

      test('retourne erreur pour email sans @', () {
        expect(ErrorHandler.validateEmail('testtest.com'), 'Format d\'email invalide');
      });
    });

    group('validatePhone', () {
      test('retourne null pour téléphone valide', () {
        expect(ErrorHandler.validatePhone('0123456789'), null);
      });

      test('retourne erreur pour téléphone null', () {
        expect(ErrorHandler.validatePhone(null), 'Le téléphone est obligatoire');
      });

      test('retourne erreur pour téléphone trop court', () {
        expect(ErrorHandler.validatePhone('123'), 'Numéro de téléphone invalide');
      });
    });

    group('validatePassword', () {
      test('retourne null pour mot de passe valide', () {
        expect(ErrorHandler.validatePassword('password123'), null);
      });

      test('retourne erreur pour mot de passe null', () {
        expect(ErrorHandler.validatePassword(null), 'Le mot de passe est obligatoire');
      });

      test('retourne erreur pour mot de passe trop court', () {
        expect(ErrorHandler.validatePassword('12345'), 'Le mot de passe doit contenir au moins 6 caractères');
      });
    });
  });
}
