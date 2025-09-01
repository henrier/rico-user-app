import '../../models/category_model.dart';

class MockCategoryData {
  static final List<Category> _thirdLevelCategories = [
    Category(
      id: '3001',
      name: 'Latest',
      level: 3,
      children: [
        Category(id: '4001', name: 'Black Bolt', level: 4, parentId: '3001'),
        Category(id: '4002', name: 'White Flare', level: 4, parentId: '3001'),
        Category(
            id: '4003', name: 'Destined Rivals', level: 4, parentId: '3001'),
      ],
    ),
    Category(
      id: '3002',
      name: 'MEGA',
      level: 3,
      children: [
        Category(
            id: '4004', name: 'Journey Together', level: 4, parentId: '3002'),
        Category(
            id: '4005',
            name: 'Prismatic Evolutions',
            level: 4,
            parentId: '3002'),
        Category(
            id: '4006', name: 'Surging Sparks', level: 4, parentId: '3002'),
      ],
    ),
    Category(
      id: '3003',
      name: 'Promo',
      level: 3,
      children: [
        Category(id: '4007', name: 'Stella Crown', level: 4, parentId: '3003'),
        Category(
            id: '4008', name: 'Shrouded Fable', level: 4, parentId: '3003'),
        Category(
            id: '4009',
            name: 'Twilight Masquerade',
            level: 4,
            parentId: '3003'),
      ],
    ),
    Category(
      id: '3004',
      name: 'Scarlet & Valet',
      level: 3,
      children: [
        Category(
            id: '4010', name: 'Scarlet Collection', level: 4, parentId: '3004'),
        Category(
            id: '4011', name: 'Valet Collection', level: 4, parentId: '3004'),
        Category(
            id: '4012', name: 'Special Edition', level: 4, parentId: '3004'),
      ],
    ),
    Category(
      id: '3005',
      name: 'Sword & Shield',
      level: 3,
      children: [
        Category(id: '4013', name: 'Base Set', level: 4, parentId: '3005'),
        Category(id: '4014', name: 'Rebel Clash', level: 4, parentId: '3005'),
        Category(
            id: '4015', name: 'Darkness Ablaze', level: 4, parentId: '3005'),
        Category(id: '4016', name: 'Vivid Voltage', level: 4, parentId: '3005'),
      ],
    ),
    Category(
      id: '3006',
      name: 'Sun & Moon',
      level: 3,
      children: [
        Category(id: '4017', name: 'Base Set', level: 4, parentId: '3006'),
        Category(
            id: '4018', name: 'Guardians Rising', level: 4, parentId: '3006'),
        Category(
            id: '4019', name: 'Burning Shadows', level: 4, parentId: '3006'),
        Category(
            id: '4020', name: 'Shining Legends', level: 4, parentId: '3006'),
      ],
    ),
    Category(
      id: '3007',
      name: 'XY',
      level: 3,
      children: [
        Category(id: '4021', name: 'Base Set', level: 4, parentId: '3007'),
        Category(id: '4022', name: 'Flashfire', level: 4, parentId: '3007'),
        Category(id: '4023', name: 'Furious Fists', level: 4, parentId: '3007'),
      ],
    ),
    Category(
      id: '3008',
      name: 'Black & White',
      level: 3,
      children: [
        Category(id: '4024', name: 'Base Set', level: 4, parentId: '3008'),
        Category(
            id: '4025', name: 'Emerging Powers', level: 4, parentId: '3008'),
        Category(
            id: '4026', name: 'Noble Victories', level: 4, parentId: '3008'),
      ],
    ),
    Category(
      id: '3009',
      name: 'HeartGold & SoulSilver',
      level: 3,
      children: [
        Category(id: '4027', name: 'Base Set', level: 4, parentId: '3009'),
        Category(id: '4028', name: 'Unleashed', level: 4, parentId: '3009'),
        Category(id: '4029', name: 'Undaunted', level: 4, parentId: '3009'),
      ],
    ),
    Category(
      id: '3010',
      name: 'Platinum Series',
      level: 3,
      children: [
        Category(id: '4030', name: 'Base Set', level: 4, parentId: '3010'),
        Category(id: '4031', name: 'Rising Rivals', level: 4, parentId: '3010'),
        Category(
            id: '4032', name: 'Supreme Victors', level: 4, parentId: '3010'),
      ],
    ),
    Category(
      id: '3011',
      name: 'Diamond & Pearl',
      level: 3,
      children: [
        Category(id: '4033', name: 'Base Set', level: 4, parentId: '3011'),
        Category(
            id: '4034',
            name: 'Mysterious Treasures',
            level: 4,
            parentId: '3011'),
        Category(
            id: '4035', name: 'Secret Wonders', level: 4, parentId: '3011'),
      ],
    ),
    Category(
      id: '3012',
      name: 'EX Series',
      level: 3,
      children: [
        Category(
            id: '4036', name: 'Ruby & Sapphire', level: 4, parentId: '3012'),
        Category(id: '4037', name: 'Sandstorm', level: 4, parentId: '3012'),
        Category(id: '4038', name: 'Dragon', level: 4, parentId: '3012'),
      ],
    ),
  ];

  /// 获取所有三级类目
  static List<Category> getThirdLevelCategories() {
    return List.unmodifiable(_thirdLevelCategories);
  }

  /// 根据三级类目ID获取其下的四级类目
  static List<Category> getFourthLevelCategories(String thirdLevelId) {
    final thirdCategory = _thirdLevelCategories.firstWhere(
      (category) => category.id == thirdLevelId,
      orElse: () => const Category(id: '', name: '', level: 3),
    );

    if (thirdCategory.id.isEmpty) {
      return [];
    }

    return List.unmodifiable(thirdCategory.children);
  }

  /// 根据ID查找类目
  static Category? findCategoryById(String id) {
    // 先在三级类目中查找
    for (final category in _thirdLevelCategories) {
      if (category.id == id) {
        return category;
      }
      // 再在四级类目中查找
      for (final child in category.children) {
        if (child.id == id) {
          return child;
        }
      }
    }
    return null;
  }
}
