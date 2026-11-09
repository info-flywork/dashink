import 'package:dashink/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Anonim oyuncu. [id] aynı zamanda RevenueCat `app_user_id`'dir.
@JsonSerializable()
class User extends Equatable implements BaseModel<User> {
  const User({this.id, this.name});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  final String? id;
  final String? name;

  User copyWith({String? id, String? name}) =>
      User(id: id ?? this.id, name: name ?? this.name);

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [id, name];
}
