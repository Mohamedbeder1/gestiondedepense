import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatefulWidget {
  final Map<String, double> monthTotals;

  const LineChartWidget(this.monthTotals, {Key? key}) : super(key: key);

  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime(2025, 1, 1),
    end: DateTime(2025, 12, 31),
  );

  String _getIntervalType() {
    final days =
        selectedDateRange.end.difference(selectedDateRange.start).inDays;
    if (days <= 31) {
      return 'days';
    } else if (days <= 90) {
      return 'weeks';
    } else {
      return 'months';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    final intervalType = _getIntervalType();

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final pickedRange = await showDateRangePicker(
              context: context,
              initialDateRange: selectedDateRange,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );

            if (pickedRange != null) {
              setState(() {
                selectedDateRange = pickedRange;
              });
            }
          },
          child: Text(
            'Select Date Range: ${_formatDate(selectedDateRange.start)} - ${_formatDate(selectedDateRange.end)}',
            style: TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: filteredData,
                    isCurved: true,
                    barWidth: 4,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                ],
                borderData: FlBorderData(
                  border: Border.all(color: Colors.grey.shade300),
                  show: true,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: _getBottomTitles(intervalType),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    //tooltipBackgroundColor:Colors.blueAccent, // Fixed property name
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final date =
                            _getDateFromSpot(touchedSpot.x, intervalType);
                        return LineTooltipItem(
                          '${_formatDateForTooltip(date)}\n\$${touchedSpot.y.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getFilteredData() {
    final intervalType = _getIntervalType();
    List<FlSpot> spots = [];

    if (intervalType == 'days') {
      // Handle daily data
      int dayIndex = 0;
      for (DateTime date = selectedDateRange.start;
          date.isBefore(selectedDateRange.end.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        // Get the value from the total of the month this day belongs to
        final monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';
        final monthTotal = widget.monthTotals[monthKey] ?? 0.0;

        // For simplicity, divide the month total by the days in that month
        final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
        final dailyValue = monthTotal / daysInMonth;

        spots.add(FlSpot(dayIndex.toDouble(), dailyValue));
        dayIndex++;
      }
    } else if (intervalType == 'weeks') {
      // Handle weekly data
      final totalDays =
          selectedDateRange.end.difference(selectedDateRange.start).inDays;
      final totalWeeks = (totalDays / 7).ceil();

      for (int week = 0; week < totalWeeks; week++) {
        final date = selectedDateRange.start.add(Duration(days: week * 7));
        final monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';
        final value = widget.monthTotals[monthKey] ?? 0.0;
        spots.add(FlSpot(week.toDouble(), value));
      }
    } else {
      // Handle monthly data
      for (int month = selectedDateRange.start.month;
          month <= selectedDateRange.end.month;
          month++) {
        final key = '2025-${month.toString().padLeft(2, '0')}';
        final value = widget.monthTotals[key] ?? 0.0;
        spots.add(
            FlSpot((month - selectedDateRange.start.month).toDouble(), value));
      }
    }

    return spots;
  }

  // ... rest of the methods remain the same

  DateTime _getDateFromSpot(double x, String intervalType) {
    if (intervalType == 'days') {
      return selectedDateRange.start.add(Duration(days: x.toInt()));
    } else if (intervalType == 'weeks') {
      return selectedDateRange.start.add(Duration(days: x.toInt() * 7));
    } else {
      return DateTime(selectedDateRange.start.year,
          selectedDateRange.start.month + x.toInt(), 1);
    }
  }

  String _formatDateForTooltip(DateTime date) {
    final intervalType = _getIntervalType();
    if (intervalType == 'days') {
      return '${date.day}/${date.month}';
    } else if (intervalType == 'weeks') {
      return 'Week ${date.difference(selectedDateRange.start).inDays ~/ 7 + 1}';
    } else {
      return '${_getMonthName(date.month)}';
    }
  }

  SideTitles _getBottomTitles(String intervalType) {
    return SideTitles(
      showTitles: true,
      interval: _calculateInterval(intervalType),
      getTitlesWidget: (value, meta) {
        final date = _getDateFromSpot(value, intervalType);
        String label;

        switch (intervalType) {
          case 'days':
            label = '${date.day}/${date.month}';
            break;
          case 'weeks':
            label = 'W${value.toInt() + 1}';
            break;
          default:
            label = _getMonthName(date.month);
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        );
      },
    );
  }

  double _calculateInterval(String intervalType) {
    switch (intervalType) {
      case 'days':
        final days =
            selectedDateRange.end.difference(selectedDateRange.start).inDays;
        return days <= 14 ? 1 : (days / 7).ceil().toDouble();
      case 'weeks':
        final weeks =
            selectedDateRange.end.difference(selectedDateRange.start).inDays /
                7;
        return weeks <= 8 ? 1 : 2;
      default:
        final months =
            selectedDateRange.end.month - selectedDateRange.start.month + 1;
        return months <= 6 ? 1 : 2;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _getMonthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}










// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class LineChartWidget extends StatefulWidget {
//   final Map<String, double> monthTotals;

//   const LineChartWidget(this.monthTotals, {Key? key}) : super(key: key);

//   @override
//   _LineChartWidgetState createState() => _LineChartWidgetState();
// }

// class _LineChartWidgetState extends State<LineChartWidget> {
//   DateTimeRange selectedDateRange = DateTimeRange(
//     start: DateTime(2025, 1, 1),
//     end: DateTime(2025, 12, 31),
//   );

//   // Calculate the interval type based on the date range
//   String _getIntervalType() {
//     final days =
//         selectedDateRange.end.difference(selectedDateRange.start).inDays;
//     if (days <= 31) {
//       return 'days';
//     } else if (days <= 90) {
//       return 'weeks';
//     } else {
//       return 'months';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredData = _getFilteredData();
//     final intervalType = _getIntervalType();

//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: () async {
//             final pickedRange = await showDateRangePicker(
//               context: context,
//               initialDateRange: selectedDateRange,
//               firstDate: DateTime(2020),
//               lastDate: DateTime(2030),
//             );

//             if (pickedRange != null) {
//               setState(() {
//                 selectedDateRange = pickedRange;
//               });
//             }
//           },
//           child: Text(
//             'Select Date Range: ${_formatDate(selectedDateRange.start)} - ${_formatDate(selectedDateRange.end)}',
//             style: TextStyle(fontSize: 14),
//           ),
//         ),
//         const SizedBox(height: 20),
//         AspectRatio(
//           aspectRatio: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: LineChart(
//               LineChartData(
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: filteredData,
//                     isCurved: true,
//                     barWidth: 4,
//                     dotData: FlDotData(
//                       show: true,
//                       getDotPainter: (spot, percent, bar, index) {
//                         return FlDotCirclePainter(
//                           radius: 6,
//                           color: Colors.blue,
//                           strokeWidth: 2,
//                           strokeColor: Colors.white,
//                         );
//                       },
//                     ),
//                     belowBarData: BarAreaData(
//                       show: true,
//                       color: Colors.blue.withOpacity(0.2),
//                     ),
//                   ),
//                 ],
//                 borderData: FlBorderData(
//                   border: Border.all(color: Colors.grey.shade300),
//                   show: true,
//                 ),
//                 gridData: FlGridData(
//                   show: true,
//                   drawVerticalLine: true,
//                   getDrawingHorizontalLine: (value) {
//                     return FlLine(
//                       color: Colors.grey.shade300,
//                       strokeWidth: 1,
//                     );
//                   },
//                 ),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: _getBottomTitles(intervalType),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   topTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   rightTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                 ),
//                 lineTouchData: LineTouchData(
//                   touchTooltipData: LineTouchTooltipData(
//                     tooltipBgColor: Colors.blueAccent,
//                     getTooltipItems: (List<LineBarSpot> touchedSpots) {
//                       return touchedSpots.map((LineBarSpot touchedSpot) {
//                         final date =
//                             _getDateFromSpot(touchedSpot.x, intervalType);
//                         return LineTooltipItem(
//                           '${_formatDateForTooltip(date)}\n\$${touchedSpot.y.toStringAsFixed(2)}',
//                           const TextStyle(color: Colors.white),
//                         );
//                       }).toList();
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   List<FlSpot> _getFilteredData() {
//     final intervalType = _getIntervalType();
//     List<FlSpot> spots = [];

//     if (intervalType == 'days') {
//       // Create daily data points
//       for (DateTime date = selectedDateRange.start;
//           date.isBefore(selectedDateRange.end) ||
//               date.isAtSameMomentAs(selectedDateRange.end);
//           date = date.add(Duration(days: 1))) {
//         final key =
//             '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//         final value = widget.monthTotals[key] ?? 0.0;
//         spots.add(FlSpot(
//             date.difference(selectedDateRange.start).inDays.toDouble(), value));
//       }
//     } else if (intervalType == 'weeks') {
//       // Create weekly data points
//       for (DateTime date = selectedDateRange.start;
//           date.isBefore(selectedDateRange.end);
//           date = date.add(Duration(days: 7))) {
//         final weekNumber = date.difference(selectedDateRange.start).inDays ~/ 7;
//         final value = widget.monthTotals[_formatDate(date)] ?? 0.0;
//         spots.add(FlSpot(weekNumber.toDouble(), value));
//       }
//     } else {
//       // Create monthly data points
//       for (int month = selectedDateRange.start.month;
//           month <= selectedDateRange.end.month;
//           month++) {
//         final key = '2025-${month.toString().padLeft(2, '0')}';
//         final value = widget.monthTotals[key] ?? 0.0;
//         spots.add(
//             FlSpot((month - selectedDateRange.start.month).toDouble(), value));
//       }
//     }

//     return spots;
//   }

//   DateTime _getDateFromSpot(double x, String intervalType) {
//     if (intervalType == 'days') {
//       return selectedDateRange.start.add(Duration(days: x.toInt()));
//     } else if (intervalType == 'weeks') {
//       return selectedDateRange.start.add(Duration(days: x.toInt() * 7));
//     } else {
//       return DateTime(selectedDateRange.start.year,
//           selectedDateRange.start.month + x.toInt(), 1);
//     }
//   }

//   String _formatDateForTooltip(DateTime date) {
//     final intervalType = _getIntervalType();
//     if (intervalType == 'days') {
//       return '${date.day}/${date.month}';
//     } else if (intervalType == 'weeks') {
//       return 'Week ${date.difference(selectedDateRange.start).inDays ~/ 7 + 1}';
//     } else {
//       return '${_getMonthName(date.month)}';
//     }
//   }

//   SideTitles _getBottomTitles(String intervalType) {
//     return SideTitles(
//       showTitles: true,
//       interval: _calculateInterval(intervalType),
//       getTitlesWidget: (value, meta) {
//         final date = _getDateFromSpot(value, intervalType);
//         String label;

//         switch (intervalType) {
//           case 'days':
//             label = '${date.day}/${date.month}';
//             break;
//           case 'weeks':
//             label = 'W${value.toInt() + 1}';
//             break;
//           default:
//             label = _getMonthName(date.month);
//         }

//         return Padding(
//           padding: const EdgeInsets.only(top: 8.0),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   double _calculateInterval(String intervalType) {
//     switch (intervalType) {
//       case 'days':
//         final days =
//             selectedDateRange.end.difference(selectedDateRange.start).inDays;
//         return days <= 14 ? 1 : (days / 7).ceil().toDouble();
//       case 'weeks':
//         final weeks =
//             selectedDateRange.end.difference(selectedDateRange.start).inDays /
//                 7;
//         return weeks <= 8 ? 1 : 2;
//       default:
//         final months =
//             selectedDateRange.end.month - selectedDateRange.start.month + 1;
//         return months <= 6 ? 1 : 2;
//     }
//   }

//   String _formatDate(DateTime date) {
//     return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//   }

//   String _getMonthName(int month) {
//     final months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return months[month - 1];
//   }
// }














// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class LineChartWidget extends StatefulWidget {
//   final Map<String, double> monthTotals;

//   const LineChartWidget(this.monthTotals, {Key? key}) : super(key: key);

//   @override
//   _LineChartWidgetState createState() => _LineChartWidgetState();
// }

// class _LineChartWidgetState extends State<LineChartWidget> {
//   // Default date range (entire year of 2025)
//   DateTimeRange selectedDateRange = DateTimeRange(
//     start: DateTime(2025, 1, 1),
//     end: DateTime(2025, 12, 31),
//   );

//   @override
//   Widget build(BuildContext context) {
//     // Get filtered data based on the selected date range
//     final filteredData = _getFilteredData();

//     return Column(
//       children: [
//         // Date Picker Button
//         ElevatedButton(
//           onPressed: () async {
//             final pickedRange = await showDateRangePicker(
//               context: context,
//               initialDateRange: selectedDateRange,
//               firstDate: DateTime(2020), // Earliest selectable date
//               lastDate: DateTime(2030), // Latest selectable date
//             );

//             if (pickedRange != null) {
//               setState(() {
//                 selectedDateRange = pickedRange;
//               });
//             }
//           },
//           child: Text(
//             'Select Date Range: ${_formatDate(selectedDateRange.start)} - ${_formatDate(selectedDateRange.end)}',
//             style: TextStyle(fontSize: 14),
//           ),
//         ),
//         // Chart
//         AspectRatio(
//           aspectRatio: 2,
//           child: LineChart(
//             LineChartData(
//               lineBarsData: [
//                 LineChartBarData(
//                   spots: filteredData
//                       .map((point) => FlSpot(point.x.toDouble(), point.y))
//                       .toList(),
//                   isCurved: true,
//                   barWidth: 4,
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: Colors.blue.withOpacity(0.2),
//                   ),
//                 ),
//               ],
//               borderData: FlBorderData(
//                 border: Border.all(color: Colors.grey, width: 1),
//               ),
//               gridData: FlGridData(show: true, drawVerticalLine: true),
//               titlesData: FlTitlesData(
//                 bottomTitles: AxisTitles(sideTitles: _bottomTitles),
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false), // Hide Y-axis labels
//                 ),
//                 topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper function to filter data based on the selected date range
//   List<PricePoint> _getFilteredData() {
//     final startMonth = selectedDateRange.start.month;
//     final endMonth = selectedDateRange.end.month;

//     // Generate data for all months in the range
//     return List.generate(12, (index) {
//       final month = index + 1;
//       final amount = widget.monthTotals['2025-${month.toString().padLeft(2, '0')}'] ?? 0.0;

//       // Include only months within the selected range
//       if (month >= startMonth && month <= endMonth) {
//         return PricePoint(month, amount);
//       } else {
//         return PricePoint(month, 0.0); // Default to 0 for months outside the range
//       }
//     });
//   }

//   // Helper function to format dates for display
//   String _formatDate(DateTime date) {
//     return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//   }

//   // Customize bottom titles (months)
//   SideTitles get _bottomTitles => SideTitles(
//         showTitles: true,
//         getTitlesWidget: (value, meta) {
//           String text = '';
//           switch (value.toInt()) {
//             case 1:
//               text = 'Jan';
//               break;
//             case 2:
//               text = 'Feb';
//               break;
//             case 3:
//               text = 'Mar';
//               break;
//             case 4:
//               text = 'Apr';
//               break;
//             case 5:
//               text = 'May';
//               break;
//             case 6:
//               text = 'Jun';
//               break;
//             case 7:
//               text = 'Jul';
//               break;
//             case 8:
//               text = 'Aug';
//               break;
//             case 9:
//               text = 'Sep';
//               break;
//             case 10:
//               text = 'Oct';
//               break;
//             case 11:
//               text = 'Nov';
//               break;
//             case 12:
//               text = 'Dec';
//               break;
//             default:
//               return SizedBox();
//           }

//           return Text(
//             text,
//             style: TextStyle(
//                 fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
//           );
//         },
//       );
// }

// // Helper class for data points
// class PricePoint {
//   final int x; // Month (1 to 12)
//   final double y; // Expense amount

//   PricePoint(this.x, this.y);
// }














// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class LineChartWidget extends StatefulWidget {
//   final Map<String, double> monthTotals;

//   const LineChartWidget(this.monthTotals, {Key? key}) : super(key: key);

//   @override
//   _LineChartWidgetState createState() => _LineChartWidgetState();
// }

// class _LineChartWidgetState extends State<LineChartWidget> {
//   // Default date range (entire year of 2025)
//   DateTimeRange selectedDateRange = DateTimeRange(
//     start: DateTime(2025, 1, 1),
//     end: DateTime(2025, 12, 31),
//   );

//   @override
//   Widget build(BuildContext context) {
//     // Filter data based on the selected date range
//     final filteredData = _getFilteredData();

//     return Column(
//       children: [
//         // Date Picker Button
//         ElevatedButton(
//           onPressed: () async {
//             final pickedRange = await showDateRangePicker(
//               context: context,
//               initialDateRange: selectedDateRange,
//               firstDate: DateTime(2020), // Earliest selectable date
//               lastDate: DateTime(2030), // Latest selectable date
//             );

//             if (pickedRange != null) {
//               setState(() {
//                 selectedDateRange = pickedRange;
//               });
//             }
//           },
//           child: Text(
//             'Select Date Range: ${_formatDate(selectedDateRange.start)} - ${_formatDate(selectedDateRange.end)}',
//             style: TextStyle(fontSize: 14),
//           ),
//         ),
//         // Chart
//         AspectRatio(
//           aspectRatio: 2,
//           child: LineChart(
//             LineChartData(
//               lineBarsData: [
//                 LineChartBarData(
//                   spots: filteredData
//                       .map((point) => FlSpot(point.x.toDouble(), point.y))
//                       .toList(),
//                   isCurved: true,
//                   barWidth: 4,
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: Colors.blue.withOpacity(0.2),
//                   ),
//                 ),
//               ],
//               borderData: FlBorderData(
//                 border: Border.all(color: Colors.grey, width: 1),
//               ),
//               gridData: FlGridData(show: true, drawVerticalLine: true),
//               titlesData: FlTitlesData(
//                 bottomTitles: AxisTitles(sideTitles: _bottomTitles),
//                 leftTitles: AxisTitles(
//                   sideTitles:
//                       SideTitles(showTitles: false), // Hide Y-axis labels
//                 ),
//                 topTitles:
//                     AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 rightTitles:
//                     AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper function to filter data based on the selected date range
//   List<PricePoint> _getFilteredData() {
//     final startMonth = selectedDateRange.start.month;
//     final endMonth = selectedDateRange.end.month;

//     // Generate data for all months in the range
//     return List.generate(12, (index) {
//       final month = index + 1;
//       final amount =
//           widget.monthTotals['2025-${month.toString().padLeft(2, '0')}'] ?? 0.0;

//       // Include only months within the selected range
//       if (month >= startMonth && month <= endMonth) {
//         return PricePoint(month, amount);
//       } else {
//         return PricePoint(
//             month, 0.0); // Default to 0 for months outside the range
//       }
//     });
//   }

//   // Helper function to format dates for display
//   String _formatDate(DateTime date) {
//     return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//   }

//   // Customize bottom titles (months)
//   SideTitles get _bottomTitles => SideTitles(
//         showTitles: true,
//         getTitlesWidget: (value, meta) {
//           String text = '';
//           switch (value.toInt()) {
//             case 1:
//               text = 'Jan';
//               break;
//             case 2:
//               text = 'Feb';
//               break;
//             case 3:
//               text = 'Mar';
//               break;
//             case 4:
//               text = 'Apr';
//               break;
//             case 5:
//               text = 'May';
//               break;
//             case 6:
//               text = 'Jun';
//               break;
//             case 7:
//               text = 'Jul';
//               break;
//             case 8:
//               text = 'Aug';
//               break;
//             case 9:
//               text = 'Sep';
//               break;
//             case 10:
//               text = 'Oct';
//               break;
//             case 11:
//               text = 'Nov';
//               break;
//             case 12:
//               text = 'Dec';
//               break;
//             default:
//               return SizedBox();
//           }

//           return Text(
//             text,
//             style: TextStyle(
//                 fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
//           );
//         },
//       );
// }

// // Helper class for data points
// class PricePoint {
//   final int x; // Month (1 to 12)
//   final double y; // Expense amount

//   PricePoint(this.x, this.y);
// }


// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:gestiondedepance/screens/stats/stats.dart';

// class LineChartWidget extends StatelessWidget {
//   final Map<String, double> monthTotals;

//   const LineChartWidget(this.monthTotals, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Ensure all months (1 to 12) are accounted for, setting missing months to 0
//     final allMonthsData = List.generate(12, (index) {
//       // Get the year-month string (e.g., '2025-01', '2025-02', ...)
//       String monthYear = '2025-${(index + 1).toString().padLeft(2, '0')}';

//       // Check if the monthYear exists in monthTotals, if not, set to 0
//       final existingAmount = monthTotals[monthYear] ?? 0.0;

//       return PricePoint(
//           index + 1, existingAmount); // Create PricePoint for each month
//     });

//     return AspectRatio(
//       aspectRatio: 2,
//       child: LineChart(
//         LineChartData(
//           lineBarsData: [
//             LineChartBarData(
//               spots: allMonthsData
//                   .map((point) => FlSpot(point.x.toDouble(), point.y))
//                   .toList(),
//               isCurved: true, // Curved line for smooth design
//               barWidth: 4,
//               belowBarData:
//                   BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
//             ),
//           ],
//           borderData: FlBorderData(
//             border: Border.all(
//                 color: Colors.grey, width: 1), // Grey border for the chart
//           ),
//           gridData: FlGridData(
//               show: true, drawVerticalLine: true), // Show gridlines for clarity
//           titlesData: FlTitlesData(
//             bottomTitles: AxisTitles(sideTitles: _bottomTitles),
//             leftTitles: AxisTitles(sideTitles: _leftTitles),
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           ),
//         ),
//       ),
//     );
//   }

//   // Customize bottom titles (months)
//   SideTitles get _bottomTitles => SideTitles(
//         showTitles: true,
//         getTitlesWidget: (value, meta) {
//           String text = '';
//           // Show all months on the bottom titles (from 1 to 12)
//           switch (value.toInt()) {
//             case 1:
//               text = 'Jan';
//               break;
//             case 2:
//               text = 'Feb';
//               break;
//             case 3:
//               text = 'Mar';
//               break;
//             case 4:
//               text = 'Apr';
//               break;
//             case 5:
//               text = 'May';
//               break;
//             case 6:
//               text = 'Jun';
//               break;
//             case 7:
//               text = 'Jul';
//               break;
//             case 8:
//               text = 'Aug';
//               break;
//             case 9:
//               text = 'Sep';
//               break;
//             case 10:
//               text = 'Oct';
//               break;
//             case 11:
//               text = 'Nov';
//               break;
//             case 12:
//               text = 'Dec';
//               break;
//             default:
//               return SizedBox(); // Don't display title for other points
//           }

//           return Text(
//             text,
//             style: TextStyle(
//                 fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
//           );
//         },
//       );

//   // Customize left titles (expense amounts)
//   SideTitles get _leftTitles => SideTitles(
//         showTitles: true,
//         getTitlesWidget: (value, meta) {
//           return Text(
//             '\$${value.toInt()}',
//             style: TextStyle(
//                 fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
//           );
//         },
//       );
// }

// import 'dart:math';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class MyChart extends StatefulWidget {
//   const MyChart({super.key});

//   @override
//   State<MyChart> createState() => _MyChartState();
// }

// class _MyChartState extends State<MyChart> {
//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       mainBarData(),
//     );
//   }

//   BarChartGroupData makeGroupData(int x, double y) {
//     return BarChartGroupData(x: x, barRods: [
//       BarChartRodData(
//           toY: y,
//           gradient: LinearGradient(
//             colors: [
//               Theme.of(context).colorScheme.primary,
//               Theme.of(context).colorScheme.secondary,
//               Theme.of(context).colorScheme.tertiary,
//             ],
//             transform: const GradientRotation(pi / 40),
//           ),
//           width: 20,
//           backDrawRodData: BackgroundBarChartRodData(
//               show: true, toY: 5, color: Colors.grey.shade300))
//     ]);
//   }

//   List<BarChartGroupData> showingGroups() => List.generate(8, (i) {
//         switch (i) {
//           case 0:
//             return makeGroupData(0, 2);
//           case 1:
//             return makeGroupData(1, 3);
//           case 2:
//             return makeGroupData(2, 2);
//           case 3:
//             return makeGroupData(3, 4.5);
//           case 4:
//             return makeGroupData(4, 3.8);
//           case 5:
//             return makeGroupData(5, 1.5);
//           case 6:
//             return makeGroupData(6, 4);
//           case 7:
//             return makeGroupData(7, 3.8);
//           default:
//             return throw Error();
//         }
//       });

//   BarChartData mainBarData() {
//     return BarChartData(
//       titlesData: FlTitlesData(
//         show: true,
//         rightTitles:
//             const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 38,
//           getTitlesWidget: getTiles,
//         )),
//         leftTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 38,
//             getTitlesWidget: leftTitles,
//           ),
//         ),
//       ),
//       borderData: FlBorderData(show: false),
//       gridData: const FlGridData(show: false),
//       barGroups: showingGroups(),
//     );
//   }

//   Widget getTiles(double value, TitleMeta meta) {
//     const style = TextStyle(
//       color: Colors.grey,
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     Widget text;

//     switch (value.toInt()) {
//       case 0:
//         text = const Text('01', style: style);
//         break;
//       case 1:
//         text = const Text('02', style: style);
//         break;
//       case 2:
//         text = const Text('03', style: style);
//         break;
//       case 3:
//         text = const Text('04', style: style);
//         break;
//       case 4:
//         text = const Text('05', style: style);
//         break;
//       case 5:
//         text = const Text('06', style: style);
//         break;
//       case 6:
//         text = const Text('07', style: style);
//         break;
//       case 7:
//         text = const Text('08', style: style);
//         break;
//       default:
//         text = const Text('', style: style);
//         break;
//     }
//     return SideTitleWidget(
//       space: 16,
//       meta: meta,
//       child: text,
//     );
//   }

//   Widget leftTitles(double value, TitleMeta meta) {
//     const style = TextStyle(
//       color: Colors.grey,
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     String text;
//     if (value == 0) {
//       text = '1K';
//     } else if (value == 2) {
//       text = '2K';
//     } else if (value == 3) {
//       text = '3K';
//     } else if (value == 4) {
//       text = '4K';
//     } else if (value == 5) {
//       text = '5K';
//     } else {
//       return Container();
//     }
//     return SideTitleWidget(
//       space: 0,
//       meta: meta,
//       child: Text(text, style: style),
//     );
//   }
// }
