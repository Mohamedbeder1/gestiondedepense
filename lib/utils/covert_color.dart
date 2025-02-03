import 'dart:ui';

Color parseColorString(String colorString) {
  RegExp regExp = RegExp(
      r'alpha:\s([0-9.]+),\sred:\s([0-9.]+),\sgreen:\s([0-9.]+),\sblue:\s([0-9.]+)');
  Match? match = regExp.firstMatch(colorString);

  if (match != null) {
    double alpha = double.parse(match.group(1)!);
    double red = double.parse(match.group(2)!);
    double green = double.parse(match.group(3)!);
    double blue = double.parse(match.group(4)!);

    return Color.fromRGBO(
      (red * 255).toInt(),
      (green * 255).toInt(),
      (blue * 255).toInt(),
      alpha,
    );
  } else {
    throw FormatException('Unable to parse color string');
  }
}
