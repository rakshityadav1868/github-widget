/// App configuration.
///
/// [githubClientId] is the **public** Client ID of the GitHub OAuth App. It is
/// safe to ship in the app (it is not a secret). The client *secret* lives only
/// on the auth backend (see `server/`), never here.
class AppConfig {
  const AppConfig._();

  static const String githubClientId = 'Ov23licTpi3rjp7lUUoH';

  /// OAuth scopes. `read:user` covers the signed-in user's profile and their
  /// own private contribution counts in the calendar.
  static const List<String> githubScopes = ['read:user'];

  /// Deep-link scheme + redirect the OAuth flow returns to. Must match the
  /// GitHub OAuth App's "Authorization callback URL" (githubwidget://callback)
  /// and the Android manifest intent-filter.
  static const String authCallbackScheme = 'githubwidget';
  static const String authRedirectUri = 'githubwidget://callback';

  /// The deployed auth backend that exchanges the code for a token.
  /// Set this to your Cloudflare Worker URL (see server/README.md).
  static const String authBackendUrl =
      'https://github-widget-auth.yadavrakshit60.workers.dev';

  static bool get isConfigured =>
      githubClientId.isNotEmpty &&
      githubClientId != 'YOUR_GITHUB_CLIENT_ID' &&
      authBackendUrl.startsWith('http');
}
