import 'package:date_format/date_format.dart';
import 'package:sevenup_mobile/common/page_scaffold.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/extensions/date.dart';
import 'package:sevenup_mobile/gen/fonts.gen.dart';
import 'package:sevenup_mobile/models/stats.dart';
import 'package:sevenup_mobile/state/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

extension on String {
  /// capitalize the first letter of a string
  // String capitalizeFirst() {
  //   if (isEmpty) return '';
  //   return replaceRange(0, 1, this[0].toUpperCase());
  // }
}

class MyStatPage extends StatefulWidget {
  static const routeName = '/mystat_page';
  const MyStatPage({
    super.key,
  });
  // final DashboardItem item;

  @override
  MyStatPageState createState() => MyStatPageState();
}

class MyStatPageState extends State<MyStatPage> {
  late StatProvider _provider;

  @override
  void initState() {
    _provider = StatProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {};
    dataMap.putIfAbsent("Flutter", () => 5);
    dataMap.putIfAbsent("React", () => 3);
    dataMap.putIfAbsent("Xamarin", () => 2);
    dataMap.putIfAbsent("Ionic", () => 2);
    TextStyle? title = Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        // fontFamily: AppFont.BAHNSCRIFT,
        letterSpacing: .1);
    TextStyle? body = Theme.of(context).textTheme.bodyLarge?.copyWith(
        letterSpacing: .1,
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        fontFamily: FontFamily.jost
        // fontFamily: AppFont.BAHNSCRIFT
        );
    return ChangeNotifierProvider(
        create: (_) => _provider,
        child: PageScaffold(
            title: 'My Activity',
            parent: SmartRefresher(
              enablePullDown: true,
              scrollController: _provider.scrollController,
              controller: _provider.refreshController,
              onRefresh: _provider.onRefresh,
            ),
            content: Consumer<StatProvider>(
                builder: (context, state, _) => _provider.stats == null
                    ? const SizedBox.shrink()
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Text('GENERAL',
                                    style: title, textAlign: TextAlign.start),
                              ),
                              for (var item in [
                                ('Name: ', state.stats?.general?.name ?? ''),
                                (
                                  'User type: ',
                                  state.stats?.general?.userType ?? ''
                                ),
                                (
                                  'Member Since: ',
                                  DateTime.tryParse(state.stats?.general
                                                  ?.memberSince ??
                                              '')
                                          ?.readableFormat ??
                                      ''
                                ),
                              ])
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 2.0),
                                  child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(text: item.$1, style: body),
                                        TextSpan(
                                            text: item.$2,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500)),
                                      ]),
                                      style: body),
                                ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                    'Course Activity Graph'.toUpperCase(),
                                    style: title,
                                    textAlign: TextAlign.start),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: PieChart(
                                  dataMap: {
                                    // 'Subscribed': state
                                    //         .stats?.courseAttendance?.subscribed
                                    //         ?.toDouble() ??
                                    //     0,
                                    'Total': state.stats?.courseAttendance
                                            ?.totalCourses
                                            ?.toDouble() ??
                                        0,
                                    'waiting': state
                                            .stats?.courseAttendance?.waiting
                                            ?.toDouble() ??
                                        0,
                                    'In progress': state
                                            .stats?.courseAttendance?.inProgress
                                            ?.toDouble() ??
                                        0,
                                    'Not Started': state
                                            .stats?.courseAttendance?.notStarted
                                            ?.toDouble() ??
                                        0,
                                    'Suspended': state
                                            .stats?.courseAttendance?.suspended
                                            ?.toDouble() ??
                                        0,
                                    // 'Others': state
                                    //         .stats?.courseAttendance?.others
                                    //         ?.toDouble() ??
                                    //     0,
                                    'Completed': state
                                            .stats?.courseAttendance?.completed
                                            ?.toDouble() ??
                                        0,
                                  },
                                  animationDuration:
                                      const Duration(milliseconds: 800),
                                  chartLegendSpacing: 32.0,
                                  chartRadius:
                                      MediaQuery.of(context).size.width * .35,

                                  // showChartValuesInPercentage: true,
                                  // showChartValues: true,
                                  // showChartValuesOutside: false,
                                  // chartValueBackgroundColor: Colors.grey[200],
                                  colorList: const [
                                    Color.fromARGB(255, 33, 240, 243),
                                    Colors.red,
                                    Colors.amber,
                                    Colors.green,
                                    Colors.indigo,
                                    Colors.tealAccent,
                                    Color.fromARGB(255, 20, 106, 130)
                                  ],
                                  // showLegends: true,
                                  // legendPosition: LegendPosition.right,
                                  // decimalPlaces: 1,
                                  // showChartValueLabel: true,
                                  // initialAngle: 0,
                                  // legendStyle: defaultLegendStyle.copyWith(),
                                  // chartValueStyle:
                                  //     defaultChartValueStyle.copyWith(
                                  //   color: Theme.of(context).primaryColor,
                                  // ),
                                  chartType: ChartType.ring,
                                ),
                              ),

                              const SizedBox(height: 40),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Text('Certificates'.toUpperCase(),
                                    style: title, textAlign: TextAlign.start),
                              ),
                              for (var item in [
                                (
                                  'Certificates attained: ',
                                  state.stats?.certificatesAttained ?? ''
                                ),
                                (
                                  'Competencies attained: ',
                                  state.stats?.competenciesAttained ?? ''
                                ),
                                (
                                  'Last login: ',
                                  '${DateTime.tryParse(state.stats?.lastLogin ?? '')?.readableFormat ?? ''} ${DateTime.tryParse(state.stats?.lastLogin ?? '')?.time ?? ''}'
                                ),
                              ])
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 2.0),
                                  child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(text: item.$1, style: body),
                                        TextSpan(
                                            text: item.$2.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500)),
                                      ]),
                                      style: body),
                                ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 4.0),
                              //   child: Text('COMMUNICATION',
                              //       style: title, textAlign: TextAlign.start),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Total Folders: ${state.stats?.communication?.numberPersonalFolders ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Total Files: ${state.stats?.communication?.numberFiles ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Total Comments: ${state.stats?.communication?.numberComments ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Total Forum Messages: ${state.stats?.communication?.numberForumMessages ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Total Personal Messages: ${state.stats?.communication?.numberPersonalFolders ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Total Size: ${state.stats?.communication?.totalSize ?? ''}  KB',
                              //       style: body),
                              // ),
                              // const SizedBox(height: 20),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 4.0),
                              //   child: Text('LEARNING PATH',
                              //       style: title, textAlign: TextAlign.start),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 4.0),
                              //   child: Text('COURSES',
                              //       style: body?.copyWith(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w600),
                              //       textAlign: TextAlign.start),
                              // ),

                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Number of Courses Assigned: ${state.stats?.courseAttendance?.totalCourses ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Number of Courses Subscribed: ${state.stats?.courseAttendance?.subscribed ?? ''}',
                              //       style: body),
                              // ),
                              // const SizedBox(height: 20),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 4.0),
                              //   child: Text('LESSONS',
                              //       style: body?.copyWith(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w600),
                              //       textAlign: TextAlign.start),
                              // ),
                              // PieChart(
                              //   dataMap: {
                              //     'completed': state
                              //             .stats?.learning?.completedLessons
                              //             ?.toDouble() ??
                              //         0,
                              //     'Outstanding': state
                              //             .stats?.learning?.assignedLessons
                              //             ?.toDouble() ??
                              //         0
                              //   },
                              //   animationDuration:
                              //       const Duration(milliseconds: 800),
                              //   chartLegendSpacing: 32.0,
                              //   chartRadius:
                              //       MediaQuery.of(context).size.width / 2.7,
                              //   // showChartValuesInPercentage: true,
                              //   // showChartValues: true,
                              //   // showChartValuesOutside: false,
                              //   // chartValueBackgroundColor: Colors.grey[200],
                              //   colorList: [
                              //     Theme.of(context).primaryColor,
                              //     Colors.blue
                              //   ],
                              //   // showLegends: true,
                              //   // legendPosition: LegendPosition.right,
                              //   // decimalPlaces: 1,
                              //   // showChartValueLabel: true,
                              //   // initialAngle: 0,
                              //   // chartValueStyle:
                              //   //     defaultChartValueStyle.copyWith(
                              //   //   color: Theme.of(context).primaryColor,
                              //   // ),
                              //   chartType: ChartType.ring,
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Number of Lessons Assigned: ${state.stats?.learning?.assignedLessons ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Number of Lessons Completed: ${state.stats?.learning?.completedLessons ?? ''}',
                              //       style: body),
                              // ),
                              // const SizedBox(height: 20),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 4.0),
                              //   child: Text('TEST',
                              //       style: body?.copyWith(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w600),
                              //       textAlign: TextAlign.start),
                              // ),
                              // PieChart(
                              //   dataMap: {
                              //     'Failed': state.stats?.learning?.failedTests
                              //             ?.toDouble() ??
                              //         0,
                              //     'Incomplete': state
                              //             .stats?.learning?.attemptedTests
                              //             ?.toDouble() ??
                              //         0
                              //   },
                              //   animationDuration:
                              //       const Duration(milliseconds: 800),
                              //   chartLegendSpacing: 32.0,
                              //   chartRadius:
                              //       MediaQuery.of(context).size.width / 2.7,
                              //   // showChartValuesInPercentage: true,
                              //   // showChartValues: true,
                              //   // showChartValuesOutside: false,
                              //   // chartValueBackgroundColor: Colors.grey[200],
                              //   colorList: [
                              //     Theme.of(context).primaryColor,
                              //     Colors.blue
                              //   ],
                              //   // showLegends: true,
                              //   // legendPosition: LegendPosition.right,
                              //   // decimalPlaces: 1,
                              //   // showChartValueLabel: true,
                              //   // initialAngle: 0,
                              //   // chartValueStyle:
                              //   //     defaultChartValueStyle.copyWith(
                              //   //   color: Theme.of(context).primaryColor,
                              //   // ),
                              //   chartType: ChartType.ring,
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Number of Tests Assigned: ${state.stats?.learning?.assignedTests ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Number of Tests Attempted: ${state.stats?.learning?.attemptedTests ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Number of Tests Passed: ${state.stats?.learning?.passedTests ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Number of Tests Failed: ${state.stats?.learning?.failedTests ?? ''}',
                              //       style: body),
                              // ),
                              // const SizedBox(height: 20),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 4.0),
                              //   child: Text('USAGE',
                              //       style: title, textAlign: TextAlign.start),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Last Login IP: ${state.stats?.usage?.lastIp ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Last Login Time: ${formatDateUtil(formatedSrting: state.stats?.usage?.lastLoginTimestamp ?? '')}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Average Week usage (minutes): ${state.stats?.usage?.weekMeanDuration ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Average Month Usage (minutes):  ${state.stats?.usage?.monthMeanDuration ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Average Usage (minutes): ${state.stats?.usage?.meanDuration ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Total Week Logins: ${state.stats?.usage?.totalWeekLogins ?? ''} ',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Total Month Logins: ${state.stats?.usage?.totalMonthLogins ?? ''}',
                              //       style: body),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 8.0, vertical: 2.0),
                              //   child: Text(
                              //       'Average Logins: ${state.stats?.usage?.totalMonthLogins ?? ''}',
                              //       style: body),
                              // ),
                              const SizedBox(height: 50)
                            ],
                          ),
                        ),
                      ))));
  }

  String formatDateUtil(
      {required String formatedSrting,
      String delimeter = '/',
      bool isDateTime = true}) {
    var milliseconds = int.tryParse(formatedSrting, radix: 10);
    // print(DateTime.tryParse(formatedSrting));
    if (milliseconds == null) return '';
    DateTime d =
        DateTime.fromMillisecondsSinceEpoch(1581072986 * 1000, isUtc: false);
    //  print(d);

    return isDateTime
        ? formatDate(
            d, [dd, delimeter, mm, delimeter, yyyy, ' ', hh, ':', nn, ':', ss])
        : formatDate(d, [yyyy, delimeter, mm, delimeter, dd]);
  }
}

class StatProvider extends MyProvider {
  Stats? stats;
  final _repository = ApiRepository();

  @override
  Future<void> onRefresh() async {
    final response = await _repository.getStats();
    if (response.body is Stats) stats = response.body;
    refreshController.refreshCompleted();
    notify(stats);
  }
}
