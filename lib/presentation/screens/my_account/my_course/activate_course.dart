import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/presentation/controller/my_course/activate_course_controller.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/domain/usecases/my_course/activate_course_usecase.dart';
import 'package:dio/dio.dart';
import 'package:tms_app/data/services/my_course/activate_course_service.dart';
import 'package:tms_app/data/repositories/my_course/activate_course_repository_impl.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/my_course.dart';

class ActivateCourseScreen extends StatefulWidget {
  const ActivateCourseScreen({Key? key}) : super(key: key);

  @override
  State<ActivateCourseScreen> createState() => _ActivateCourseScreenState();
}

class _ActivateCourseScreenState extends State<ActivateCourseScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _activationCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _studyHoursController = TextEditingController();
  final TextEditingController _socialMediaHoursController = TextEditingController();
  final TextEditingController _sleepHoursController = TextEditingController();

  // Controller
  late ActivateCourseController _activateCourseController;

  // Theme colors
  final Color primaryColor = const Color(0xFF3498DB); // Primary blue
  final Color lightBlueColor = const Color(0xFFE1F5FE); // Light blue background
  final Color accentColor = const Color(0xFF2980B9); // Darker blue for accents

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Create a new controller instance with direct dependency creation
    final dio = Dio();
    final service = ActivateCourseService(dio);
    final repository = ActivateCourseRepositoryImpl(activateCourseService: service);
    final checkCourseCodeUseCase = CheckCourseCodeUseCase(repository);
    final activateCourseUseCase = ActivateCourseUseCase(repository);
    
    _activateCourseController = ActivateCourseController(
      checkCourseCodeUseCase: checkCourseCodeUseCase,
      activateCourseUseCase: activateCourseUseCase,
    );
    
    _activateCourseController.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _activationCodeController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _studyHoursController.dispose();
    _socialMediaHoursController.dispose();
    _sleepHoursController.dispose();
    super.dispose();
  }

  // Check activation code
  Future<void> _checkActivationCode() async {
    if (!_formKey.currentState!.validate()) return;

    final code = _activationCodeController.text.trim().toUpperCase();
    _activateCourseController.setActivationCode(code);

    final isValid = await _activateCourseController.checkActivationCode();
    if (isValid) {
      _activateCourseController.nextStep();
    }
  }

  // Move to step 3 (study time)
  void _moveToStudyTimeStep() {
    if (!_formKey.currentState!.validate()) return;
    
    // Save basic info from step 2
    _activateCourseController.setEmail(_emailController.text);
    
    try {
      int age = int.parse(_birthdayController.text);
      _activateCourseController.setBirthday(age);
    } catch (e) {
      // Use default
    }
    
    _activateCourseController.nextStep();
  }

  // Move to step 4 (learning style)
  void _moveToLearningStyleStep() {
    if (!_formKey.currentState!.validate()) return;
    
    // Save study time info from step 3
    try {
      int studyHours = int.parse(_studyHoursController.text);
      _activateCourseController.setStudyHoursPerWeek(studyHours);
    } catch (e) {
      // Use default
    }
    
    try {
      int socialHours = int.parse(_socialMediaHoursController.text);
      _activateCourseController.setTimeSpentOnSocialMedia(socialHours);
    } catch (e) {
      // Use default
    }
    
    try {
      int sleepHours = int.parse(_sleepHoursController.text);
      _activateCourseController.setSleepHoursPerNight(sleepHours);
    } catch (e) {
      // Use default
    }
    
    _activateCourseController.nextStep();
  }

  // Complete activation
  Future<void> _finishActivation() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _activateCourseController.activateCourse();
    if (success) {
      _showSuccessDialog();
    }
  }

  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 24,
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon và hiệu ứng
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green[600],
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'KÍCH HOẠT THÀNH CÔNG',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(color: Colors.grey.withOpacity(0.2), height: 1),
              // Nội dung
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                        children: [
                          const TextSpan(
                              text:
                                  'Bạn đã kích hoạt thành công khóa học với mã '),
                          TextSpan(
                            text:
                                '"${_activationCodeController.text.trim().toUpperCase()}"',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue[700], size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Khóa học đã được thêm vào danh sách "Khóa học của tôi".',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to My Course Screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MyCourseScreen(), 
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Vào học ngay',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Reset form
                    _activateCourseController.reset();
                    _activationCodeController.clear();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Kích hoạt mã khác',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _activateCourseController,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Kích hoạt khóa học',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: child,
            );
          },
          child: Consumer<ActivateCourseController>(
            builder: (context, controller, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      lightBlueColor.withOpacity(0.3),
                      lightBlueColor.withOpacity(0.5),
                    ],
                  ),
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Title and progress indicator
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 24),
                                child: _buildTitleSection(controller),
                              ),
                              
                              // Form content based on current step
                              Expanded(
                                child: _buildCurrentStepContent(controller),
                              ),
                              
                              // Footer buttons
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (controller.errorMessage != null)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              controller.errorMessage!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  // Next/Back buttons
                                  _buildNavigationButtons(controller),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  // Build step circle
  Widget _buildStepCircle(int step, String label, bool isActive, bool isCurrent) {
    // Only show steps if code has been validated 
    if (step > 1 && _activateCourseController.currentStep == 1) {
      return const SizedBox.shrink();
    }
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent 
                  ? primaryColor 
                  : (isActive ? Colors.blue[100] : Colors.grey[300]),
              border: Border.all(
                color: isCurrent ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: isCurrent || isActive
                  ? Icon(
                      isActive && !isCurrent ? Icons.check : null,
                      color: Colors.white,
                      size: 18,
                    )
                  : Text(
                      step.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isCurrent ? primaryColor : Colors.grey[600],
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build step line
  Widget _buildStepLine(bool isActive) {
    // Hide step lines if code hasn't been validated
    if (_activateCourseController.currentStep == 1) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: 30,
      height: 2,
      color: isActive ? primaryColor : Colors.grey[300],
    );
  }

  // Build form content based on current step
  Widget _buildCurrentStepContent(ActivateCourseController controller) {
    if (controller.currentStep == 1) {
      return _buildCodeActivationStep(controller);
    }
    
    // Only show survey steps if code is valid
    return _buildSurveySteps(controller);
  }
  
  // Survey steps after code validation
  Widget _buildSurveySteps(ActivateCourseController controller) {
    switch (controller.currentStep) {
      case 2:
        return _buildBasicInfoStep(controller);
      case 3:
        return _buildStudyTimeStep(controller);
      case 4:
        return _buildLearningStyleStep(controller);
      default:
        return const SizedBox();
    }
  }

  // Step 1: Code activation
  Widget _buildCodeActivationStep(ActivateCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction text
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Hướng dẫn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Nhập mã kích hoạt khóa học bạn nhận được từ email hoặc từ thẻ cào kích hoạt. Mã kích hoạt thường bao gồm chữ và số.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Mã kích hoạt mẫu: X23O1A0Y, 9DNMJ575 (O là chữ cái, không phải số 0)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),

        // Activation code field
        Text(
          'Mã kích hoạt',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _activationCodeController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: primaryColor,
          ),
          decoration: InputDecoration(
            hintText: 'Nhập mã kích hoạt',
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _activationCodeController.clear(),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập mã kích hoạt';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(12),
          ],
        ),
        
        const Spacer(),
      ],
    );
  }
  
  // Step 2: Basic info
  Widget _buildBasicInfoStep(ActivateCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        Text(
          'Email *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email của bạn',
            prefixIcon: const Icon(Icons.email),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập email';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 24),
        
        // Birthday field
        Text(
          'Ngày sinh *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _birthdayController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Tuổi của bạn',
            prefixIcon: const Icon(Icons.cake),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tuổi của bạn';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Gender field
        Text(
          'Giới tính',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
            ),
            value: '0',
            items: const [
              DropdownMenuItem(
                value: '0',
                child: Text('Nữ'),
              ),
              DropdownMenuItem(
                value: '1',
                child: Text('Nam'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.setGender(value);
              }
            },
          ),
        ),
        
        const Spacer(),
      ],
    );
  }
  
  // Step 3: Study time
  Widget _buildStudyTimeStep(ActivateCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Study hours per week
        Text(
          'Bạn dành bao nhiêu giờ học mỗi tuần? *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _studyHoursController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: const Icon(Icons.access_time),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số giờ học';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Social media hours per week
        Text(
          'Bạn dành bao nhiêu giờ cho mạng xã hội mỗi tuần? *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _socialMediaHoursController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: const Icon(Icons.phone_android),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số giờ dành cho mạng xã hội';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Sleep hours per night
        Text(
          'Bạn ngủ bao nhiêu giờ mỗi đêm? *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sleepHoursController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: const Icon(Icons.nightlight),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số giờ ngủ';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        
        const Spacer(),
      ],
    );
  }
  
  // Step 4: Learning style
  Widget _buildLearningStyleStep(ActivateCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Learning style preference
        Text(
          'Phong cách học ưa thích của bạn là gì?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
            ),
            value: 0,
            items: const [
              DropdownMenuItem(
                value: 0,
                child: Text('Học qua thực hành'),
              ),
              DropdownMenuItem(
                value: 1,
                child: Text('Đọc và viết'),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text('Nghe'),
              ),
              DropdownMenuItem(
                value: 3,
                child: Text('Nhìn'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.setPreferredLearningStyle(value);
              }
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Educational technology usage
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sử dụng công nghệ giáo dục',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bạn có thường xuyên sử dụng các ứng dụng học tập, công cụ trực tuyến không?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      bool isChecked = false;
                      return Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                          controller.setUseOfEducationalTech(isChecked);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Stress level
        Text(
          'Bạn có thường xuyên cảm thấy căng thẳng không?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
            ),
            value: 0,
            items: const [
              DropdownMenuItem(
                value: 0,
                child: Text('Rất thấp'),
              ),
              DropdownMenuItem(
                value: 1,
                child: Text('Thấp'),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text('Trung bình'),
              ),
              DropdownMenuItem(
                value: 3,
                child: Text('Cao'),
              ),
              DropdownMenuItem(
                value: 4,
                child: Text('Rất cao'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.setSelfReportedStressLevel(value);
              }
            },
          ),
        ),
        
        const Spacer(),
      ],
    );
  }
  
  // Build navigation buttons
  Widget _buildNavigationButtons(ActivateCourseController controller) {
    if (controller.currentStep == 1) {
      return SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isLoading ? null : _checkActivationCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: controller.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'TIẾP TỤC',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    } else {
      return Row(
        children: [
          // Back button
          Expanded(
            child: OutlinedButton(
              onPressed: controller.previousStep,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'QUAY LẠI',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Next/Finish button
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () {
                      if (controller.currentStep == 2) {
                        _moveToStudyTimeStep();
                      } else if (controller.currentStep == 3) {
                        _moveToLearningStyleStep();
                      } else if (controller.currentStep == 4) {
                        _finishActivation();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      controller.currentStep == 4 ? 'HOÀN TẤT' : 'TIẾP TỤC',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      );
    }
  }

  // Build title section with step progress
  Widget _buildTitleSection(ActivateCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.currentStep == 1 
              ? 'Kích hoạt khóa học'
              : 'Khảo sát thói quen học tập',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          controller.currentStep == 1
              ? 'Nhập mã code để kích hoạt khóa học của bạn'
              : 'Chúng tôi sẽ ghi nhận thói quen này để đưa ra lộ trình học tập phù hợp với bạn!',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        
        // Step indicator row
        Row(
          children: [
            _buildStepCircle(
              1, 
              'Mã kích hoạt', 
              controller.currentStep >= 1,
              controller.currentStep == 1
            ),
            _buildStepLine(controller.currentStep > 1),
            _buildStepCircle(
              2, 
              'Thông tin cơ bản',  
              controller.currentStep >= 2,
              controller.currentStep == 2
            ),
            _buildStepLine(controller.currentStep > 2),
            _buildStepCircle(
              3, 
              'Thời gian học tập', 
              controller.currentStep >= 3,
              controller.currentStep == 3
            ),
            _buildStepLine(controller.currentStep > 3),
            _buildStepCircle(
              4, 
              'Phong cách học', 
              controller.currentStep >= 4,
              controller.currentStep == 4
            ),
          ],
        ),
      ],
    );
  }
}
