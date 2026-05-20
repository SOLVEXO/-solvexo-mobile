// import 'package:book_store_app/app/components/custom_app_bar_two.dart';
// import 'package:book_store_app/app/modules/category/widgets/category_search_bar.dart';
// import 'package:book_store_app/app/modules/category/widgets/category_search_list.dart';
// import 'package:book_store_app/app/modules/category/widgets/category_tile.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';

// class CategoriesScreen extends StatelessWidget {
//   CategoriesScreen({super.key});

//   final controller = Get.put(CategoryController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBarTwo(title: 'Categories'),
//       backgroundColor: const Color(0xffF7F8FA),
//       body: Column(
//         children: [
//           CategorySearchBar(controller: controller),

//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (controller.searchQuery.value.isNotEmpty) {
//                 return CategorySearchList(controller: controller);
//               }

//               if (controller.categoryTrees.isEmpty) {
//                 return const CategoryEmptyView();
//               }

//               return RefreshIndicator(
//                 onRefresh: controller.refresh,
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: controller.categoryTrees.length,
//                   itemBuilder: (_, index) {
//                     return CategoryTile(
//                       category: controller.categoryTrees[index],
//                       level: 0,
//                     );
//                   },
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
