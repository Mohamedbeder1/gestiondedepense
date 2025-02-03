import 'dart:math';
import 'package:pdf/pdf.dart' as pdf;
import 'package:gestiondedepance/utils/important_calcule.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateAndSharePdf(Map<String, double> categoryTotals) async {
  final pdfDocument = pw.Document();

  var baseColor = pdf.PdfColors.cyan;
  const tableHeaders = ['Catégorie', 'Dépenses Total'];

  final totalExpense = calculateTotalExpenset(categoryTotals);

  final chartData = categoryTotals.entries.map((entry) {
    return pw.PieDataSet(
      legend:
          '${entry.key}\n${((entry.value / totalExpense) * 100).toStringAsFixed(1)}%',
      value: entry.value,
      color: _getRandomColor(),
    );
  }).toList();

  final tableHeight = categoryTotals.length * 15;
  final maxTableHeight = 250;
  bool isTableTooLarge = tableHeight > maxTableHeight;

  pdfDocument.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '     Rapport de dépenses',
              style: pw.TextStyle(
                fontSize: 40,
                color: baseColor,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(thickness: 4),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              data: [
                tableHeaders,
                ...categoryTotals.entries.map((entry) =>
                    [entry.key, '${entry.value.toStringAsFixed(2)} MRU']),
              ],
              border: pw.TableBorder.all(
                color: pdf.PdfColors.black,
                width: 1,
              ),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: pdf.PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: pdf.PdfColors.blueGrey,
              ),
              rowDecoration: pw.BoxDecoration(
                color: pdf.PdfColors.grey200,
              ),
              cellAlignment: pw.Alignment.center,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total: ${totalExpense.toStringAsFixed(2)} MRU',
              style: pw.TextStyle(
                fontSize: 36,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (isTableTooLarge) pw.SizedBox(height: 100),
          ],
        );
      },
    ),
  );

  if (isTableTooLarge) {
    pdfDocument.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Flexible(
                child: pw.Chart(
                  title: pw.Text(
                    'Répartition des dépenses',
                    style: pw.TextStyle(
                      fontSize: 20,
                      color: baseColor,
                    ),
                  ),
                  grid: pw.PieGrid(),
                  datasets: chartData,
                ),
              ),
            ],
          );
        },
      ),
    );
  } else {
    pdfDocument.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.SizedBox(height: 20),
              pw.Flexible(
                child: pw.Chart(
                  title: pw.Text(
                    'Répartition des dépenses',
                    style: pw.TextStyle(
                      fontSize: 20,
                      color: baseColor,
                    ),
                  ),
                  grid: pw.PieGrid(),
                  datasets: chartData,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  await Printing.sharePdf(
    bytes: await pdfDocument.save(),
    filename: 'expense_report.pdf',
  );
}

pdf.PdfColor _getRandomColor() {
  Random random = Random();
  int r = random.nextInt(256);
  int g = random.nextInt(256);
  int b = random.nextInt(256);

  return pdf.PdfColor.fromInt((r << 16) | (g << 8) | b);
}
