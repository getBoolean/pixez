import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/fluent/page/picture/illust_lighting_page.dart';

class RecomMangaPage extends StatefulWidget {
  const RecomMangaPage({Key? key}) : super(key: key);

  @override
  State<RecomMangaPage> createState() => _RecomMangaPageState();
}

class _RecomMangaPageState extends State<RecomMangaPage> {
  EasyRefreshController controller = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  late LightingStore _store;

  @override
  void initState() {
    _store = LightingStore(
      ApiSource(
        futureGet: () => apiClient.getMangaRecommend(),
      ),
    );
    _store.fetch();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text("Manga"),
      ),
      content: Observer(builder: (_) {
        return EasyRefresh(
          controller: controller,
          onLoad: () {
            _store.fetchNext();
          },
          onRefresh: () {
            _store.fetch();
          },
          child: Container(
            child: _store.iStores.isEmpty
                ? Container()
                : ListView.builder(
                    itemBuilder: (context, index) {
                      final illust = _store.iStores[index].illusts;
                      return Card(
                        child: IconButton(
                            onPressed: () {
                              Leader.push(
                                context,
                                IllustLightingPage(id: illust.id),
                                icon: Icon(FluentIcons.picture),
                                title: Text(I18n.of(context).illust_id +
                                    ': ${illust.id}'),
                              );
                            },
                            icon: PixivImage(illust!.imageUrls.medium)),
                      );
                    },
                    itemCount: _store.iStores.length,
                  ),
          ),
        );
      }),
    );
  }
}
