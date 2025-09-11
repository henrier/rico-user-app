import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/themes/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/product_card.dart';
import '../../widgets/bundle_card.dart';
import '../../widgets/stats_section.dart';
import '../../widgets/bottom_action_buttons.dart';
import 'package:provider/provider.dart';
import '../../providers/product_info_provider.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String selectedLanguage = 'Pokemon EN';
  String selectedTab = 'Published';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildTopBar(),
            
            // 统计信息
            StatsSection(
              selectedTab: selectedTab,
              onTabChanged: (tab) {
                setState(() {
                  selectedTab = tab;
                });
              },
            ),
            
            // 分割线
            Container(
              height: 1.h,
              color: const Color(0xFFF4F4F6),
            ),
            
            // 操作按钮区域
            _buildActionSection(),
            
            // Bundle Sales 部分
            _buildBundleSalesSection(),
            
            // 商品列表
            Expanded(
              child: _buildProductList(),
            ),
            
            // 底部操作按钮
            BottomActionButtons(
              onAddProduct: () {
                // 导航到添加商品页面
                Navigator.pushNamed(context, '/home/categories');
              },
              onBulkAddProduct: () {
                // 导航到批量添加商品页面
                Navigator.pushNamed(context, '/home/batch-add-product');
              },
              onCreateBundle: () {
                // 导航到创建Bundle页面
                Navigator.pushNamed(context, '/home/categories');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 88.h,
      color: Colors.white,
      child: Stack(
        children: [
          // 背景装饰
          Container(
            height: 88.h,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F4F6),
            ),
          ),
          
          // 返回按钮
          Positioned(
            left: 30.w,
            top: 24.h,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF212222),
                ),
              ),
            ),
          ),
          
          // 标题
          Center(
            child: Text(
              'Manage Listing',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF212222),
              ),
            ),
          ),
          
          // 语言选择器
          Positioned(
            right: 30.w,
            top: 24.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF000000).withOpacity(0.2)),
                borderRadius: BorderRadius.circular(33.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedLanguage,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF212222),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 22.w,
                    color: const Color(0xFF212222),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      child: Row(
        children: [
          // 批量编辑按钮
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F6),
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit,
                  size: 22.w,
                  color: const Color(0xFF212222),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Bulk Edit',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: const Color(0xFF212222),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 最新列表和筛选
          Row(
            children: [
              Text(
                'Latest Listing',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: const Color(0xFF212222),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.keyboard_arrow_down,
                size: 22.w,
                color: const Color(0xFF212222),
              ),
              SizedBox(width: 20.w),
              Icon(
                Icons.filter_list,
                size: 30.w,
                color: const Color(0xFF212222),
              ),
              SizedBox(width: 8.w),
              Text(
                'Filter',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: const Color(0xFF212222),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBundleSalesSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Bundle Sales',
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF212222),
            ),
          ),
          Row(
            children: [
              Text(
                'More',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF212222),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.keyboard_arrow_down,
                size: 22.w,
                color: const Color(0xFF212222),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      children: [
        // Bundle 卡片
        BundleCard(
          title: 'Bundle 1',
          price: 'RM 2,500',
          originalPrice: 'RM 2,500',
          days: '12',
          hours: '12',
          minutes: '12',
          seconds: '12',
        ),
        SizedBox(height: 20.h),
        BundleCard(
          title: 'Bundle 2',
          price: 'RM 2,500',
          originalPrice: 'RM 2,500',
          days: '12',
          hours: '12',
          minutes: '12',
          seconds: '12',
        ),
        SizedBox(height: 20.h),
        
        // 商品列表
        ProductCard(
          name: 'Umbreon ex',
          code: 'DRI-031/182',
          type: 'Holo',
          price: 'RM 2,500',
          condition: 'Lightly Played',
          quantity: 'x1',
        ),
        ProductCard(
          name: 'Umbreon ex',
          code: 'DRI-031/182',
          type: 'Holo',
          price: 'RM 2,500',
          condition: 'Lightly Played',
          quantity: 'x1',
          grade: 'PSA10',
        ),
        ProductCard(
          name: 'Umbreon ex',
          code: 'DRI-031/182',
          type: 'Holo',
          price: 'RM 2,500',
          condition: 'Lightly Played',
          quantity: 'x1',
          grade: 'BGS Black Label',
        ),
        ProductCard(
          name: 'Umbreon ex',
          code: 'DRI-031/182',
          type: 'Holo',
          price: 'RM 2,500',
          condition: 'Lightly Played',
          quantity: 'x1',
          grade: 'BGS Black Label',
        ),
      ],
    );
  }

}
