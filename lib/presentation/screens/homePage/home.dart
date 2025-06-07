import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/banner_model.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/domain/usecases/banner_usecase.dart';
import 'package:tms_app/domain/usecases/blog_usecase.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/screens/blog/blog_list.dart';
import 'package:tms_app/presentation/screens/document/document_list_screen.dart';
import 'package:tms_app/presentation/screens/notification/notification_view.dart';
import 'package:tms_app/presentation/widgets/banner/banner_widget.dart';
import 'package:tms_app/presentation/widgets/component/footer.dart';
import 'package:tms_app/presentation/widgets/course/course_categories.dart';
import 'package:tms_app/presentation/widgets/course/discount_courses.dart';
import 'package:tms_app/presentation/widgets/course/popular_courses.dart';
import 'package:tms_app/presentation/widgets/home/home_app_bar.dart';
import 'package:tms_app/presentation/widgets/home/home_discover_widget.dart';
import 'package:tms_app/presentation/widgets/home/home_user_header.dart';
import 'package:tms_app/presentation/widgets/home/teaching_staff_list.dart';
import 'package:tms_app/presentation/widgets/navbar/bottom_navbar_widget.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
// import 'package:tms_app/data/datasources/blog_data.dart';
import '../../controller/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _screens = _controller.getScreens(
      HomePage(),
      DocumentListScreen(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.selectedIndex,
      builder: (context, index, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _screens[index],
          bottomNavigationBar: BottomNavBar(
            selectedIndex: index,
            onTap: _controller.onItemTapped,
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Biến đối tượng của các usecase
  final courseUseCase = GetIt.instance<CourseUseCase>();
  final bannerUseCase = GetIt.instance<BannerUseCase>();
  final blogUseCase = GetIt.instance<BlogUsecase>();

  // Biến lưu trữ các danh sách
  late Future<List<CourseCardModel>> popularCoursesFuture;
  late Future<List<CourseCardModel>> discountCoursesFuture;
  late Future<List<BannerModel>> bannersFuture;
  late Future<List<BlogCardModel>> blogsFuture;

  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData(); // Gọi hàm tải dữ liệu khi khởi tạo
  }

  void _loadData() {
    setState(() {
      hasError = false;
      errorMessage = '';
    });
    popularCoursesFuture =
        courseUseCase.getPopularCourses(); // Khóa học phổ biến
    discountCoursesFuture =
        courseUseCase.getDiscountCourses(); // Khóa học giảm giá
    bannersFuture = bannerUseCase.getBannersByPositionAndPlatform(
        'home', 'mobile'); // Banner
    blogsFuture = blogUseCase.getAllBlogs(); // Blogs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeAppBarWidget(
        unreadNotifications: 3,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadData(); // Tải lại dữ liệu khi kéo màn hình
            });
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh tìm kiếm và thông tin người dùng
                const HomeUserHeader(),
                // Khám phá nhanh
                const HomeDiscoverWidget(),
                // Banner
                FutureBuilder<List<BannerModel>>(
                  future: bannersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child:
                              Text('Error loading banners: ${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final banners = snapshot.data!;
                      return BannerSlider(banners: banners);
                    } else {
                      return const Center(
                          child: Text('No data available for banners'));
                    }
                  },
                ),
                
                // Đội ngũ của chúng tôi
                const TeachingStaffList(),
                
                // Danh mục
                const CategoryWidget(),

                // Hiển thị lỗi nếu có
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Không thể tải khóa học: $errorMessage',
                          style: AppStyles.errorText,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loadData(); // Cập nhật lại dữ liệu
                            });
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),

                // Khóa học phổ biến
                FutureBuilder<List<CourseCardModel>>(
                  future: popularCoursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const PopularCourses(courses: [], isLoading: true);
                    } else if (snapshot.hasError) {
                      return PopularCourses(
                        courses: [],
                        error: 'Không thể tải khóa học: ${snapshot.error}',
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final courses = snapshot.data!;
                      return PopularCourses(courses: courses);
                    } else {
                      return const PopularCourses(
                        courses: [],
                        error: 'Không có khóa học phổ biến',
                      );
                    }
                  },
                ),

                const SizedBox(height: AppDimensions.blockSpacing),
                // Khóa học giảm giá
                FutureBuilder<List<CourseCardModel>>(
                  future: discountCoursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const DiscountCourses(
                          courses: [], isLoading: true);
                    } else if (snapshot.hasError) {
                      return DiscountCourses(
                        courses: [],
                        error: 'Không thể tải khóa học: ${snapshot.error}',
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final courses = snapshot.data!;
                      return DiscountCourses(courses: courses);
                    } else {
                      return const DiscountCourses(
                        courses: [],
                        error: 'Không có khóa học giảm giá',
                      );
                    }
                  },
                ),

                const SizedBox(height: AppDimensions.blockSpacing),

                // Blog Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Blog công nghệ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BlogListScreen(),
                                ),
                              );
                            },
                            child: const Text('Xem tất cả'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<BlogCardModel>>(
                        future: blogsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Không thể tải bài viết: ${snapshot.error}',
                                style: AppStyles.errorText,
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            final featuredBlog =
                                snapshot.data!.first; // Lấy bài viết đầu tiên
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BlogListScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        featuredBlog.image,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 150,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 50,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            featuredBlog.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            featuredBlog.sumary,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                child: Text(
                                                  featuredBlog
                                                          .authorName.isNotEmpty
                                                      ? featuredBlog
                                                          .authorName[0]
                                                          .toUpperCase()
                                                      : "A",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                featuredBlog.authorName,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${featuredBlog.views} lượt xem',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: Text(
                                "Chưa có bài viết nào",
                                style: AppStyles.subText,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.blockSpacing),

                // Thêm footer vào đây
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
