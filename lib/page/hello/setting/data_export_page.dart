import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/glance_illust_persist.dart';
import 'package:pixez/page/history/history_store.dart';

class DataExportPage extends HookConsumerWidget {
  const DataExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).app_data)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(8.0),
              child: _buildColumn(context, ref),
            ),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(
                  Icons.cleaning_services_outlined,
                  color: errorColor,
                ),
                title: Text(
                  I18n.of(context).clear_all_cache,
                  style: TextStyle(color: errorColor),
                ),
                onTap: () async {
                  try {
                    await _showClearCacheDialog(context);
                  } catch (e) {}
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAppDataListTile(
          context,
          I18n.of(context).search_history,
          Icons.search,
          (tileContext) async {
            try {
              await tagHistoryStore.exportData(tileContext);
            } catch (e) {
              print(e);
            }
          },
          () async {
            try {
              await tagHistoryStore.importData();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
        Divider(),
        _buildAppDataListTile(
          context,
          I18n.of(context).bookmark_tag,
          Icons.star_outline,
          (tileContext) async {
            try {
              await bookTagStore.exportData(tileContext);
            } catch (e) {
              print(e);
            }
          },
          () async {
            try {
              await bookTagStore.importData();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
        Divider(),
        _buildAppDataListTile(
          context,
          I18n.of(context).illust_history,
          Icons.photo_library_outlined,
          (tileContext) async {
            try {
              await ref.read(historyProvider.notifier).fetch();
              await ref.read(historyProvider.notifier).exportData(tileContext);
            } catch (e) {
              print(e);
            }
          },
          () async {
            try {
              await ref.read(historyProvider.notifier).fetch();
              await ref.read(historyProvider.notifier).importData();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
        Divider(),
        _buildAppDataListTile(
          context,
          I18n.of(context).novel_history,
          Icons.menu_book_outlined,
          (tileContext) async {
            try {
              await novelHistoryStore.fetch();
              await novelHistoryStore.exportData(tileContext);
            } catch (e) {
              print(e);
            }
          },
          () async {
            try {
              await novelHistoryStore.fetch();
              await novelHistoryStore.importData();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
        Divider(),
        _buildAppDataListTile(
          context,
          I18n.of(context).mute_data,
          Icons.block,
          (tileContext) async {
            try {
              await muteStore.export(tileContext);
            } catch (e) {
              print(e);
            }
          },
          () async {
            try {
              await muteStore.importFile();
            } catch (e) {
              print(e);
              BotToast.showText(text: e.toString());
            }
          },
        ),
      ],
    );
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(I18n.of(context).clear_all_cache),
          actions: <Widget>[
            TextButton(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop("CANCEL");
              },
            ),
            TextButton(
              child: Text(I18n.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop("OK");
              },
            ),
          ],
        );
      },
      context: context,
    );
    switch (result) {
      case "OK":
        {
          try {
            Directory tempDir = await getTemporaryDirectory();
            tempDir.deleteSync(recursive: true);
            cleanGlanceData();
          } catch (e) {}
        }
        break;
    }
  }

  void cleanGlanceData() async {
    GlanceIllustPersistProvider glanceIllustPersistProvider =
        GlanceIllustPersistProvider();
    await glanceIllustPersistProvider.open();
    await glanceIllustPersistProvider.deleteAll();
    await glanceIllustPersistProvider.close();
  }

  Widget _buildAppDataListTile(
    BuildContext context,
    String title,
    IconData icon,
    Future<void> Function(BuildContext tileContext) onExport,
    Function() onImport,
  ) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: Text(I18n.of(context).import_title),
            onPressed: onImport,
          ),
          // Use the button's own context so the share sheet anchors to it on
          // tablets.
          Builder(
            builder: (tileContext) => TextButton(
              child: Text(I18n.of(context).export),
              onPressed: () => onExport(tileContext),
            ),
          ),
        ],
      ),
    );
  }
}
