int _sequence = 0;

String createId() {
  _sequence += 1;
  return '${DateTime.now().microsecondsSinceEpoch}-$_sequence';
}
