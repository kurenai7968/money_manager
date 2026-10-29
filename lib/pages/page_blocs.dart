import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

bool hasBloc<T>(BuildContext context) {
  try {
    context.read<T>();
    return true;
  } on ProviderNotFoundException {
    return false;
  }
}
