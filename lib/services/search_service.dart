class SearchNormalizer {
  static const Map<String, List<String>> governorateAliases = {
    '\u062a\u0648\u0646\u0633': ['\u062a\u0648\u0646\u0633', 'tunis', 'tn'],
    '\u0623\u0631\u064a\u0627\u0646\u0629': ['\u0623\u0631\u064a\u0627\u0646\u0629', '\u0627\u0631\u064a\u0627\u0646\u0629', 'ariana'],
    '\u0628\u0646 \u0639\u0631\u0648\u0633': ['\u0628\u0646 \u0639\u0631\u0648\u0633', 'ben arous', 'benarous', 'ba'],
    '\u0645\u0646\u0648\u0628\u0629': ['\u0645\u0646\u0648\u0628\u0629', '\u0645\u0646\u0648\u0628\u0647', 'manouba', 'manoubeh'],
    '\u0628\u0646\u0632\u0631\u062a': ['\u0628\u0646\u0632\u0631\u062a', 'bizerte', 'benzart', 'bzrt'],
    '\u0646\u0627\u0628\u0644': ['\u0646\u0627\u0628\u0644', 'nabeul', 'nabul'],
    '\u0632\u063a\u0648\u0627\u0646': ['\u0632\u063a\u0648\u0627\u0646', 'zaghouan', 'zaghwan'],
    '\u0628\u0627\u062c\u0629': ['\u0628\u0627\u062c\u0629', '\u0628\u0627\u062c\u0647', 'beja', 'béja'],
    '\u062c\u0646\u062f\u0648\u0628\u0629': ['\u062c\u0646\u062f\u0648\u0628\u0629', '\u062c\u0646\u062f\u0648\u0628\u0647', 'jendouba', 'jenduba'],
    '\u0627\u0644\u0643\u0627\u0641': ['\u0627\u0644\u0643\u0627\u0641', 'le kef', 'kef', 'el kef'],
    '\u0633\u0644\u064a\u0627\u0646\u0629': ['\u0633\u0644\u064a\u0627\u0646\u0629', '\u0633\u0644\u064a\u0627\u0646\u0647', 'siliana', 'silyana'],
    '\u0633\u0648\u0633\u0629': ['\u0633\u0648\u0633\u0629', '\u0633\u0648\u0633\u0647', 'sousse', 'susa'],
    '\u0627\u0644\u0645\u0646\u0633\u062a\u064a\u0631': ['\u0627\u0644\u0645\u0646\u0633\u062a\u064a\u0631', 'monastir', 'monastire'],
    '\u0627\u0644\u0645\u0647\u062f\u064a\u0629': ['\u0627\u0644\u0645\u0647\u062f\u064a\u0629', '\u0627\u0644\u0645\u0647\u062f\u064a\u0647', 'mahdia', 'mahdya'],
    '\u0635\u0641\u0627\u0642\u0633': ['\u0635\u0641\u0627\u0642\u0633', 'sfax', 'sfx'],
    '\u0627\u0644\u0642\u064a\u0631\u0648\u0627\u0646': ['\u0627\u0644\u0642\u064a\u0631\u0648\u0627\u0646', 'kairouan', 'kairwan'],
    '\u0627\u0644\u0642\u0635\u0631\u064a\u0646': ['\u0627\u0644\u0642\u0635\u0631\u064a\u0646', 'kasserine', 'kassrine'],
    '\u0633\u064a\u062f\u064a \u0628\u0648\u0632\u064a\u062f': ['\u0633\u064a\u062f\u064a \u0628\u0648\u0632\u064a\u062f', 'sidi bouzid', 'sidibouzid'],
    '\u0642\u0627\u0628\u0633': ['\u0642\u0627\u0628\u0633', 'gabes', 'gabus'],
    '\u0645\u062f\u0646\u064a\u0646': ['\u0645\u062f\u0646\u064a\u0646', 'medenine', 'mednine'],
    '\u062a\u0637\u0627\u0648\u064a\u0646': ['\u062a\u0637\u0627\u0648\u064a\u0646', 'tataouine', 'tatawin'],
    '\u0642\u0641\u0635\u0629': ['\u0642\u0641\u0635\u0629', '\u0642\u0641\u0635\u0647', 'gafsa', 'qafsa'],
    '\u062a\u0648\u0632\u0631': ['\u062a\u0648\u0632\u0631', 'tozeur', 'tozer'],
    '\u0642\u0628\u0644\u064a': ['\u0642\u0628\u0644\u064a', 'kebili', 'qibili', 'kibili'],
  };

  static const List<List<String>> equipmentAliases = [
    ['trax', 'traxe', '\u062a\u0631\u0627\u0643\u0633', '\u062c\u0631\u0627\u0641\u0629'],
    ['camera', '\u0643\u0627\u0645\u064a\u0631\u0627', 'cam'],
    ['pelle', '\u0628\u0648\u0643\u0644\u0627\u0646', '\u0645\u0639\u062f\u0629 \u062d\u0641\u0631'],
    ['son', '\u0635\u0648\u062a', 'haut-parleur', 'baffle'],
  ];

  static String normalize(String value) {
    var result = value.toLowerCase().trim();
    result = result.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '');
    result = result.replaceAll(RegExp(r'[àáâãäå]'), 'a');
    result = result.replaceAll(RegExp(r'[èéêë]'), 'e');
    result = result.replaceAll(RegExp(r'[ìíîï]'), 'i');
    result = result.replaceAll(RegExp(r'[òóôõö]'), 'o');
    result = result.replaceAll(RegExp(r'[ùúûü]'), 'u');
    result = result
        .replaceAll('\u0623', '\u0627')
        .replaceAll('\u0625', '\u0627')
        .replaceAll('\u0622', '\u0627')
        .replaceAll('\u0671', '\u0627')
        .replaceAll('\u0649', '\u064a')
        .replaceAll('\u0629', '\u0647');
    result = result.replaceAll(RegExp(r"[^\p{L}\p{N}]+", unicode: true), ' ');
    return result.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static Set<String> _expandedQueries(String query) {
    final normalizedQuery = normalize(query);
    final expanded = <String>{normalizedQuery};

    for (final aliases in governorateAliases.values) {
      final normalizedAliases = aliases.map(normalize).toList();
      if (normalizedAliases.any((alias) => alias == normalizedQuery)) {
        expanded.addAll(normalizedAliases);
      }
    }
    for (final aliases in equipmentAliases) {
      final normalizedAliases = aliases.map(normalize).toList();
      if (normalizedAliases.any((alias) => alias == normalizedQuery)) {
        expanded.addAll(normalizedAliases);
      }
    }
    return expanded;
  }

  static bool matches(String query, Iterable<String> values) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return true;

    final normalizedValues = values.map(normalize);
    final expandedQueries = _expandedQueries(normalizedQuery);
    return normalizedValues.any(
      (value) => expandedQueries.any((candidate) => value.contains(candidate)),
    );
  }
}