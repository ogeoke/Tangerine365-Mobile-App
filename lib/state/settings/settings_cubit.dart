import 'package:equatable/equatable.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    load();
  }

  final _repository = ApiRepository();
  reset() {
    emit(const SettingsState());
  }

  load([bool forceCache = true]) async {
    emit(state.copyWith(isLoading: true));

    final response = await _repository.settings(forceCache);

    if (response.isSuccessful && response.body is Settings) {
      emit(state.copyWith(data: response.body));
    }

    emit(state.copyWith(isLoading: false));

    if (forceCache) load(false);
  }
}
