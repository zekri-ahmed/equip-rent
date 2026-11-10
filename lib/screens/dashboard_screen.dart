import 'package:flutter/material.dart';
import '../models/rental.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.index, required this.rentals});
  final int index;
  final List<Rental> rentals;
  @override
  Widget build(BuildContext context) {
    if (index == 2) {
      if (rentals.isEmpty) return _empty('\u0644\u0627 \u062A\u0648\u062C\u062F \u062D\u062C\u0648\u0632\u0627\u062A \u0628\u0639\u062F', Icons.receipt_long_outlined);
      return ListView(children: [for (final rental in rentals) _rentalCard(rental)]);
    }
    if (index == 3) return _empty('\u0644\u0627 \u062A\u0648\u062C\u062F \u0631\u0633\u0627\u0626\u0644 \u062C\u062F\u064A\u062F\u0629', Icons.chat_bubble_outline);
    if (index == 4) return _empty('\u062D\u062F\u0651\u062B \u0628\u064A\u0627\u0646\u0627\u062A \u0645\u0644\u0641\u0643 \u0627\u0644\u0634\u062E\u0635\u064A \u0645\u0646 \u0647\u0646\u0627', Icons.settings_outlined);
    return _empty('\u0627\u0628\u062F\u0623 \u0628\u0625\u0636\u0627\u0641\u0629 \u0623\u0648\u0644 \u0645\u0639\u062F\u0629 \u0644\u0643', Icons.inventory_2_outlined);
  }
  Widget _rentalCard(Rental rental) => Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: const Icon(Icons.calendar_month),
          title: Text(rental.itemTitle),
          subtitle: Text('${rental.total.toStringAsFixed(0)} \u062F.\u062A  •  ${rental.startDate.day}/${rental.startDate.month} - ${rental.endDate.day}/${rental.endDate.month}'),
          trailing: Text(_status(rental.status)),
        ),
      );

  Widget _empty(String text, IconData icon) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 54, color: const Color(0xFF4A35A6)), const SizedBox(height: 14), Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]));
  String _status(String value) => {'pending': '\u0642\u064A\u062F \u0627\u0644\u0627\u0646\u062A\u0638\u0627\u0631', 'accepted': '\u0645\u0642\u0628\u0648\u0644', 'rejected': '\u0645\u0631\u0641\u0648\u0636', 'completed': '\u0645\u0643\u062A\u0645\u0644'}[value] ?? value;
}
