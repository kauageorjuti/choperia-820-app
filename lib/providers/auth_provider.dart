import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = AppUser(
          id: user.uid,
          name: user.displayName ?? 'Cliente',
          email: user.email ?? '',
          phone: '', // Pode ser puxado do Firestore depois, se necessário
        );
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  AppUser? _currentUser;
  bool _isLoading = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // clientId      → usado pela Web (google_sign_in_web)
  // serverClientId → usado pelo Android para gerar o idToken
  // Ambos usam o Web Client ID (client_type: 3) do google-services.json
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: '984856277343-hq08tums6vdkfprq3gmtksi1opr39n5t.apps.googleusercontent.com',
    serverClientId: '984856277343-hq08tums6vdkfprq3gmtksi1opr39n5t.apps.googleusercontent.com',
  );

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  // 1. LOGIN COM E-MAIL E SENHA
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = AppUser(
        id: credential.user!.uid,
        name: credential.user?.displayName ?? 'Cliente Choperia',
        email: credential.user?.email ?? email,
        phone: '',
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('E-mail ou senha incorretos.');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. LOGIN COM GOOGLE — API v6
  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCred;

      if (kIsWeb) {
        // NA WEB: Usamos a forma nativa do Firebase para Web (muito mais simples e estável)
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCred = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // NO ANDROID/iOS: Usamos o google_sign_in
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          throw Exception('Login com Google cancelado.');
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        userCred = await _firebaseAuth.signInWithCredential(credential);
      }

      // Salva o usuário logado
      _currentUser = AppUser(
        id: userCred.user!.uid,
        name: userCred.user?.displayName ?? 'Cliente Google',
        email: userCred.user?.email ?? '',
        phone: '',
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Erro Google Sign-In: $e');
      throw Exception('Erro ao entrar com o Google. Verifique sua conexão e tente novamente.');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 3. CRIAR CONTA COM E-MAIL E SENHA
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      _currentUser = AppUser(
        id: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erro ao criar conta. Verifique os dados e tente novamente.');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 4. RECUPERAR SENHA
  Future<void> recoverPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Erro ao enviar e-mail de recuperação.');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 5. LOGOUT
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    _currentUser = null;
    notifyListeners();
  }
}