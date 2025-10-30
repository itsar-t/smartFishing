import 'package:flutter/material.dart';
import 'county_licence_page.dart'; // ⬅️ NYTT

class LicencePage extends StatefulWidget {
  const LicencePage({super.key});
  @override
  State<LicencePage> createState() => _LicencePageState();
}

class _LicencePageState extends State<LicencePage> {
  final TextEditingController _search = TextEditingController();

  static const _counties = <String>[
    'Blekinge län',
    'Dalarnas län',
    'Gotlands län',
    'Gävleborgs län',
    'Hallands län',
    'Jämtlands län',
    'Jönköpings län',
    'Kalmar län',
    'Kronobergs län',
    'Norrbottens län',
    'Skåne län',
    'Stockholms län',
    'Södermanlands län',
    'Uppsala län',
    'Värmlands län',
    'Västerbottens län',
    'Västernorrlands län',
    'Västmanlands län',
    'Västra Götalands län',
    'Örebro län',
    'Östergötlands län',
  ];

  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text.trim()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _counties
        .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Find a place',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final name = filtered[i];
              return ListTile(
                title: Text(name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CountyLicencePage(countyName: name),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
