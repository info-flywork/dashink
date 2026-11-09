import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dashink/core/network/network_exception.dart';
import 'package:dashink/core/network/network_manager.dart';
import 'package:dashink/core/utils/enum/request_type.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/domain/shop/shop_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockNetwork extends Mock implements NetworkManager {}

void main() {
  const oldCatalog = ShopCatalog(items: [ShopItem(id: 'ball_klasik')]);
  const newCatalog = ShopCatalog(
    items: [
      ShopItem(id: 'ball_klasik'),
      ShopItem(id: 'ball_basket'),
    ],
  );

  late _MockNetwork network;
  late ShopRepository repo;

  setUpAll(() => registerFallbackValue(RequestType.get));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefManager.instance.init();
    network = _MockNetwork();
    repo = ShopRepository(network, SharedPrefManager.instance);
  });

  void serve(ShopCatalog catalog) => when(
    () => network.send<ShopCatalog>(
      path: any(named: 'path'),
      method: any(named: 'method'),
      parserModel: any(named: 'parserModel'),
    ),
  ).thenAnswer((_) async => catalog);

  group('ShopRepository', () {
    test(
      'önbellek yeni olsa da katalog her açılışta ağdan tazelenir',
      () async {
        serve(oldCatalog);
        await repo.catalog();
        expect(repo.cachedCatalog, oldCatalog);

        // Sunucuya yeni öğe eklendi: hemen görünmeli (24 saat beklememeli).
        serve(newCatalog);
        expect(await repo.catalog(), newCatalog);
        expect(repo.cachedCatalog, newCatalog);
      },
    );

    test('ağ yoksa önbellek döner', () async {
      serve(oldCatalog);
      await repo.catalog();
      when(
        () => network.send<ShopCatalog>(
          path: any(named: 'path'),
          method: any(named: 'method'),
          parserModel: any(named: 'parserModel'),
        ),
      ).thenThrow(NetworkException.emptyResponse());
      expect(await repo.catalog(), oldCatalog);
    });
  });
}
