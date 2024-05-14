import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/network/res.dart';

abstract class LoadingState<T extends StatefulWidget, S extends Object> extends State<T>{
  bool isLoading = false;

  S? data;

  String? error;

  Future<Res<S>> loadData();

  Widget buildContent(BuildContext context, S data);

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error!),
          const SizedBox(height: 12),
          Button(
            onPressed: () {
              setState(() {
                isLoading = true;
                error = null;
              });
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
            },
            child: const Text("Retry"),
          )
        ],
      ),
    ).paddingHorizontal(16);
  }

  @override
  @mustCallSuper
  void initState() {
    isLoading = true;
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return const Center(
        child: ProgressRing(),
      );
    } else if (error != null){
      return buildError();
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
        var message = value.errorMessage ?? "Network Error";
        if(message == "No more data") {
          return;
        }
        if(message.length > 20) {
          message = "${message.substring(0, 20)}...";
        }
        context.showToast(message: message);
      }
    });
  }

  void reset() {
    setState(() {
      _isFirstLoading = true;
      _isLoading = false;
      _data = null;
      _error = null;
      _page = 1;
    });
    firstLoad();
  }

  void firstLoad() {
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
  }

  @override
  void initState() {
    firstLoad();
    super.initState();
  }

  Widget buildLoading(BuildContext context) {
    return const Center(
      child: ProgressRing(),
    );
  }

  Widget buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error),
          const SizedBox(height: 12),
          Button(
            onPressed: () {
              reset();
            },
            child: const Text("Retry"),
          )
        ],
      ),
    ).paddingHorizontal(16);
  }

  @override
  Widget build(BuildContext context) {
    if(_isFirstLoading){
      return buildLoading(context);
    } else if (_error != null){
      return buildError(context, _error!);
    } else {
      return buildContent(context, _data!);
    }
  }
}
