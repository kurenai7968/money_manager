class AppException implements Exception {
  final String message;
  final Object? cause;

  const AppException(this.message, {this.cause});

  @override
  String toString() {
    final cause = this.cause;
    if (cause == null) return message;
    return '$message ($cause)';
  }
}

class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}

/// Runs [action] and wraps any non-[AppException] error as [CacheException].
Future<T> guard<T>(String message, Future<T> Function() action) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } catch (error, stackTrace) {
    Error.throwWithStackTrace(
      CacheException(message, cause: error),
      stackTrace,
    );
  }
}
