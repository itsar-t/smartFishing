import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_page.dart';

/// Login page that allows sign-in by either email or username + password.
/// Layout goal:
/// - Logo + title stay at the top
/// - Fields + buttons are stuck to the bottom (even on tall screens)
/// - Still scrollable when the keyboard opens (so nothing gets hidden)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers for the two fields (identifier and password)
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Firebase references
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Attempts to sign in the user.
  /// If the identifier contains '@' we treat it as an email.
  /// Otherwise we look up the email by username in Firestore.
  Future<void> _signIn() async {
    try {
      String email;
      final String identifier = _identifierController.text.trim();
      final String password = _passwordController.text.trim();

      if (identifier.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-info',
          message: 'Fyll i båda fälten.',
        );
      }

      // If user typed an email → use it directly.
      // Otherwise, resolve username → email via Firestore.
      if (identifier.contains('@')) {
        email = identifier;
      } else {
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: identifier.toLowerCase())
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          email = querySnapshot.docs.first.data()['email'] as String;
        } else {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Inget konto hittades.',
          );
        }
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Okänt fel vid inloggning"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      // Fallback for any unexpected error types
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Något gick fel. Försök igen."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _signInAsGuest() async {
    try {
      await _auth.signInAnonymously();
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logged in as guest")));

      // Navigera till din huvudskärm
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Failed to sign in as guest"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background is your theme primary (dark blue in your setup)
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // SafeArea prevents content from overlapping notches / status bar
      body: SafeArea(
        // LayoutBuilder gives us the viewport height (constraints.maxHeight)
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // We still keep it scrollable so the UI can move when keyboard opens
              padding: const EdgeInsets.symmetric(horizontal: 16.0),

              // ❗ The magic: ConstrainedBox with minHeight = viewport height
              // This gives the Column a *real height* to work with so that
              // MainAxisAlignment.spaceBetween can push the bottom section down.
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),

                // This Column has two children:
                // 1) The top section (logo + title)
                // 2) The bottom section (fields + buttons)
                // spaceBetween will push them apart vertically.
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
                    // Small bottom padding helps when the keyboard is open:
                    // it adds some breathing space so the button doesn't hug the edge.
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom * 0.3,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Login",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                          ),

                          const SizedBox(height: 24),

                          TextField(
                            controller: _identifierController,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            cursorWidth: 2.0,
                            decoration: _inputDecoration(
                              context,
                              "Username or Email",
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) => _signIn(),
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            cursorWidth: 2.0,
                            decoration: _inputDecoration(context, "Password"),
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                              child: const Text("Sign In"),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              "No account? Register here",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: _signInAsGuest,
                            child: Text(
                              "Continue as Guest",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              // TODO: implement forgot password flow
                              // You could use FirebaseAuth.instance
                              //   .sendPasswordResetEmail(email: ...)
                              // after resolving the email like in _signIn().
                            },
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
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

  // Small helper to avoid repeating identical InputDecoration code.
  // Tip: extracted so that you can tweak styling in one place.
  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      floatingLabelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.primary,

      // Borders for different states
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
