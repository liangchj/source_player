
class LoadingStateModel<T> {
  bool loading;
  String? errorMsg;
  bool loadedSuc;
  T? data;
  LoadingStateModel({
    this.loading = true,
    this.errorMsg,
    this.loadedSuc = false,
    this.data,
  });

  LoadingStateModel copyWith({
    bool? loading,
    String? errorMsg,
    bool? loadedSuc,
    T? data,
  }) {
    return LoadingStateModel(
      loading: loading ?? this.loading,
      errorMsg: errorMsg ?? this.errorMsg,
      loadedSuc: loadedSuc ?? this.loadedSuc,
      data: data ?? this.data,
    );
  }
}