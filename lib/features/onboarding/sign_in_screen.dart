import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';
import '../../data/services/github_api.dart';
import '../../data/services/github_auth.dart';
import '../../data/services/token_store.dart';

/// Sign in with GitHub using the OAuth device flow.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.onSignedIn, this.onPreview});

  /// Called with the signed-in username once a token is stored.
  final ValueChanged<String> onSignedIn;

  /// Optional: preview the widget with sample data without signing in.
  final VoidCallback? onPreview;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

enum _Stage { idle, requesting, awaitingUser, verifying, error }

class _SignInScreenState extends State<SignInScreen> {
  final _auth = GitHubAuth(
    clientId: AppConfig.githubClientId,
    scopes: AppConfig.githubScopes,
  );
  final _store = TokenStore();

  _Stage _stage = _Stage.idle;
  DeviceCodeResponse? _code;
  String? _error;

  @override
  void dispose() {
    _auth.close();
    super.dispose();
  }

  Future<void> _start() async {
    if (!AppConfig.isConfigured) {
      setState(() {
        _stage = _Stage.error;
        _error = 'GitHub sign-in isn\'t set up yet. Add the OAuth Client ID in '
            'lib/core/config.dart.';
      });
      return;
    }
    setState(() {
      _stage = _Stage.requesting;
      _error = null;
    });
    try {
      final code = await _auth.requestDeviceCode();
      setState(() {
        _code = code;
        _stage = _Stage.awaitingUser;
      });
      final token = await _auth.pollForToken(code);
      setState(() => _stage = _Stage.verifying);
      final api = GitHubApi(token: token);
      final login = await api.fetchViewerLogin();
      api.close();
      await _store.save(token: token, login: login);
      if (mounted) widget.onSignedIn(login);
    } catch (e) {
      final message = e is GitHubAuthException || e is GitHubApiException
          ? e.toString().split(': ').skip(1).join(': ')
          : 'Something went wrong. Please try again.';
      setState(() {
        _stage = _Stage.error;
        _error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_stage) {
      case _Stage.awaitingUser:
        return _CodeStep(code: _code!);
      case _Stage.requesting:
      case _Stage.verifying:
        return const _Loading();
      case _Stage.idle:
      case _Stage.error:
        return _Intro(
          error: _error,
          onPressed: _start,
          onPreview: widget.onPreview,
        );
    }
  }
}

class _Intro extends StatelessWidget {
  const _Intro({this.error, required this.onPressed, this.onPreview});
  final String? error;
  final VoidCallback onPressed;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.grid_view_rounded, size: 56),
        const SizedBox(height: 20),
        Text('GitHub Widget',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Sign in to show your live stats on your home screen.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.code),
          label: const Text('Sign in with GitHub'),
        ),
        if (onPreview != null) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: onPreview,
            child: const Text('Preview with sample data'),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 20),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({required this.code});
  final DeviceCodeResponse code;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Enter this code on GitHub',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        SelectableText(
          code.userCode,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: 6,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => Clipboard.setData(ClipboardData(text: code.userCode)),
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy code'),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => launchUrl(
            Uri.parse(code.verificationUri),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Open GitHub'),
        ),
        const SizedBox(height: 28),
        const _Loading(label: 'Waiting for you to authorize…'),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({this.label});
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        if (label != null) ...[
          const SizedBox(height: 16),
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}
