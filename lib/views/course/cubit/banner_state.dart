part of 'banner_cubit.dart';

class BannerState extends Equatable {
  final bool isLoading;
  final List<Banners>? data;

  const BannerState({
    this.data,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [isLoading, data];

  BannerState copyWith({bool? isLoading, List<Banners>? data}) {
    return BannerState(
      isLoading: isLoading ?? false,
      data: data ?? this.data,
    );
  }
}
