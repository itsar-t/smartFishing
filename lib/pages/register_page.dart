import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    String username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty && email.contains('@')) {
      username = email.split('@').first;
    }
    if (email.isEmpty || password.isEmpty) {
      _showError('Fyll i både e-post och lösenord.');
      return;
    }
    if (username.contains('@')) {
      _showError('Användarnamn får inte innehålla @.');
      return;
    }
    if (password.length < 6) {
      _showError('Lösenord måste vara minst 6 tecken.');
      return;
    }

    try {
      // Kolla att username är ledigt
      final existing = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        _showError('Användarnamnet är redan taget.');
        return;
      }

      final currentUser = _auth.currentUser;

      // --- 1) AUTH: antingen länka gäst eller skapa nytt ---
      User user;
      if (currentUser != null && currentUser.isAnonymous) {
        final cred = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        final linked = await currentUser.linkWithCredential(cred);
        user = linked.user!;
        await user.updateDisplayName(username);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konto kopplat! Du är inte längre gäst.'),
          ),
        );
      } else {
        final userCred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = userCred.user!;
        await user.updateDisplayName(username);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Konto skapat!')));
      }

      // --- 2) FIRESTORE: försök skriva profilen, men blockera inte navigation ---
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username.toLowerCase(),
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Logga men låt användaren gå vidare – Auth lyckades ju
        debugPrint('⚠️ Firestore profile write failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Konto skapat, men kunde inte spara profil just nu.',
              ),
            ),
          );
        }
      }

      // --- 3) Navigera vidare oavsett profil-skrivningens resultat ---
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on FirebaseAuthException catch (e) {
      // Visa tydligare auth-fel istället för “något gick fel”
      final msg = switch (e.code) {
        'credential-already-in-use' =>
          'E-postadressen används redan av ett annat konto.',
        'email-already-in-use' => 'E-postadressen är redan registrerad.',
        'invalid-email' => 'Ogiltig e-postadress.',
        'weak-password' => 'Lösenordet är för svagt.',
        _ => (e.message ?? 'Något gick fel vid inloggning.'),
      };
      _showError(msg);
    } catch (e) {
      debugPrint('❌ Unexpected error in _signUp: $e');
      _showError('Något gick fel. Försök igen.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/white_logo.png',
                          height: 137,
                          width: 227,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom * 0.3,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Register",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            cursorWidth: 2.0,
                            decoration: _inputDecoration(
                              context,
                              "Username (valfritt)",
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            cursorWidth: 2.0,
                            decoration: _inputDecoration(context, "Email"),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) => _signUp(),
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            cursorWidth: 2.0,
                            decoration: _inputDecoration(context, "Password"),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                              child: const Text("Create account"),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      floatingLabelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.primary,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
