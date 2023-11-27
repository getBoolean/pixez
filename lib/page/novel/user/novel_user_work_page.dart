/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/component/novel_lighting_store.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';
import 'package:pixez/page/user/works/works_page.dart';
import 'package:pixez/exts.dart';

class NovelUserWorkPage extends StatefulWidget {
  final int id;
  final NovelLightingStore store;

  const NovelUserWorkPage({Key? key, required this.id, required this.store})
      : super(key: key);

  @override
  _NovelUserWorkPageState createState() => _NovelUserWorkPageState();
}

class _NovelUserWorkPageState extends State<NovelUserWorkPage> {
  late NovelLightingStore _store;

  @override
  void initState() {
    _store = widget.store;
    super.initState();
    _store.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(builder: (context) {
        return EasyRefresh.builder(
            controller: _store.controller,
            onLoad: () {
              _store.next();
            },
            onRefresh: () {
              _store.fetch();
            },
            header: PixezDefault.header(context,
                position: IndicatorPosition.locator, safeArea: false),
            footer: PixezDefault.footer(
              context,
              position: IndicatorPosition.locator,
            ),
            childBuilder: (_, phy) {
              return Observer(builder: (_) {
                final userIsMe = accountStore.now != null &&
                    accountStore.now!.userId == widget.id.toString();
                return CustomScrollView(
                  physics: phy,
                  key: PageStorageKey("novel_bookmark"),
                  slivers: [
                    userIsMe
                        ? SliverPinnedOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          )
                        : SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          ),
                    const HeaderLocator.sliver(),
                    _buildListBody(),
                    const FooterLocator.sliver(),
                  ],
                );
              });
            });
      }),
    );
  }

  _buildListBody() {
    _store.novels.removeWhere((element) => element.novel?.hateByUser() == true);
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      Novel novel = _store.novels[index].novel!;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (BuildContext context) => NovelViewerPage(
                      id: novel.id,
                      novelStore: _store.novels[index],
                    )));
          },
          child: Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: PixivImage(
                          novel.imageUrls.medium,
                          width: 80,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: Text(
                                novel.title,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 3,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                novel.user.name,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 2,
                                runSpacing: 0,
                                children: [
                                  for (var f in novel.tags)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      child: Text(
                                        f.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    )
                                ],
                              ),
                            ),
                            Container(
                              height: 8.0,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      NovelBookmarkButton(novel: novel),
                      Text('${novel.totalBookmarks}',
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }, childCount: _store.novels.length));
  }
}
