import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/domain/purchase/purchase_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const packs = [
    CoinPack(productId: 'p500', coins: 500),
    CoinPack(productId: 'p1200', coins: 1200),
    CoinPack(productId: 'p3000', coins: 3000),
  ];

  group('coinPackBonuses', () {
    test('büyük paket para başına daha fazla altın verir', () {
      final bonus = coinPackBonuses(packs, {
        'p500': (text: r'$0.99', amount: 0.99),
        'p1200': (text: r'$1.99', amount: 1.99),
        'p3000': (text: r'$3.99', amount: 3.99),
      });
      expect(bonus, {'p1200': 19, 'p3000': 49});
    });

    test('doğrusal fiyatta rozet yok', () {
      final bonus = coinPackBonuses(packs, {
        'p500': (text: '₺50', amount: 50),
        'p1200': (text: '₺120', amount: 120),
        'p3000': (text: '₺300', amount: 300),
      });
      expect(bonus, isEmpty);
    });

    test('fiyatı bilinmeyen paket yok sayılır', () {
      expect(
        coinPackBonuses(packs, {'p500': (text: r'$0.99', amount: 0.99)}),
        isEmpty,
      );
    });
  });
}
