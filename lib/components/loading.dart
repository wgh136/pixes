import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/res.dart';

abstract class LoadingState<T extends StatefulWidget, S extends Object> extends State<T>{
  bool isLoading = true;

  S? data;

  String? error;

  Future<Res<S>> loadData();

  Widget buildContent(BuildContext context, S data);

  @override
  Widget build(BuildContext context) {
    if(isLoading){
      loadData().then((value) {
        if(value.success) {
          setState(() {
            isLoading = false;
            data = value.data;
          });
        } else {
          setState(() {
            isLoading = false;
            error = value.errorMessage!;
          });
        }
      });
      return const Center(
        child: ProgressRing(),
      );
    } else if (error != null){
      return Center(
        child: Text(error!),
      );
    } else {
      return buildContent(context, data!);
    }
  }
}

abstract class MultiPageLoadingState<T extends StatefulWidget, S extends Object> extends State<T>{
  bool _isFirstLoading = true;

  bool _isLoading = false;

  List<S>? _data;

  String? _error;

  int _page = 1;

  Future<Res<List<S>>> loadData(int page);

  Widget buildContent(BuildContext context, final List<S> data);

  bool get isLoading => _isLoading || _isFirstLoading;

  void nextPage() {
    if(_isLoading) return;
    _isLoading = true;
    loadData(_page).then((value) {
      _isLoading = false;
      if(value.success) {
        _page++;
        setState(() {
          _data!.addAll(value.data);
        });
      } else {
        context.showToast(message: "Network Error");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_isFirstLoading){
      loadData(_page).then((value) {
        if(value.success) {
          _page++;
          setState(() {
            _isFirstLoading = false;
            _data = value.data;
          });
        } else {
          setState(() {
            _isFirstLoading = false;
            _error = value.errorMessage!;
          });
        }
      });
      return const Center(
        child: ProgressRing(),
      );
    } else if (_error != null){
      return Center(
        child: Text(_error!),
      );
    } else {
      return buildContent(context, _data!);
    }
  }
}
