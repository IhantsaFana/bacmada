import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final VoidCallback onToggle;

  const AuthForm({super.key, required this.isLogin, required this.onToggle});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      if (widget.isLogin) {
        await authService.signInWithEmailAndPassword(email, password);
      } else {
        await authService.signUpWithEmailAndPassword(email, password);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      await authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.blue.shade50, blurRadius: 10)],
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              widget.isLogin ? 'Connexion' : 'Créer un compte',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email, color: Colors.indigo),
                labelText: 'Adresse e-mail',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value != null && value.contains('@')
                  ? null
                  : 'Email invalide',
              onChanged: (value) => email = value,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, color: Colors.indigo),
                labelText: 'Mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              obscureText: true,
              validator: (value) => value != null && value.length >= 6
                  ? null
                  : 'Min. 6 caractères',
              onChanged: (value) => password = value,
              enabled: !_isLoading,
            ),
            if (!widget.isLogin) ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.indigo,
                  ),
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                obscureText: true,
                validator: (value) => value == password
                    ? null
                    : 'Les mots de passe ne correspondent pas',
                onChanged: (value) => confirmPassword = value,
                enabled: !_isLoading,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(widget.isLogin ? Icons.login : Icons.person_add),
                label: Text(
                  widget.isLogin ? 'Se connecter' : 'Créer un compte',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : _handleSubmit,
              ),
            ),
            if (!kIsWeb) ...[
              // N'afficher le bouton Google que sur mobile
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.g_translate, color: Colors.red),
                  label: const Text('Continuer avec Google'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : widget.onToggle,
              child: Text(
                widget.isLogin
                    ? 'Pas encore de compte ? Inscrivez-vous'
                    : 'Déjà un compte ? Connectez-vous',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
