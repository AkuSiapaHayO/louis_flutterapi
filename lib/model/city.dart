import 'package:equatable/equatable.dart';

class City extends Equatable {
  final String? cityId;
  final String? provinceId;
  final String? province;
  final String? type;
  final String? cityName;

  const City({
    this.cityId,
    this.provinceId,
    this.province,
    this.type,
    this.cityName,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        cityId: json['city_id'] as String?,
        provinceId: json['province_id'] as String?,
        province: json['province'] as String?,
        type: json['type'] as String?,
        cityName: json['city_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'city_id': cityId,
        'province_id': provinceId,
        'province': province,
        'type': type,
        'city_name': cityName,
      };

  @override
  List<Object?> get props => [cityId, provinceId, province, type, cityName];
}