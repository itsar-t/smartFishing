import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Register page matching the LoginPage layout:
/// - Logo pinned to the top
/// - Form + button pinned to the bottom (even on tall screens)
/// - Still scrollable so nothing gets hidden behind the keyboard
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Firebase refs
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // Always dispose to avoid leaks
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Creates a user account:
  /// 1) Validates inputs
  /// 2) Ensures username is unique (case-insensitive)
  /// 3) Creates Firebase Auth user
  /// 4) Stores username/email in Firestore under /users/{uid}
  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Basic client-side checks for nicer UX
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Fyll i alla fält.');
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
      // 1) Ensure username uniqueness (case-insensitive)
      final existing = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        _showError('Användarnamnet är redan taget.');
        return;
      }

      // 2) Create auth user
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        _showError('Kunde inte skapa användare, försök igen.');
        return;
      }

      // 3) Persist profile in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'username': username.toLowerCase(), // store lowercased for lookups
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4) Update display name (nice-to-have)
      await user.updateDisplayName(username);

      // Optional: send email verification (uncomment if you want this flow)
      // await user.sendEmailVerification();

      if (!mounted) return;
      // Pop back to Login after a successful registration
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Okänt fel vid registrering.');
    } catch (_) {
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
      // Match app background with your theme primary
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        // LayoutBuilder gives us the viewport height → lets us pin bottom section
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // Give Column a **real height** to make spaceBetween work
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ---------- TOP SECTION ----------
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

                    // ---------- BOTTOM SECTION ----------
                    // Keep padding responsive to keyboard to avoid hugging the edge
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

                          // Username
                          TextField(
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            cursorWidth: 2.0,
                            decoration: _inputDecoration(context, "Username"),
                          ),
                          const SizedBox(height: 16),

                          // Email
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

                          // Password
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

  // Same decoration helper as LoginPage for consistent styling
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
