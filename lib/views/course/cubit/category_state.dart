part of 'category_cubit.dart';

class CategoryState extends Equatable {
  final bool isLoading;
  final List<Categories>? data;
  final Categories? selected;

  const CategoryState({this.selected, this.isLoading = false, this.data});

  @override
  List<Object?> get props => [isLoading, data, selected];

  CategoryState copyWith(
      {bool? isLoading, Categories? selected, List<Categories>? data}) {
    return CategoryState(
      selected: selected?.name.toLowerCase() == 'all'
          ? null
          : selected ?? this.selected,
      isLoading: isLoading ?? false,
      data: data ?? this.data,
    );
  }
}
