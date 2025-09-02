import '../../models/audit_metadata.dart';
import '../../models/i18n_string.dart';
import '../../models/productcategory/product_category.dart';
import '../../models/user_info.dart';

/// 模拟类目数据
/// 用于开发和测试阶段，提供静态的类目数据
class MockCategoryData {
  /// 获取三级类目列表
  static List<Category> getThirdLevelCategories() {
    final now = DateTime.now();
    final auditMetadata = AuditMetadata(
      createdAt: now,
      updatedAt: now,
      createdBy: const UserInfo(id: 'system', name: 'System'),
      updatedBy: const UserInfo(id: 'system', name: 'System'),
    );

    return [
      Category(
        id: '3001',
        name: const I18NString(
            chinese: 'Scarlet & Violet',
            english: 'Scarlet & Violet',
            japanese: 'スカーレット&バイオレット'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3002',
        name:
            const I18NString(chinese: 'MEGA', english: 'MEGA', japanese: 'メガ'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3003',
        name: const I18NString(
            chinese: 'Stellar Crown',
            english: 'Stellar Crown',
            japanese: 'ステラークラウン'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3004',
        name: const I18NString(
            chinese: 'Collection', english: 'Collection', japanese: 'コレクション'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3005',
        name: const I18NString(
            chinese: 'Sword & Shield',
            english: 'Sword & Shield',
            japanese: 'ソード&シールド'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3006',
        name: const I18NString(
            chinese: 'Sun & Moon', english: 'Sun & Moon', japanese: 'サン&ムーン'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3007',
        name: const I18NString(chinese: 'XY', english: 'XY', japanese: 'XY'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3008',
        name: const I18NString(
            chinese: 'Black & White',
            english: 'Black & White',
            japanese: 'ブラック&ホワイト'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3009',
        name: const I18NString(
            chinese: 'HeartGold & SoulSilver',
            english: 'HeartGold & SoulSilver',
            japanese: 'ハートゴールド&ソウルシルバー'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3010',
        name: const I18NString(
            chinese: 'Platinum', english: 'Platinum', japanese: 'プラチナ'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3011',
        name: const I18NString(
            chinese: 'Diamond & Pearl',
            english: 'Diamond & Pearl',
            japanese: 'ダイヤモンド&パール'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
      Category(
        id: '3012',
        name: const I18NString(
            chinese: 'Ruby & Sapphire',
            english: 'Ruby & Sapphire',
            japanese: 'ルビー&サファイア'),
        categoryTypes: const [CategoryType.series1],
        auditMetadata: auditMetadata,
      ),
    ];
  }

  /// 根据三级类目ID获取四级类目列表
  static List<Category> getFourthLevelCategories(String thirdCategoryId) {
    final now = DateTime.now();
    final auditMetadata = AuditMetadata(
      createdAt: now,
      updatedAt: now,
      createdBy: const UserInfo(id: 'system', name: 'System'),
      updatedBy: const UserInfo(id: 'system', name: 'System'),
    );

    switch (thirdCategoryId) {
      case '3001': // Scarlet & Violet
        return [
          Category(
            id: '4001',
            name: const I18NString(
                chinese: 'Black Bolt',
                english: 'Black Bolt',
                japanese: 'ブラックボルト'),
            categoryTypes: const [CategoryType.series2],
            parentCategories: [
              Category(
                id: '3001',
                name: const I18NString(
                    chinese: 'Scarlet & Violet',
                    english: 'Scarlet & Violet',
                    japanese: 'スカーレット&バイオレット'),
                categoryTypes: const [CategoryType.series1],
                auditMetadata: auditMetadata,
              ),
            ],
            auditMetadata: auditMetadata,
          ),
          Category(
            id: '4002',
            name: const I18NString(
                chinese: 'White Flare',
                english: 'White Flare',
                japanese: 'ホワイトフレア'),
            categoryTypes: const [CategoryType.series2],
            parentCategories: [
              Category(
                id: '3001',
                name: const I18NString(
                    chinese: 'Scarlet & Violet',
                    english: 'Scarlet & Violet',
                    japanese: 'スカーレット&バイオレット'),
                categoryTypes: const [CategoryType.series1],
                auditMetadata: auditMetadata,
              ),
            ],
            auditMetadata: auditMetadata,
          ),
          Category(
            id: '4003',
            name: const I18NString(
                chinese: 'Destined Rivals',
                english: 'Destined Rivals',
                japanese: '運命のライバル'),
            categoryTypes: const [CategoryType.series2],
            parentCategories: [
              Category(
                id: '3001',
                name: const I18NString(
                    chinese: 'Scarlet & Violet',
                    english: 'Scarlet & Violet',
                    japanese: 'スカーレット&バイオレット'),
                categoryTypes: const [CategoryType.series1],
                auditMetadata: auditMetadata,
              ),
            ],
            auditMetadata: auditMetadata,
          ),
        ];

      case '3002': // MEGA
        return [
          Category(
            id: '4004',
            name: const I18NString(
                chinese: 'Journey Together',
                english: 'Journey Together',
                japanese: '一緒の旅'),
            categoryTypes: const [CategoryType.series2],
            parentCategories: [
              Category(
                id: '3002',
                name: const I18NString(
                    chinese: 'MEGA', english: 'MEGA', japanese: 'メガ'),
                categoryTypes: const [CategoryType.series1],
                auditMetadata: auditMetadata,
              ),
            ],
            auditMetadata: auditMetadata,
          ),
          Category(
            id: '4005',
            name: const I18NString(
                chinese: 'Twilight Masquerade',
                english: 'Twilight Masquerade',
                japanese: 'トワイライトマスカレード'),
            categoryTypes: const [CategoryType.series2],
            parentCategories: [
              Category(
                id: '3002',
                name: const I18NString(
                    chinese: 'MEGA', english: 'MEGA', japanese: 'メガ'),
                categoryTypes: const [CategoryType.series1],
                auditMetadata: auditMetadata,
              ),
            ],
            auditMetadata: auditMetadata,
          ),
          Category(
            id: '4006',
            name: const I18NString(
                chinese: 'Surging Sparks',
                english: 'Surging Sparks',
                japanese: 'サージングスパーク'),
            categoryTypes: const [CategoryType.series2],
            parentCategories: [
              Category(
                id: '3002',
                name: const I18NString(
                    chinese: 'MEGA', english: 'MEGA', japanese: 'メガ'),
                categoryTypes: const [CategoryType.series1],
                auditMetadata: auditMetadata,
              ),
            ],
            auditMetadata: auditMetadata,
          ),
        ];

      case '3003': // Stellar Crown
        return [
          Category(
            id: '4007',
            name: const I18NString(
                chinese: 'Stella Crown',
                english: 'Stella Crown',
                japanese: 'ステラクラウン'),
            categoryTypes: const [CategoryType.series2],
            parentCategories: [
              Category(
                id: '3003',
                name: const I18NString(
                    chinese: 'Stellar Crown',
                    english: 'Stellar Crown',
                    japanese: 'ステラークラウン'),
                categoryTypes: const [CategoryType.series1],
                auditMetadata: auditMetadata,
              ),
            ],
            auditMetadata: auditMetadata,
          ),
          Category(
            id: '4008',
            name: const I18NString(
                chinese: 'Shrouded Fable',
                english: 'Shrouded Fable',
                japanese: 'シュラウデッドフェーブル'),
            categoryTypes: const [CategoryType.series2],
            parentCategories: [
              Category(
                id: '3003',
                name: const I18NString(
                    chinese: 'Stellar Crown',
                    english: 'Stellar Crown',
                    japanese: 'ステラークラウン'),
                categoryTypes: const [CategoryType.series1],
                auditMetadata: auditMetadata,
              ),
            ],
            auditMetadata: auditMetadata,
          ),
          Category(
            id: '4009',
            name: const I18NString(
                chinese: 'Temporal Forces',
                english: 'Temporal Forces',
                japanese: 'テンポラルフォース'),
            categoryTypes: const [CategoryType.series2],
            parentCategories: [
              Category(
                id: '3003',
                name: const I18NString(
                    chinese: 'Stellar Crown',
                    english: 'Stellar Crown',
                    japanese: 'ステラークラウン'),
                categoryTypes: const [CategoryType.series1],
                auditMetadata: auditMetadata,
              ),
            ],
            auditMetadata: auditMetadata,
          ),
        ];

      default:
        return [];
    }
  }

  /// 根据类目ID查找类目
  static Category? findCategoryById(String categoryId) {
    // 先在三级类目中查找
    final thirdCategory = getThirdLevelCategories()
        .where((cat) => cat.id == categoryId)
        .firstOrNull;

    if (thirdCategory != null) {
      return thirdCategory;
    }

    // 在四级类目中查找
    for (final thirdCategory in getThirdLevelCategories()) {
      final fourthCategories = getFourthLevelCategories(thirdCategory.id);
      final fourthCategory =
          fourthCategories.where((cat) => cat.id == categoryId).firstOrNull;

      if (fourthCategory != null) {
        return fourthCategory;
      }
    }

    return null;
  }

  /// 获取所有类目的扁平列表
  static List<Category> getAllCategories() {
    final allCategories = <Category>[];

    // 添加三级类目
    allCategories.addAll(getThirdLevelCategories());

    // 添加四级类目
    for (final thirdCategory in getThirdLevelCategories()) {
      allCategories.addAll(getFourthLevelCategories(thirdCategory.id));
    }

    return allCategories;
  }
}

/// Dart 3.0+ 扩展方法，用于安全的firstOrNull操作
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
