import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/models/github_stats.dart';
import 'data/sample_stats.dart';
import 'data/services/github_api.dart';
import 'data/services/token_store.dart';
import 'data/services/widget_updater.dart';
import 'features/onboarding/sign_in_screen.dart';
import 'features/preview/preview_screen.dart';

void main() => runApp(const GitHubWidgetApp());

class GitHubWidgetApp extends StatelessWidget {
  const GitHubWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const RootGate(),
    );
  }
}

/// Decides the first screen: sign-in when there's no stored token, otherwise
/// the live widget preview.
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

  void _previewSample() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewScreen(
          stats: sampleGitHubStats(),
          subtitle: 'Sample data - sign in to see your own stats.',
        ),
      ),
    );
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
        onPreview: _previewSample,
      );
    }
    return _SignedInHome(login: _login!, onSignOut: _signOut);
  }
}

/// Loads the signed-in user's real stats and shows the preview. Falls back to
/// sample data if the live fetch fails (e.g. no network yet).
class _SignedInHome extends StatefulWidget {
  const _SignedInHome({required this.login, required this.onSignOut});
  final String login;
  final VoidCallback onSignOut;

  @override
  State<_SignedInHome> createState() => _SignedInHomeState();
}

class _SignedInHomeState extends State<_SignedInHome> {
  final _store = TokenStore();
  late final Future<GitHubStats> _future = _load();

  Future<GitHubStats> _load() async {
    final token = await _store.readToken();
    if (token == null) throw StateError('No token');
    final api = GitHubApi(token: token);
    try {
      final stats = await api.fetchStats(widget.login);
      await WidgetUpdater.update(stats);
      return stats;
    } finally {
      api.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GitHubStats>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          );
        }
        if (snapshot.hasError) {
          return PreviewScreen(
            stats: sampleGitHubStats(),
            subtitle: "Couldn't load your live stats yet - showing sample.",
            onSignOut: widget.onSignOut,
          );
        }
        return PreviewScreen(
          stats: snapshot.data!,
          subtitle: 'Signed in as @${widget.login}',
          onSignOut: widget.onSignOut,
        );
      },
    );
  }
}
