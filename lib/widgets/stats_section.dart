import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsSection extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabChanged;

  const StatsSection({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Published (3)', 'Published'),
          _buildStatItem('Draft (10)', 'Draft'),
          _buildStatItem('Sold (1,000)', 'Sold'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text, String tabKey) {
    final isActive = selectedTab == tabKey;
    
    return GestureDetector(
      onTap: () => onTabChanged(tabKey),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              color: const Color(0xFF212222),
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
}
