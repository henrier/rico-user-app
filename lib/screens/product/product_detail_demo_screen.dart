import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 商品详情演示页面
/// 用于展示如何导航到商品详情新增页面
class ProductDetailDemoScreen extends ConsumerWidget {
  const ProductDetailDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情演示'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '点击下面的按钮来创建商品详情',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildDemoCard(
              context,
              title: 'Umbreon ex',
              code: 'DRI-031/182',
              rarity: 'Rainbow',
              imageUrl: 'https://example.com/umbreon.jpg',
            ),
            const SizedBox(height: 24),
            _buildDemoCard(
              context,
              title: 'Pikachu VMAX',
              code: 'SWS-188/185',
              rarity: 'Secret Rare',
              imageUrl: 'https://example.com/pikachu.jpg',
            ),
            const Spacer(),
            const Text(
              '这是一个演示页面，展示了如何从SPU选择页面导航到商品详情新增页面。',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context, {
    required String title,
    required String code,
    required String rarity,
    required String imageUrl,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToProductDetailCreate(
          context,
          title: title,
          code: code,
          imageUrl: imageUrl,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 占位图片
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.grey[400],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // 商品信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        rarity,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 箭头图标
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetailCreate(
    BuildContext context, {
    required String title,
    required String code,
    required String imageUrl,
  }) {
    // 生成模拟的SPU ID
    final spuId = 'spu_${code.replaceAll('/', '_').toLowerCase()}';
    
    context.pushNamed(
      'product-detail-create',
      queryParameters: {
        'spuId': spuId,
        'spuName': title,
        'spuCode': code,
        'spuImageUrl': imageUrl,
      },
    );
  }
}
