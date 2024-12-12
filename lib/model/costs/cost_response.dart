import 'package:equatable/equatable.dart';

import 'costs.dart';

class CostResponse extends Equatable {
  final String? code;
  final String? name;
  final List<Costs>? costs;

  const CostResponse({this.code, this.name, this.costs});

  factory CostResponse.fromJson(Map<String, dynamic> json) => CostResponse(
        code: json['code'] as String?,
        name: json['name'] as String?,
        costs: (json['costs'] as List<dynamic>?)
            ?.map((e) => Costs.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'costs': costs?.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [code, name, costs];
}