import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_content.freezed.dart';
part 'github_content.g.dart';

/// GitHub Contents API response model
/// Represents a file or directory in a GitHub repository
@freezed
class GithubContent with _$GithubContent {
  const factory GithubContent({
    /// File or directory name
    required String name,

    /// Path within the repository
    required String path,

    /// Git SHA hash
    required String sha,

    /// File size in bytes
    required int size,

    /// Content type (file, dir, submodule, symlink)
    required String type,

    /// Direct download URL (null for directories)
    @JsonKey(name: 'download_url') String? downloadUrl,

    /// Base64-encoded file content (when fetching file contents)
    String? content,

    /// Encoding type (usually 'base64')
    String? encoding,
  }) = _GithubContent;

  factory GithubContent.fromJson(Map<String, dynamic> json) =>
      _$GithubContentFromJson(json);
}
