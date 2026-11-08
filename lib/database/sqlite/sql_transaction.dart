part of 'app_database.dart';

class _SqlTransaction with _SqlExecutorMethods implements SqlExecutor {
  @override
  final DatabaseExecutor _executor;

  _SqlTransaction(this._executor);
}
