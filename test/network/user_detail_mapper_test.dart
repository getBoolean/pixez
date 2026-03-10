import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/network/user_detail_mapper.dart';

void main() {
  test('maps ajax social twitter url into profile fields', () {
    final mapped = mapAjaxUserDetailToAppApiShape({
      'userId': '5004479',
      'name': 'Watakaze',
      'imageBig': 'https://example.com/avatar_170.png',
      'comment': 'hello',
      'isFollowed': false,
      'following': 86,
      'mypixivCount': 3,
      'webpage': 'https://watakaze.example',
      'gender': {'name': null, 'privacyLevel': 'public'},
      'job': {'name': 'Illustrator', 'privacyLevel': 'private'},
      'social': {
        'twitter': {'url': 'https://twitter.com/Watakaze1062'},
      },
      'workspace': null,
    });

    final profile = mapped['profile'] as Map<String, dynamic>;
    final user = mapped['user'] as Map<String, dynamic>;

    expect(user['id'], 5004479);
    expect(user['is_mypixiv'], isFalse);
    expect(profile['twitter_url'], 'https://twitter.com/Watakaze1062');
    expect(profile['twitter_account'], 'Watakaze1062');
    expect(profile['webpage'], 'https://watakaze.example');
    expect(profile['gender'], isNull);
    expect(profile['job'], 'Illustrator');
    expect((mapped['workspace'] as Map<String, dynamic>)['pc'], '');
  });

  test('supports x.com twitter urls', () {
    final mapped = mapAjaxUserDetailToAppApiShape({
      'userId': 123,
      'name': 'Alice',
      'image': 'https://example.com/avatar.png',
      'social': {
        'twitter': {'url': 'https://x.com/alice_dev'},
      },
      'isMypixiv': true,
      'workspace': {},
    });

    final user = mapped['user'] as Map<String, dynamic>;
    final profile = mapped['profile'] as Map<String, dynamic>;
    expect(user['is_mypixiv'], isTrue);
    expect(profile['twitter_account'], 'alice_dev');
    expect(profile['twitter_url'], 'https://x.com/alice_dev');
  });
}
