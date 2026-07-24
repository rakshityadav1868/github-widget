/// App configuration.
///
/// [githubClientId] is the **public** Client ID of the GitHub OAuth App used
/// for the device-flow sign-in. It is safe to ship in the app (it is not a
/// secret). Create the OAuth App at https://github.com/settings/developers,
/// enable "Device Flow", and paste its Client ID here.
class AppConfig {
  const AppConfig._();

  static const String githubClientId = 'Ov23licTpi3rjp7lUUoH';

  /// OAuth scopes. `read:user` covers the signed-in user's profile and their
  /// own private contribution counts in the calendar.
  static const List<String> githubScopes = ['read:user'];

  static bool get isConfigured =>
      githubClientId.isNotEmpty && githubClientId != 'YOUR_GITHUB_CLIENT_ID';
}
