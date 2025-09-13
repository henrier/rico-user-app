import '../../models/personalproduct/data.dart';
import '../../models/productinfo/data.dart';
import '../../models/i18n_string.dart';
import '../../models/audit_metadata.dart';
import '../../models/usershop/data.dart';

/// 批量编辑页面的模拟数据
class MockBulkEditData {
  static List<PersonalProduct> getMockProducts() {
    return [
      // 第一个商品 - 已选中
      PersonalProduct(
        id: 'product_1',
        price: 2500.0,
        quantity: 1,
        condition: PersonalProductCondition.lightlyPlayed,
        type: PersonalProductType.rawCard,
        status: PersonalProductStatus.listed,
        images: [
          'https://images.pokemontcg.io/sv4pt5/182.png', // Umbreon ex 图片
        ],
        productInfo: ProductInfo(
          id: 'spu_1',
          name: const I18NString(
            chinese: 'Umbreon ex',
            english: 'Umbreon ex',
            japanese: 'ブラッキーex',
          ),
          code: 'DRI-031/182',
          images: ['https://images.pokemontcg.io/sv4pt5/182.png'],
          auditMetadata: AuditMetadata(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        owner: UserShop(
          id: 'user_1',
          userId: 'user_1',
          shopName: '测试用户商店',
          auditMetadata: AuditMetadata(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        bundleInfo: const BundleInfo(),
        auditMetadata: AuditMetadata(
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      ),
      
      // 第二个商品 - 未选中
      PersonalProduct(
        id: 'product_2',
        price: 2500.0,
        quantity: 1,
        condition: PersonalProductCondition.lightlyPlayed,
        type: PersonalProductType.rawCard,
        status: PersonalProductStatus.listed,
        images: [
          'https://images.pokemontcg.io/sv4pt5/182.png',
        ],
        productInfo: ProductInfo(
          id: 'spu_2',
          name: const I18NString(
            chinese: 'Umbreon ex',
            english: 'Umbreon ex',
            japanese: 'ブラッキーex',
          ),
          code: 'DRI-031/182',
          images: ['https://images.pokemontcg.io/sv4pt5/182.png'],
          auditMetadata: AuditMetadata(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        owner: UserShop(
          id: 'user_1',
          userId: 'user_1',
          shopName: '测试用户商店',
          auditMetadata: AuditMetadata(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        bundleInfo: const BundleInfo(),
        auditMetadata: AuditMetadata(
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now(),
        ),
      ),
      
      // 第三个商品 - 未选中
      PersonalProduct(
        id: 'product_3',
        price: 2500.0,
        quantity: 1,
        condition: PersonalProductCondition.lightlyPlayed,
        type: PersonalProductType.rawCard,
        status: PersonalProductStatus.listed,
        images: [
          'https://images.pokemontcg.io/sv4pt5/182.png',
        ],
        productInfo: ProductInfo(
          id: 'spu_3',
          name: const I18NString(
            chinese: 'Umbreon ex',
            english: 'Umbreon ex',
            japanese: 'ブラッキーex',
          ),
          code: 'DRI-031/182',
          images: ['https://images.pokemontcg.io/sv4pt5/182.png'],
          auditMetadata: AuditMetadata(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        owner: UserShop(
          id: 'user_1',
          userId: 'user_1',
          shopName: '测试用户商店',
          auditMetadata: AuditMetadata(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        bundleInfo: const BundleInfo(),
        auditMetadata: AuditMetadata(
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now(),
        ),
      ),
      
      // 第四个商品 - 未选中
      PersonalProduct(
        id: 'product_4',
        price: 2500.0,
        quantity: 1,
        condition: PersonalProductCondition.lightlyPlayed,
        type: PersonalProductType.rawCard,
        status: PersonalProductStatus.listed,
        images: [
          'https://images.pokemontcg.io/sv4pt5/182.png',
        ],
        productInfo: ProductInfo(
          id: 'spu_4',
          name: const I18NString(
            chinese: 'Umbreon ex',
            english: 'Umbreon ex',
            japanese: 'ブラッキーex',
          ),
          code: 'DRI-031/182',
          images: ['https://images.pokemontcg.io/sv4pt5/182.png'],
          auditMetadata: AuditMetadata(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        owner: UserShop(
          id: 'user_1',
          userId: 'user_1',
          shopName: '测试用户商店',
          auditMetadata: AuditMetadata(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        bundleInfo: const BundleInfo(),
        auditMetadata: AuditMetadata(
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          updatedAt: DateTime.now(),
        ),
      ),
    ];
  }
  
  /// 获取初始选中的商品ID（根据Figma设计，第一个商品是选中的）
  static Set<String> getInitialSelectedIds() {
    return {'product_1'};
  }
}
