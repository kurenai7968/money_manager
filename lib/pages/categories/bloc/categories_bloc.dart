import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc(this._repository, {this.transactions})
    : super(const CategoriesState()) {
    on<CategoriesStarted>(_onCategoriesStarted);
    on<CategorySavePressed>(_onCategorySavePressed);
    on<CategoryDeletePressed>(_onCategoryDeletePressed);
    on<CategoriesReorderPressed>(_onCategoriesReorderPressed);
  }

  final CategoryRepository _repository;
  final TransactionRepository? transactions;

  Future<void> _onCategoriesStarted(
    CategoriesStarted event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CategoriesStatus.loading,
        error: CategoriesError.none,
      ),
    );
    try {
      if (await _repository.isEmpty()) {
        for (final category in event.defaults) {
          await _repository.save(category);
        }
      }
      final categories = await _repository.getAll();
      emit(
        state.copyWith(
          status: CategoriesStatus.success,
          categories: categories,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CategoriesStatus.failure,
          error: CategoriesError.saveFailed,
        ),
      );
    }
  }

  Future<void> _onCategorySavePressed(
    CategorySavePressed event,
    Emitter<CategoriesState> emit,
  ) async {
    if (!event.category.hasLabel) {
      emit(
        state.copyWith(
          status: CategoriesStatus.failure,
          error: CategoriesError.nameRequired,
        ),
      );
      return;
    }
    try {
      await _repository.save(event.category);
      final categories = await _repository.getAll();
      emit(
        state.copyWith(
          status: CategoriesStatus.success,
          categories: categories,
          error: CategoriesError.none,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CategoriesStatus.failure,
          error: CategoriesError.saveFailed,
        ),
      );
    }
  }

  Future<void> _onCategoryDeletePressed(
    CategoryDeletePressed event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      final existing = state.categories.where(
        (category) => category.id == event.id,
      );
      final source = transactions;
      final used = source == null ? 0 : await source.countForCategory(event.id);
      if (existing.isNotEmpty && used > 0) {
        await _repository.save(existing.first.copyWith(archived: true));
      } else {
        await _repository.delete(event.id);
      }
      final categories = await _repository.getAll();
      emit(
        state.copyWith(
          status: CategoriesStatus.success,
          categories: categories,
          error: CategoriesError.none,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CategoriesStatus.failure,
          error: CategoriesError.saveFailed,
        ),
      );
    }
  }

  Future<void> _onCategoriesReorderPressed(
    CategoriesReorderPressed event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      await _repository.reorder(event.ids);
      final categories = await _repository.getAll();
      emit(
        state.copyWith(
          status: CategoriesStatus.success,
          categories: categories,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CategoriesStatus.failure,
          error: CategoriesError.saveFailed,
        ),
      );
    }
  }
}
