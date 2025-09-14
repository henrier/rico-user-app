import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsSection extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabChanged;
  final int publishedCount;
  final int pendingCount;
  final int soldOutCount;
  final bool isLoadingCounts;

  const StatsSection({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    this.publishedCount = 0,
    this.pendingCount = 0,
    this.soldOutCount = 0,
    this.isLoadingCounts = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Published', publishedCount, 'Published'),
          _buildStatItem('Pending', pendingCount, 'Pending'),
          _buildStatItem('Sold Out', soldOutCount, 'Sold Out'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, String tabKey) {
    final isActive = selectedTab == tabKey;
    
    return GestureDetector(
      onTap: () => onTabChanged(tabKey),
      child: Column(
        children: [
          // 显示标签和数量
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: const Color(0xFF212222),
                    fontFamily: 'Roboto',
                  ),
                ),
                TextSpan(
                  text: ' (',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: const Color(0xFF212222),
                    fontFamily: 'Roboto',
                  ),
                ),
                TextSpan(
                  text: isLoadingCounts ? '...' : _formatCount(count),
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: isLoadingCounts ? const Color(0xFF919191) : const Color(0xFF212222),
                    fontFamily: 'Roboto',
                  ),
                ),
                TextSpan(
                  text: ')',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: const Color(0xFF212222),
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: 32.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: const Color(0xFF0DEE80),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
        ],
      ),
    );
  }
  
  /// 格式化数量显示
  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
  }
}
