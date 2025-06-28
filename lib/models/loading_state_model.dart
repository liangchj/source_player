
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
}