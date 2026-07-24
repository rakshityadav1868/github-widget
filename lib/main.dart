import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/services/token_store.dart';
import 'features/onboarding/sign_in_screen.dart';

void main() => runApp(const GitHubWidgetApp());

class GitHubWidgetApp extends StatelessWidget {
  const GitHubWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Widget',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const RootGate(),
    );
  }
}

/// Decides the first screen: sign-in when there's no stored token, otherwise
/// the signed-in landing (replaced by the widget preview in PR #4).
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  final _store = TokenStore();
  bool _loading = true;
  String? _login;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final login = await _store.readLogin();
    if (mounted) {
      setState(() {
        _login = login;
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _store.clear();
    if (mounted) setState(() => _login = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }
    if (_login == null) {
      return SignInScreen(
        onSignedIn: (login) => setState(() => _login = login),
      );
    }
    return _SignedInScreen(login: _login!, onSignOut: _signOut);
  }
}

/// Temporary landing after sign-in. PR #4 replaces this with the animated
/// widget preview.
class _SignedInScreen extends StatelessWidget {
  const _SignedInScreen({required this.login, required this.onSignOut});
  final String login;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GitHub Widget')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 48),
            const SizedBox(height: 16),
            Text('Signed in as @$login',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Widget preview coming next',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            TextButton(onPressed: onSignOut, child: const Text('Sign out')),
          ],
        ),
      ),
    );
  }
}
