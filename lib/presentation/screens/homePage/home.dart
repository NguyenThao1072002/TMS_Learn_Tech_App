import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/course_card_model.dart';
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
import 'package:tms_app/data/datasources/blog_data.dart';
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

    final courseUseCase = GetIt.instance<CourseUseCase>();
    _controller = HomeController(courseUseCase);
    _screens = _controller.getScreens(
      HomePage(),
      DocumentListScreen(),
      //PopularCourses(courses: []),
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
  final courseUseCase = GetIt.instance<CourseUseCase>();

  late Future<List<CourseCardModel>> popularCoursesFuture;
  late Future<List<CourseCardModel>> discountCoursesFuture;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize futures
    _loadCourses();
  }

  void _loadCourses() {
    setState(() {
      hasError = false;
      errorMessage = '';
    });

    // popularCoursesFuture =
    //     courseUseCase.getPopularCourses().catchError((error) {
    //   setState(() {
    //     hasError = true;
    //     errorMessage = error.toString();
    //   });
    //   return <CourseCardModel>[];
    // });

    // discountCoursesFuture = courseUseCase.getAllCourses().catchError((error) {
    //   print('❌ Lỗi khi tải tất cả khóa học: $error');
    //   return <CourseCardModel>[];
    // });
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
              _loadCourses();
            });
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh tìm kiếm và thông tin người dùng
                const HomeUserHeader(),
                //Khám phá nhanh
                const HomeDiscoverWidget(),
                // Banner
                const BannerSlider(showText: false),
                //Danh mục
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
                              _loadCourses();
                            });
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),

                //Khóa học phổ biến
                FutureBuilder<List<CourseCardModel>>(
                  future: popularCoursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const PopularCourses(
                        courses: [],
                        isLoading: true,
                      );
                    } else if (snapshot.hasError) {
                      print(
                          '❌ Error loading popular courses in UI: ${snapshot.error}');
                      return PopularCourses(
                        courses: [],
                        error: 'Không thể tải khóa học: ${snapshot.error}',
                      );
                    } else if (snapshot.hasData) {
                      final courses = snapshot.data!;
                      print(
                          '✅ Popular courses loaded in UI: ${courses.length} items');
                      if (courses.isEmpty) {
                        return const PopularCourses(
                          courses: [],
                          error: "Không có khóa học phổ biến",
                        );
                      }
                      // In ra thông tin khóa học đầu tiên để kiểm tra
                      if (courses.isNotEmpty) {
                        final first = courses.first;
                        print(
                            '📘 First course: ${first.title}, ID: ${first.id}, Students: ${first.numberOfStudents}');
                      }
                      return PopularCourses(courses: courses);
                    } else {
                      print('⚠️ No data returned for popular courses');
                      return const PopularCourses(
                        courses: [],
                        error: "Không có dữ liệu",
                      );
                    }
                  },
                ),

                const SizedBox(height: AppDimensions.blockSpacing),
                //Khóa học giảm giá
                FutureBuilder<List<CourseCardModel>>(
                  future:
                      discountCoursesFuture, // Lấy danh sách khóa học giảm giá
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text("Error: ${snapshot.error}",
                              style: AppStyles.subText));
                    } else if (snapshot.hasData) {
                      return DiscountCourses(
                          courses:
                              snapshot.data!); // Hiển thị khóa học giảm giá
                    } else {
                      return const Center(
                          child: Text("No data available",
                              style: AppStyles.subText));
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
                      Builder(builder: (context) {
                        try {
                          final blogDataSource =
                              GetIt.instance<BlogDataSource>();
                          final featuredBlog = blogDataSource.getFeaturedBlog();

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BlogListScreen(),
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
                                      featuredBlog.imageUrl,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
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
                                          featuredBlog.summary,
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
                                              backgroundImage: NetworkImage(
                                                  featuredBlog.authorAvatar),
                                              radius: 12,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              featuredBlog.author,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${featuredBlog.readTime} phút đọc',
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
                        } catch (e) {
                          return const Center(
                              child: Text("Error loading featured blog",
                                  style: AppStyles.subText));
                        }
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.blockSpacing),

                // Đội ngũ của chúng tôi
                const TeachingStaffList(),

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
