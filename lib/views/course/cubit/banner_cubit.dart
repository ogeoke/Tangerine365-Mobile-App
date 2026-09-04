import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/banners.dart';

part 'banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  BannerCubit() : super(const BannerState()) {
    load();
  }

  final _repository = ApiRepository();
  reset() {
    emit(const BannerState());
  }

  load([bool forceCache = true]) async {
    emit(state.copyWith(isLoading: true));

    final response = await _repository.getBanners(forceCache);

    if (response.isSuccessful && response.body is List<Banners>) {
      emit(state.copyWith(data: response.body));
    }

    emit(state.copyWith(isLoading: false));

    if (forceCache) load(false);
  }
}
