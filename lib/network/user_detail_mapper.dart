Map<String, dynamic> mapAjaxUserDetailToAppApiShape(
  Map<String, dynamic> body,
) {
  final social = (body['social'] as Map?)?.cast<String, dynamic>() ?? {};
  final twitterUrl = _extractSocialUrl(social, 'twitter');
  final twitterAccount = _extractTwitterAccount(twitterUrl);
  final workspace = _normalizeWorkspace(
    (body['workspace'] as Map?)?.cast<String, dynamic>(),
  );

  return {
    'user': {
      'id': int.tryParse('${body['userId'] ?? 0}') ?? 0,
      'name': body['name']?.toString() ?? '',
      'account': '',
      'profile_image_urls': {
        'medium': body['imageBig']?.toString() ??
            body['image']?.toString() ??
            '',
      },
      'comment': body['comment']?.toString(),
      'is_followed': body['isFollowed'] == true,
    },
    'profile': {
      'webpage': body['webpage']?.toString(),
      'gender': body['gender']?.toString(),
      'birth': body['age']?.toString(),
      'birth_day': body['birthDay']?.toString(),
      'birth_year': null,
      'region': body['region']?.toString(),
      'address_id': null,
      'country_code': null,
      'job': body['job']?.toString(),
      'job_id': null,
      'total_follow_users': _toInt(body['following']),
      'total_mypixiv_users': _toInt(body['mypixivCount']),
      'total_illusts': 0,
      'total_manga': 0,
      'total_novels': 0,
      'total_illust_bookmarks_public': 0,
      'total_illust_series': 0,
      'total_novel_series': 0,
      'background_image_url': body['background']?['url']?.toString(),
      'twitter_account': twitterAccount,
      'twitter_url': twitterUrl,
      'pawoo_url': _extractSocialUrl(social, 'pawoo'),
      'is_premium': body['premium'] == true,
      'is_using_custom_profile_image': true,
    },
    'profile_publicity': {
      'gender': '',
      'region': '',
      'birth_day': '',
      'birth_year': '',
      'job': '',
      'pawoo': _extractSocialUrl(social, 'pawoo') != null,
    },
    'workspace': workspace,
  };
}

String? _extractSocialUrl(Map<String, dynamic> social, String key) {
  final node = social[key];
  if (node is Map && node['url'] != null) {
    return node['url'].toString();
  }
  return null;
}

String? _extractTwitterAccount(String? url) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  if (!host.contains('twitter.com') && !host.contains('x.com')) return null;
  for (final segment in uri.pathSegments) {
    if (segment.isNotEmpty) {
      return segment;
    }
  }
  return null;
}

Map<String, dynamic> _normalizeWorkspace(Map<String, dynamic>? workspace) {
  String val(String key) => workspace?[key]?.toString() ?? '';
  return {
    'pc': val('pc'),
    'monitor': val('monitor'),
    'tool': val('tool'),
    'scanner': val('scanner'),
    'tablet': val('tablet'),
    'mouse': val('mouse'),
    'printer': val('printer'),
    'desktop': val('desktop'),
    'music': val('music'),
    'desk': val('desk'),
    'chair': val('chair'),
    'comment': val('comment'),
    'workspace_image_url': workspace?['workspace_image_url'],
  };
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}
