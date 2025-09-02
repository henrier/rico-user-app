import 'package:flutter/material.dart';

import '../common/constants/app_constants.dart';
import '../models/productinfo/data.dart';

/// 商品信息项目组件
/// 对应Figma设计中的商品列表项
class ProductInfoItem extends StatelessWidget {
  /// 商品信息数据
  final ProductInfo productInfo;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否显示分隔线
  final bool showDivider;

  const ProductInfoItem({
    super.key,
    required this.productInfo,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品图片
                _buildProductImage(),
                const SizedBox(width: 12),
                // 商品信息
                Expanded(
                  child: _buildProductInfo(),
                ),
              ],
            ),
          ),
        ),
        // 分隔线
        if (showDivider) _buildDivider(),
      ],
    );
  }

  /// 构建商品图片
  Widget _buildProductImage() {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: productInfo.hasImages
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                productInfo.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholderImage();
                },
              ),
            )
          : _buildPlaceholderImage(),
    );
  }

  /// 构建占位图片
  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey[500],
        size: 32,
      ),
    );
  }

  /// 构建商品信息
  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 商品名称
        Text(
          productInfo.displayName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // 商品编码和等级
        Row(
          children: [
            // 商品编码
            Text(
              productInfo.code,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            // 商品等级
            if (productInfo.level.isNotEmpty)
              Text(
                productInfo.level,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // 标签区域
        _buildTags(),
      ],
    );
  }

  /// 构建标签区域
  Widget _buildTags() {
    return Row(
      children: [
        // 类目标签
        if (productInfo.categories.isNotEmpty)
          _buildTag(productInfo.categories.first.displayName),
        const SizedBox(width: 8),
        // 语言标签（模拟数据，实际应该从商品信息中获取）
        _buildTag('EN'),
      ],
    );
  }

  /// 构建单个标签
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin:
          const EdgeInsets.only(left: AppConstants.defaultPadding + 80 + 12),
      color: Colors.grey[300],
    );
  }
}

/// 商品信息加载项目组件
/// 用于显示加载状态的占位符
class ProductInfoLoadingItem extends StatelessWidget {
  const ProductInfoLoadingItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片占位符
          Container(
            width: 80,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          // 信息占位符
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 名称占位符
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // 编码占位符
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                // 标签占位符
                Row(
                  children: [
                    Container(
                      height: 24,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 24,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 商品信息空状态组件
class ProductInfoEmptyState extends StatelessWidget {
  /// 空状态消息
  final String message;

  /// 重试回调
  final VoidCallback? onRetry;

  const ProductInfoEmptyState({
    super.key,
    this.message = '暂无商品信息',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 商品信息错误状态组件
class ProductInfoErrorState extends StatelessWidget {
  /// 错误消息
  final String message;

  /// 重试回调
  final VoidCallback? onRetry;

  const ProductInfoErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}
