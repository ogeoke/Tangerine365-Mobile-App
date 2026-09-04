import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/categories.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(const CategoryState());

  final _repository = ApiRepository();

  reset() {
    emit(const CategoryState());
  }

  selectCategory(Categories category) {
    emit(state.copyWith(selected: category));
  }

  load() async {
    emit(state.copyWith(isLoading: true));

    final response = await _repository.getCategories();

    if (response.body is List<Categories>) {
      emit(state.copyWith(data: response.body));
    }

    emit(state.copyWith(isLoading: false));
  }
}
