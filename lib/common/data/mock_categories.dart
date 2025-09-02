import '../../models/audit_metadata.dart';
import '../../models/i18n_string.dart';
import '../../models/productcategory/product_category.dart';
import '../../models/user_info.dart';

class MockCategoryData {
  // 创建默认的审计信息
  static final AuditMetadata _defaultAuditMetadata = AuditMetadata(
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    createdBy: const UserInfo(id: 'system', name: 'System'),
    updatedBy: const UserInfo(id: 'admin', name: 'Admin'),
  );

  // 三级类目数据
  static final List<Category> _thirdLevelCategories = [
    Category(
      id: '3001',
      name: const I18NString(
        chinese: '最新',
        english: 'Latest',
        japanese: '最新',
      ),
      categoryTypes: const [CategoryType.series1],
      auditMetadata: _defaultAuditMetadata,
    ),
    Category(
      id: '3002',
      name: const I18NString(
        chinese: 'MEGA',
        english: 'MEGA',
        japanese: 'MEGA',
      ),
      categoryTypes: const [CategoryType.series1],
      auditMetadata: _defaultAuditMetadata,
    ),
    Category(
      id: '3003',
      name: const I18NString(
        chinese: '促销',
        english: 'Promo',
        japanese: 'プロモ',
      ),
      categoryTypes: const [CategoryType.series1],
      auditMetadata: _defaultAuditMetadata,
    ),
    Category(
      id: '3004',
      name: const I18NString(
        chinese: '朱紫系列',
        english: 'Scarlet & Violet',
        japanese: 'スカーレット&バイオレット',
      ),
      categoryTypes: const [CategoryType.series1],
      auditMetadata: _defaultAuditMetadata,
    ),
    Category(
      id: '3005',
      name: const I18NString(
        chinese: '剑盾系列',
        english: 'Sword & Shield',
        japanese: 'ソード&シールド',
      ),
      categoryTypes: const [CategoryType.series1],
      auditMetadata: _defaultAuditMetadata,
    ),
    Category(
      id: '3006',
      name: const I18NString(
        chinese: '日月系列',
        english: 'Sun & Moon',
        japanese: 'サン&ムーン',
      ),
      categoryTypes: const [CategoryType.series1],
      auditMetadata: _defaultAuditMetadata,
    ),
    Category(
      id: '3007',
      name: const I18NString(
        chinese: 'XY系列',
        english: 'XY',
        japanese: 'XY',
      ),
      categoryTypes: const [CategoryType.series1],
      auditMetadata: _defaultAuditMetadata,
    ),
    Category(
      id: '3008',
      name: const I18NString(
        chinese: '黑白系列',
        english: 'Black & White',
        japanese: 'ブラック&ホワイト',
      ),
      categoryTypes: const [CategoryType.series1],
      auditMetadata: _defaultAuditMetadata,
    ),
  ];

  // 四级类目数据
  static final Map<String, List<Category>> _fourthLevelCategories = {
    '3001': [
      Category(
        id: '4001',
        name: const I18NString(
          chinese: '黑色闪电',
          english: 'Black Bolt',
          japanese: 'ブラックボルト',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[0]],
        auditMetadata: _defaultAuditMetadata,
      ),
      Category(
        id: '4002',
        name: const I18NString(
          chinese: '白色闪焰',
          english: 'White Flare',
          japanese: 'ホワイトフレア',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[0]],
        auditMetadata: _defaultAuditMetadata,
      ),
      Category(
        id: '4003',
        name: const I18NString(
          chinese: '宿命对手',
          english: 'Destined Rivals',
          japanese: '宿命のライバル',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[0]],
        auditMetadata: _defaultAuditMetadata,
      ),
    ],
    '3002': [
      Category(
        id: '4004',
        name: const I18NString(
          chinese: '共同旅程',
          english: 'Journey Together',
          japanese: '共に歩む旅路',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[1]],
        auditMetadata: _defaultAuditMetadata,
      ),
      Category(
        id: '4005',
        name: const I18NString(
          chinese: '棱镜进化',
          english: 'Prismatic Evolutions',
          japanese: 'プリズマティック進化',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[1]],
        auditMetadata: _defaultAuditMetadata,
      ),
      Category(
        id: '4006',
        name: const I18NString(
          chinese: '激流火花',
          english: 'Surging Sparks',
          japanese: 'サージングスパーク',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[1]],
        auditMetadata: _defaultAuditMetadata,
      ),
    ],
    '3003': [
      Category(
        id: '4007',
        name: const I18NString(
          chinese: '星辰王冠',
          english: 'Stella Crown',
          japanese: 'ステラクラウン',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[2]],
        auditMetadata: _defaultAuditMetadata,
      ),
      Category(
        id: '4008',
        name: const I18NString(
          chinese: '神秘传说',
          english: 'Shrouded Fable',
          japanese: '神秘の物語',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[2]],
        auditMetadata: _defaultAuditMetadata,
      ),
    ],
    '3004': [
      Category(
        id: '4010',
        name: const I18NString(
          chinese: '朱红收藏',
          english: 'Scarlet Collection',
          japanese: 'スカーレットコレクション',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[3]],
        auditMetadata: _defaultAuditMetadata,
      ),
      Category(
        id: '4011',
        name: const I18NString(
          chinese: '紫罗兰收藏',
          english: 'Violet Collection',
          japanese: 'バイオレットコレクション',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[3]],
        auditMetadata: _defaultAuditMetadata,
      ),
    ],
    '3005': [
      Category(
        id: '4013',
        name: const I18NString(
          chinese: '基础系列',
          english: 'Base Set',
          japanese: 'ベースセット',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[4]],
        auditMetadata: _defaultAuditMetadata,
      ),
      Category(
        id: '4014',
        name: const I18NString(
          chinese: '反叛冲突',
          english: 'Rebel Clash',
          japanese: 'リベルクラッシュ',
        ),
        categoryTypes: const [CategoryType.series2],
        parentCategories: [_thirdLevelCategories[4]],
        auditMetadata: _defaultAuditMetadata,
      ),
    ],
  };

  /// 获取所有三级类目
  static List<Category> getThirdLevelCategories() {
    return List.unmodifiable(_thirdLevelCategories);
  }

  /// 根据三级类目ID获取其下的四级类目
  static List<Category> getFourthLevelCategories(String thirdLevelId) {
    return List.unmodifiable(_fourthLevelCategories[thirdLevelId] ?? []);
  }

  /// 根据ID查找类目
  static Category? findCategoryById(String id) {
    // 先在三级类目中查找
    for (final category in _thirdLevelCategories) {
      if (category.id == id) {
        return category;
      }
    }

    // 再在四级类目中查找
    for (final fourthLevelList in _fourthLevelCategories.values) {
      for (final category in fourthLevelList) {
        if (category.id == id) {
          return category;
        }
      }
    }

    return null;
  }
}
