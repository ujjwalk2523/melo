/// Represents domain/application failures across the Melo application.
class AppFailure {
  final String message;
  final String? code;
  final dynamic cause;

  const AppFailure({required this.message, this.code, this.cause});

  @override
  String toString() => 'AppFailure(message: $message, code: $code)';
}
