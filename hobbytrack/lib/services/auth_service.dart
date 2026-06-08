import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool emailSouUnit(String email) {
    return email.toLowerCase().trim().endsWith('@souunit.com.br');
  }

  Future<User?> cadastrarComEmailSenha({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final emailTratado = email.toLowerCase().trim();

    if (!emailSouUnit(emailTratado)) {
      throw FirebaseAuthException(
        code: 'email-invalido',
        message: 'Use apenas e-mail institucional @souunit.com.br.',
      );
    }

    final credencial = await _auth.createUserWithEmailAndPassword(
      email: emailTratado,
      password: senha,
    );

    final usuario = credencial.user;

    if (usuario != null) {
      await usuario.updateDisplayName(nome);

      await _firestore.collection('usuarios').doc(usuario.uid).set({
        'nome': nome,
        'email': emailTratado,
        'usuario_logado': emailTratado,
        'criado_por': emailTratado,
        'criado_em': FieldValue.serverTimestamp(),
      });
    }

    return usuario;
  }

  Future<User?> entrarComEmailSenha({
    required String email,
    required String senha,
  }) async {
    final emailTratado = email.toLowerCase().trim();

    final credencial = await _auth.signInWithEmailAndPassword(
      email: emailTratado,
      password: senha,
    );

    final usuario = credencial.user;
    final emailUsuario = usuario?.email ?? '';

    if (!emailSouUnit(emailUsuario)) {
      await sair();

      throw FirebaseAuthException(
        code: 'dominio-invalido',
        message: 'Acesso permitido apenas com e-mail @souunit.com.br.',
      );
    }

    if (usuario != null) {
      await _firestore.collection('usuarios').doc(usuario.uid).set({
        'email': emailUsuario,
        'usuario_logado': emailUsuario,
        'criado_por': emailUsuario,
        'ultimo_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return usuario;
  }

  Future<User?> entrarComGoogle() async {
    UserCredential userCredential;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();

      provider.setCustomParameters({
        'prompt': 'select_account',
      });

      userCredential = await _auth.signInWithPopup(provider);
    } else {
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      final contaGoogle = await googleSignIn.authenticate();

      final autenticacaoGoogle = contaGoogle.authentication;

      final credencial = GoogleAuthProvider.credential(
        idToken: autenticacaoGoogle.idToken,
      );

      userCredential = await _auth.signInWithCredential(credencial);
    }

    final usuario = userCredential.user;
    final emailUsuario = usuario?.email ?? '';

    if (!emailSouUnit(emailUsuario)) {
      await sair();

      throw FirebaseAuthException(
        code: 'dominio-invalido',
        message: 'Acesso permitido apenas com e-mail @souunit.com.br.',
      );
    }

    if (usuario != null) {
      await _firestore.collection('usuarios').doc(usuario.uid).set({
        'nome': usuario.displayName ?? '',
        'email': emailUsuario,
        'usuario_logado': emailUsuario,
        'criado_por': emailUsuario,
        'ultimo_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return usuario;
  }

  Future<void> recuperarSenha(String email) async {
    final emailTratado = email.toLowerCase().trim();

    if (!emailSouUnit(emailTratado)) {
      throw FirebaseAuthException(
        code: 'email-invalido',
        message: 'Use apenas e-mail institucional @souunit.com.br.',
      );
    }

    await _auth.setLanguageCode('pt-BR');

    await _auth.sendPasswordResetEmail(email: emailTratado);
  }

  Future<void> sair() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }

    await _auth.signOut();
  }

  User? get usuarioAtual {
    return _auth.currentUser;
  }
}