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

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/fluent/new_version_chip.dart';
import 'package:pixez/component/fluent/painter_avatar.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/er/updater.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/glance_illust_persist.dart';
import 'package:pixez/page/fluent/about/about_page.dart';
import 'package:pixez/page/fluent/account/edit/account_edit_page.dart';
import 'package:pixez/page/fluent/account/select/account_select_page.dart';
import 'package:pixez/page/fluent/book/tag/book_tag_page.dart';
import 'package:pixez/page/fluent/hello/recom/recom_manga_page.dart';
import 'package:pixez/page/fluent/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/fluent/history/history_page.dart';
import 'package:pixez/page/fluent/login/login_page.dart';
import 'package:pixez/page/fluent/network/network_setting_page.dart';
import 'package:pixez/page/novel/history/novel_history_page.dart';
import 'package:pixez/page/novel/novel_rail.dart';
import 'package:pixez/page/fluent/shield/shield_page.dart';
import 'package:pixez/page/fluent/task/job_page.dart';
import 'package:pixez/page/fluent/theme/theme_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
    initMethod();
  }

  bool hasNewVersion = false;

  initMethod() async {
    if (Updater.result != Result.timeout) {
      bool hasNew = Updater.result == Result.yes;
      if (mounted)
        setState(() {
          hasNewVersion = hasNew;
        });
      return;
    }
    Result result = await Updater.check();
    switch (result) {
      case Result.yes:
        if (mounted) {
          setState(() {
            hasNewVersion = true;
          });
        }
        break;
      default:
        if (mounted) {
          setState(() {
            hasNewVersion = false;
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Text(I18n.of(context).setting),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            if (kDebugMode)
              CommandBarButton(
                  icon: Icon(FluentIcons.code),
                  onPressed: () {
                    _showSavedLogDialog(context);
                  }),
            CommandBarButton(
              icon: Icon(
                FluentIcons.color,
                color: FluentTheme.of(context).typography.body?.color,
              ),
              onPressed: () {
                Leader.push(context, ThemePage());
              },
            ),
          ],
        ),
      ),
      children: [
        Observer(builder: (context) {
          if (accountStore.now != null)
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: PainterAvatar(
                        url: accountStore.now!.userImage,
                        id: int.parse(accountStore.now!.userId),
                      ),
                      title: Text(accountStore.now!.name,
                          style: FluentTheme.of(context).typography.title),
                      subtitle: Text(
                        accountStore.now!.mailAddress,
                        style: FluentTheme.of(context).typography.caption,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .push(FluentPageRoute(builder: (_) {
                          return AccountSelectPage();
                        }));
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(FluentIcons.account_management),
                    title: Text(I18n.of(context).account_message),
                    onPressed: () {
                      Leader.push(
                        context,
                        AccountEditPage(),
                        icon: Icon(FluentIcons.account_management),
                        title: Text(I18n.of(context).account_message),
                      );
                    },
                  )
                ],
              ),
            );
          return Container();
        }),
        Divider(),
        Column(
          children: <Widget>[
            ListTile(
              leading: Icon(FluentIcons.history),
              title: Text(I18n.of(context).history_record),
              onPressed: () {
                Leader.push(
                  context,
                  Constants.type == 0 ? HistoryPage() : NovelHistory(),
                  icon: Icon(FluentIcons.history),
                  title: Text(I18n.of(context).history_record),
                );
              },
            ),
            ListTile(
              leading: Icon(FluentIcons.settings),
              title: Text(I18n.of(context).quality_setting),
              onPressed: () {
                Leader.push(
                  context,
                  SettingQualityPage(),
                  icon: Icon(FluentIcons.settings),
                  title: Text(I18n.of(context).quality_setting),
                );
              },
            ),
            ListTile(
              leading: Icon(FluentIcons.bookmarks),
              title: Text(I18n.of(context).favorited_tag),
              onPressed: () => Leader.pushWithScaffold(
                context,
                BookTagPage(),
                icon: Icon(FluentIcons.bookmarks),
                title: Text(I18n.of(context).favorited_tag),
              ),
            ),
            ListTile(
              leading: Icon(FluentIcons.blocked),
              title: Text(I18n.of(context).shielding_settings),
              onPressed: () => Leader.push(
                context,
                ShieldPage(),
                icon: Icon(FluentIcons.blocked),
                title: Text(I18n.of(context).shielding_settings),
              ),
            ),
            ListTile(
              leading: Icon(FluentIcons.save),
              title: Text(I18n.of(context).task_progress),
              onPressed: () => Leader.push(
                context,
                JobPage(),
                icon: Icon(FluentIcons.save),
                title: Text(I18n.of(context).task_progress),
              ),
            ),
            ListTile(
              onPressed: () => _showClearCacheDialog(context),
              title: Text(I18n.of(context).clearn_cache),
              leading: Icon(FluentIcons.clear),
            ),
          ],
        ),
        Divider(),
        Column(
          children: <Widget>[
            ListTile(
              leading: Icon(FluentIcons.library),
              title: Text('Manga'),
              onPressed: () => Leader.push(
                context,
                RecomMangaPage(),
                title: Text('Manga'),
                icon: Icon(FluentIcons.library),
              ),
            ),
            ListTile(
              leading: Icon(FluentIcons.plain_text),
              title: Text('Novel'),
              onPressed: () => Leader.push(
                context,
                NovelRail(),
                title: Text('Novel'),
                icon: Icon(FluentIcons.plain_text),
              ),
            ),
            if (kDebugMode)
              ListTile(
                title: Text("网络诊断"),
                onPressed: () {
                  Leader.push(context, NetworkSettingPage(),
                      title: Text("网络诊断"),
                      icon: Icon(
                        FluentIcons.bug,
                      ));
                },
              ),
            ListTile(
              leading: Icon(FluentIcons.message),
              title: Text(I18n.of(context).about),
              onPressed: () => Leader.push(
                context,
                AboutPage(newVersion: hasNewVersion),
                icon: Icon(FluentIcons.message),
                title: Text(I18n.of(context).about),
              ),
              trailing: Visibility(
                child: NewVersionChip(),
                visible: hasNewVersion,
              ),
            ),
            Observer(builder: (context) {
              if (accountStore.now != null)
                return ListTile(
                  leading: Icon(FluentIcons.sign_out),
                  title: Text(I18n.of(context).logout),
                  onPressed: () => _showLogoutDialog(context),
                );
              else
                return ListTile(
                  leading: Icon(FluentIcons.signin),
                  title: Text(I18n.of(context).login),
                  onPressed: () => Leader.push(
                    context,
                    LoginPage(),
                    icon: Icon(FluentIcons.signin),
                    title: Text(I18n.of(context).login),
                  ),
                );
            })
          ],
        )
      ],
    );
  }

  Future _showSavedLogDialog(BuildContext context) async {
    var savedLogFile = await LPrinter.savedLogFile();
    var content = savedLogFile.readAsStringSync();
    final result = await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Text("Log"),
            content: Container(
              child: Text(content),
              height: 400,
            ),
            actions: <Widget>[
              HyperlinkButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              HyperlinkButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        });
    switch (result) {
      case "OK":
        {}
        break;
      case "CANCEL":
        {}
        break;
    }
  }

  // ignore: unused_element
  _showMessage(BuildContext context) async {
    final link =
        "https://cdn.jsdelivr.net/gh/Notsfsssf/pixez-flutter@master/assets/json/host.json";
    try {
      final dio = Dio(BaseOptions(baseUrl: link));
      Response response = await dio.get("");
      final data = response.data as Map;
      print("${data['doh']}");
    } catch (e) {
      print(e);
    }
  }

  Future _showLogoutDialog(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Text(I18n.of(context).logout),
            actions: <Widget>[
              HyperlinkButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              HyperlinkButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        });
    switch (result) {
      case "OK":
        {
          accountStore.deleteAll();
        }
        break;
      case "CANCEL":
        {}
        break;
    }
  }

  // ignore: unused_element
  _showCacheBottomSheet(BuildContext context) async {
    await showDialog(
        context: context,
        // shape: const RoundedRectangleBorder(
        //     borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(16.0),
        //         topRight: Radius.circular(16.0))),
        builder: (context) {
          return SafeArea(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(I18n.of(context).clear_all_cache),
              ),
              Slider(
                value: 1,
                onChanged: (v) {},
              ),
              ListTile(
                title: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
              ListTile(
                title: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
        });
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
        builder: (BuildContext context) {
          return ContentDialog(
            title: Text(I18n.of(context).clear_all_cache),
            actions: <Widget>[
              HyperlinkButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              HyperlinkButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        },
        context: context);
    switch (result) {
      case "OK":
        {
          try {
            Directory tempDir = await getTemporaryDirectory();
            tempDir.deleteSync(recursive: true);
            GlanceIllustPersistProvider glanceIllustPersistProvider =
                GlanceIllustPersistProvider();
            await glanceIllustPersistProvider.open();
            await glanceIllustPersistProvider.deleteAll();
            await glanceIllustPersistProvider.close();
          } catch (e) {}
        }
        break;
    }
  }
}
