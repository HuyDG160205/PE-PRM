/// Devices from the public catalogue API have no explicit "category" field,
/// so the category shown in the UI is inferred from the device name.
class CategoryInferrer {
  CategoryInferrer._();

  static const Map<String, List<String>> _keywordsByCategory = {
    'Laptop': ['laptop', 'macbook', 'notebook', 'chromebook'],
    'Phone': ['phone', 'iphone', 'galaxy s', 'galaxy note', 'pixel'],
    'Tablet': ['tablet', 'ipad', 'galaxy tab'],
    'Camera': ['camera', 'gopro', 'dslr'],
    'Monitor': ['monitor', 'display'],
    'Watch': ['watch'],
    'Console': ['playstation', 'xbox', 'nintendo', 'console'],
    'TV': ['tv', 'television'],
    'Audio': ['headphone', 'speaker', 'earbud', 'airpods'],
  };

  static String infer(String name) {
    final lowerName = name.toLowerCase();
    for (final entry in _keywordsByCategory.entries) {
      if (entry.value.any(lowerName.contains)) return entry.key;
    }
    return 'Other';
  }
}
