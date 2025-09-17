import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../viewmodels/product_search_mock_viewmodel.dart';
import '../../models/productinfo/data.dart';

class ProductSearchMockScreen extends ConsumerStatefulWidget {
  const ProductSearchMockScreen({super.key});

  @override
  ConsumerState<ProductSearchMockScreen> createState() => _ProductSearchMockScreenState();
}

class _ProductSearchMockScreenState extends ConsumerState<ProductSearchMockScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch() {
    final vm = ref.read(productSearchMockProvider.notifier);
    vm.search(_controller.text);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productSearchMockProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildSearchBar(),
            if (!state.isEmpty) _buildFilter(context),
            Container(height: 20.h, color: const Color(0xFFF1F1F3)),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 88.h,
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 26.w),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF212222), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 72.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(59.r),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 24.w, right: 12.w),
                    child: Icon(Icons.search, color: const Color(0xFF212222), size: 30.w),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Search for products...',
                        hintStyle: TextStyle(color: const Color(0xFF212222), fontSize: 28.sp, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 20.h),
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: 28.sp, color: const Color(0xFF212222), fontFamily: 'Roboto', fontWeight: FontWeight.w400),
                      onSubmitted: (_) => _onSearch(),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: _onSearch,
            child: Container(
              height: 72.h,
              width: 142.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(59.r),
              ),
              child: Center(
                child: Text('Search', style: TextStyle(color: const Color(0xFF212222), fontSize: 28.sp, fontWeight: FontWeight.w400)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 88.h,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () async {
          // 简化版：模拟筛选（仅Level）
          final vm = ref.read(productSearchMockProvider.notifier);
          final state = ref.read(productSearchMockProvider);
          final current = state.filterConditions['Level'] ?? <String>{};
          final options = {'SSR', 'SR', 'R'};

          final selected = await showDialog<Set<String>>(
            context: context,
            builder: (context) {
              final temp = {...current};
              return AlertDialog(
                title: const Text('Level 筛选'),
                content: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: options.map((o) {
                        final checked = temp.contains(o);
                        return CheckboxListTile(
                          title: Text(o),
                          value: checked,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) temp.add(o); else temp.remove(o);
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, current), child: const Text('清除')),
                  ElevatedButton(onPressed: () => Navigator.pop(context, temp), child: const Text('确定')),
                ],
              );
            },
          );

          if (selected != null) {
            await vm.applyFilter({'Level': selected});
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 30.w, color: const Color(0xFF212222)),
            SizedBox(width: 8.w),
            Text('Filter', style: TextStyle(fontSize: 24.sp, color: const Color(0xFF212222), fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ProductSearchMockState state) {
    if (state.isEmpty) return _buildInit();
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.productList.isEmpty) return _buildEmpty();
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: state.productList.length,
      separatorBuilder: (_, __) => Container(height: 0.5.h, color: const Color(0xFFF1F1F3)),
      itemBuilder: (context, index) => _buildItem(state.productList[index]),
    );
  }

  Widget _buildInit() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search, size: 64, color: Color(0xFFB8B8B8)),
          SizedBox(height: 16),
          Text('Search for Products', style: TextStyle(fontSize: 18, color: Color(0xFF919191))),
          SizedBox(height: 8),
          Text('Enter product name or code to search', style: TextStyle(fontSize: 14, color: Color(0xFFB8B8B8))),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(60)),
            child: const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFB8B8B8)),
          ),
          const SizedBox(height: 24),
          const Text('No matching items', style: TextStyle(fontSize: 18, color: Color(0xFF919191))),
        ],
      ),
    );
  }

  Widget _buildItem(ProductInfo p) {
    return Container(
      height: 120,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 88,
            decoration: BoxDecoration(color: const Color(0xFFF4F4F6), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.image_outlined, color: Colors.grey),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.displayName, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF212222))),
                const SizedBox(height: 6),
                Row(children: [
                  Text(p.code, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF919191))),
                  Container(width: 2, height: 14, margin: const EdgeInsets.symmetric(horizontal: 8), color: const Color(0xFF919191)),
                  Text(p.level, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF919191))),
                ]),
                const Spacer(),
                Row(children: [
                  Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD3D3D3)), borderRadius: BorderRadius.circular(6)),
                    child: Center(child: Text(p.categories.isNotEmpty ? (p.categories.first.displayName ?? p.categories.first.name.toString()) : 'Pokémon', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF919191)))),
                  ),
                  if (p.cardLanguage.value.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      height: 24,
                      width: 40,
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD3D3D3)), borderRadius: BorderRadius.circular(6)),
                      child: Center(child: Text(p.cardLanguage.value, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF919191)))),
                    ),
                  ],
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

