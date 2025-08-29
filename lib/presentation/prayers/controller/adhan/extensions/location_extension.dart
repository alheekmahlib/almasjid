part of '../../../prayers.dart';

extension LocationExtension on String {
  Future<CalculationParameters> getCalculationParameters() async {
    final calculationMethod = await getCalculationParametersFromJson(this);
    CalculationMethod? method = calculationMethod ?? CalculationMethod.other;
    switch (method) {
      case CalculationMethod.umm_al_qura:
        return CalculationMethod.umm_al_qura.getParameters();
      case CalculationMethod.north_america:
        return CalculationMethod.north_america.getParameters();
      case CalculationMethod.egyptian:
        return CalculationMethod.egyptian.getParameters();
      case CalculationMethod.dubai:
        return CalculationMethod.dubai.getParameters();
      case CalculationMethod.karachi:
        return CalculationMethod.karachi.getParameters();
      case CalculationMethod.kuwait:
        return CalculationMethod.kuwait.getParameters();
      case CalculationMethod.qatar:
        return CalculationMethod.qatar.getParameters();
      case CalculationMethod.turkey:
        return CalculationMethod.turkey.getParameters();
      case CalculationMethod.singapore:
        return CalculationMethod.singapore.getParameters();
      case CalculationMethod.muslim_world_league:
        return CalculationMethod.muslim_world_league.getParameters();
      case CalculationMethod.other:
        return CalculationMethod.other.getParameters();
      default:
        return CalculationMethod.other.getParameters();
    }
  }
}

Future<CalculationMethod?> getCalculationParametersFromJson(
    String countryName) async {
  try {
    final jsonString = await rootBundle.loadString('assets/json/madhab.json');
    final jsonData = jsonDecode(jsonString) as List;
    final countryData = jsonData.cast<Map<String, dynamic>>().firstWhereOrNull(
          (item) => item['country'] == countryName,
        );
    if (countryData == null) {
      return null;
    }
    final params = countryData['params'] as String?;
    switch (params) {
      case 'umm_al_qura':
        return CalculationMethod.umm_al_qura;
      case 'Saudi Arabia':
        return CalculationMethod.umm_al_qura;
      case 'muslim_world_league':
        return CalculationMethod.muslim_world_league;
      case 'egyptian':
        return CalculationMethod.egyptian;
      case 'dubai':
        return CalculationMethod.dubai;
      case 'karachi':
        return CalculationMethod.karachi;
      case 'kuwait':
        return CalculationMethod.kuwait;
      case 'qatar':
        return CalculationMethod.qatar;
      case 'singapore':
        return CalculationMethod.singapore;
      case 'turkey':
        return CalculationMethod.turkey;
      case 'north_america':
        return CalculationMethod.north_america;
      default:
        return CalculationMethod.other;
    }
  } catch (e) {
    log('Error fetching calculation parameters: $e');
    return null;
  }
}
