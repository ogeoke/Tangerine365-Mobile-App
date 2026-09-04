part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool isLoading;
  final Settings? data;

  const SettingsState({this.isLoading = false, this.data});

  @override
  List<Object?> get props => [isLoading, data];

  SettingsState copyWith({bool? isLoading, Settings? data}) {
    return SettingsState(
      isLoading: isLoading ?? false,
      data: data ?? this.data,
    );
  }
}
