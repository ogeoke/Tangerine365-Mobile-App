import 'package:data_repository/data_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sevenup_mobile/constants/env.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/test.dart';
import 'package:sevenup_mobile/models/unit.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/views/playcourse_page.dart';

class UnitsTile extends StatefulWidget {
  final String title;
  final bool isTest;

  const UnitsTile({super.key, required this.title, this.isTest = false});
  @override
  UnitsTileState createState() => UnitsTileState();
}

class UnitsTileState extends State<UnitsTile>
    with SingleTickerProviderStateMixin {
  late Animation<double> _iconTurns;
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).chain(CurveTween(curve: Curves.easeIn)),
    );
    super.initState();
  }

  var env = GetIt.I<Env>();
  @override
  Widget build(BuildContext context) {
    return Consumer<UnitsProvider>(
      builder: (context, state, _) => Column(
        children: <Widget>[
          ExpansionTile(
            onExpansionChanged: (isOpening) {
              if (!state.isLoading &&
                  isOpening &&
                  state.unit == null &&
                  state.test == null) state.loadUnits();
              isOpening ? _controller.forward() : _controller.reverse();
            },
            trailing: RotationTransition(
              turns: _iconTurns,
              child: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).primaryColor.withOpacity(0.8),
              ),
            ),
            title: Text(
              widget.title, //?? 'UNITS',
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 0.07,
                color: Colors.black,
              ),
              maxLines: 4,
            ),
            children: <Widget>[
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: LinearProgressIndicator(),
                ),
              if (state.unit == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    state.errorMessage?.toUpperCase() ?? '',
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              if (state.unit?.isNotEmpty == true)
                for (var item in state.unit ?? <Unit>[])
                  _buildItem(
                    title: item.name ?? '',
                    status: item.status?.toUpperCase() ?? '',
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (c) => PlayCoursePage(
                            auth: GetIt.I<AuthBloc>().state.token ?? '',
                            url: _buildContentURi(state.lessonId, item.id),
                          ),
                        ),
                      );
                    },
                  ),
              if (state.test?.isNotEmpty == true)
                for (var item in state.test ?? <Test>[])
                  _buildItem(
                    title: item.name ?? '',
                    status: item.metadata?.status?.toUpperCase() ?? '',
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (c) => PlayCoursePage(
                            auth: GetIt.I<AuthBloc>().state.token ?? '',
                            url: _buildContentURi(state.lessonId, item.id),
                          ),
                        ),
                      );
                    },
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Uri _buildContentURi(String lessonId, String contentId) {
    var uri = Uri.parse('${env.baseUrl}/external_scorm_player.php');
    var auth = GetIt.I<AuthBloc>();
    uri = uri.replace(
      queryParameters: <String, dynamic>{
        'key': env.scormApiKey,
        'username': auth.state.user?.username,
        'token': auth.state.token,
        'course_id': '-1',
        'lesson_id': lessonId,
        'lesson_content_id': contentId,
      },
    );
    // print(uri.toString());
    return uri;
  }

  Widget _buildItem({
    required String title,
    required String status,
    Function()? onClick,
  }) =>
      InkWell(
        onTap: onClick,
        child: Ink(
          padding: const EdgeInsets.only(right: 20, bottom: 10),
          child: Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 10),
                width: 7,
                height: 60,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 15,
                        letterSpacing: 0.06,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.06,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_right,
                color: Theme.of(context).primaryColor.withOpacity(0.8),
              ),
            ],
          ),
        ),
      );
}

class UnitsProvider with ChangeNotifier {
  final String lessonId;
  List<Unit>? unit;
  List<Test>? test;
  bool isLoading;
  final bool isTest;
  String? errorMessage;
  final _repository = ApiRepository();

  UnitsProvider(this.lessonId, {this.isLoading = false, this.isTest = false});

  Future<void> loadUnits() async {
    isLoading = true;
    notifyListeners();
    // print('refreshing units');
    final response = isTest
        ? await _repository.getTests(lessonId)
        : await _repository.getUnits(lessonId);
    // print(response.body);
    if (response.isSuccessful) {
      if (response.body is List<Unit>) {
        unit = response.body as List<Unit>;
      } else if (response.body is List<Test>) {
        test = response.body as List<Test>;
      }
    } else {
      if (response.error is ApiError) {
        ApiError err = response.error as ApiError;
        errorMessage = err.message;
      } else {
        errorMessage = 'Could not load ${isTest ? 'test' : 'unit'}';
      }
    }
    isLoading = false;
    notifyListeners();
  }
}
