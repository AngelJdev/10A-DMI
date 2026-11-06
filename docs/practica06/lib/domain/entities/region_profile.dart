class RegionProfile {
  const RegionProfile({
    required this.code,
    required this.country,
    required this.locale,
    required this.continent,
    required this.language,
    required this.ratingSystem,
    required this.accentValue,
    required this.gradientValues,
  });

  final String code;
  final String country;
  final String locale;
  final String continent;
  final String language;
  final String ratingSystem;
  final int accentValue;
  final List<int> gradientValues;

  String get flagAssetUrl =>
      'https://flagcdn.com/w160/${code.toLowerCase()}.png';
}

const regionProfiles = <RegionProfile>[
  RegionProfile(
    code: 'MX',
    country: 'México',
    locale: 'es-MX',
    continent: 'América del Norte',
    language: 'Español',
    ratingSystem: 'RTC',
    accentValue: 0xff19724b,
    gradientValues: [0xff006847, 0xffffffff, 0xffce1126],
  ),
  RegionProfile(
    code: 'US',
    country: 'Estados Unidos',
    locale: 'en-US',
    continent: 'América del Norte',
    language: 'Inglés',
    ratingSystem: 'MPA',
    accentValue: 0xff3157a4,
    gradientValues: [0xff3c3b6e, 0xffffffff, 0xffb22234],
  ),
  RegionProfile(
    code: 'SV',
    country: 'El Salvador',
    locale: 'es-SV',
    continent: 'América Central',
    language: 'Español',
    ratingSystem: 'Espectáculos Públicos',
    accentValue: 0xff3478bd,
    gradientValues: [0xff0f47af, 0xffffffff, 0xff0f47af],
  ),
  RegionProfile(
    code: 'BR',
    country: 'Brasil',
    locale: 'pt-BR',
    continent: 'Sudamérica',
    language: 'Portugués',
    ratingSystem: 'ClassInd',
    accentValue: 0xffd19b00,
    gradientValues: [0xff009c3b, 0xffffdf00, 0xff002776],
  ),
  RegionProfile(
    code: 'DE',
    country: 'Alemania',
    locale: 'de-DE',
    continent: 'Europa',
    language: 'Alemán',
    ratingSystem: 'FSK',
    accentValue: 0xffc7423a,
    gradientValues: [0xff111111, 0xffdd0000, 0xffffce00],
  ),
  RegionProfile(
    code: 'JP',
    country: 'Japón',
    locale: 'ja-JP',
    continent: 'Asia',
    language: 'Japonés',
    ratingSystem: 'Eirin',
    accentValue: 0xffbc3346,
    gradientValues: [0xffffffff, 0xfff3d9de, 0xffbc002d],
  ),
  RegionProfile(
    code: 'AU',
    country: 'Australia',
    locale: 'en-AU',
    continent: 'Oceanía',
    language: 'Inglés',
    ratingSystem: 'ACB',
    accentValue: 0xff275ca8,
    gradientValues: [0xff012169, 0xff335f9d, 0xffffffff],
  ),
  RegionProfile(
    code: 'CD',
    country: 'R. D. del Congo',
    locale: 'fr-CD',
    continent: 'África',
    language: 'Francés',
    ratingSystem: 'Clasificación local',
    accentValue: 0xff2a77a8,
    gradientValues: [0xff007fff, 0xfff7d618, 0xffce1021],
  ),
];
