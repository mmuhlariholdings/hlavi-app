import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository.freezed.dart';
part 'repository.g.dart';

/// GitHub repository entity matching the web app's Repository interface
@freezed
class Repository with _$Repository {
  const factory Repository({
    /// GitHub repository ID
    required int id,

    /// Repository name (e.g., "hlavi")
    required String name,

    /// Full repository name including owner (e.g., "owner/hlavi")
    @JsonKey(name: 'full_name') required String fullName,

    /// Repository owner information
    required RepositoryOwner owner,

    /// Repository description (optional)
    String? description,

    /// Whether the repository is private
    required bool private,

    /// HTML URL to the repository on GitHub
    @JsonKey(name: 'html_url') required String htmlUrl,
  }) = _Repository;

  factory Repository.fromJson(Map<String, dynamic> json) =>
      _$RepositoryFromJson(json);
}

/// Repository owner (user or organization)
@freezed
class RepositoryOwner with _$RepositoryOwner {
  const factory RepositoryOwner({
    /// Owner's login/username
    required String login,

    /// Owner's avatar URL
    @JsonKey(name: 'avatar_url') required String avatarUrl,
  }) = _RepositoryOwner;

  factory RepositoryOwner.fromJson(Map<String, dynamic> json) =>
      _$RepositoryOwnerFromJson(json);
}
