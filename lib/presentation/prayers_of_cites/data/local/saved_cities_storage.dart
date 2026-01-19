part of '../../cites.dart';

class SavedCitiesStorage {
  SavedCitiesStorage({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  List<SavedCity> readAll() {
    final raw = _box.read(SAVED_CITIES);
    if (raw is! List) return <SavedCity>[];

    final cities = raw
        .whereType<Map>()
        .map((e) => SavedCity.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    cities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return cities;
  }

  Future<void> writeAll(List<SavedCity> cities) async {
    final normalized = <SavedCity>[];

    for (int i = 0; i < cities.length; i++) {
      normalized.add(cities[i].copyWith(sortOrder: i));
    }

    await _box.write(
      SAVED_CITIES,
      normalized.map((c) => c.toJson()).toList(),
    );
  }

  Future<List<SavedCity>> add(SavedCity city) async {
    final cities = readAll();

    final exists = cities.any((c) => c.id == city.id);
    if (exists) return cities;

    cities.add(city.copyWith(sortOrder: cities.length));
    await writeAll(cities);
    return cities;
  }

  Future<List<SavedCity>> removeById(String id) async {
    final cities = readAll()..removeWhere((c) => c.id == id);
    await writeAll(cities);
    return cities;
  }

  Future<List<SavedCity>> reorder(int oldIndex, int newIndex) async {
    final cities = readAll();
    if (oldIndex < 0 || oldIndex >= cities.length) return cities;

    if (newIndex < 0) newIndex = 0;
    if (newIndex > cities.length) newIndex = cities.length;

    if (newIndex > oldIndex) newIndex -= 1;

    final item = cities.removeAt(oldIndex);
    cities.insert(newIndex, item);

    await writeAll(cities);
    return cities;
  }
}
