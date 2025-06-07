import 'package:flutter/material.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/models/my_course/activate_model.dart';
import 'package:tms_app/data/repositories/my_course/activate_course_repository_impl.dart';
import 'package:tms_app/data/services/my_course/activate_course_service.dart';
import 'package:tms_app/domain/repositories/my_course/activate_course_repository.dart';
import 'package:tms_app/domain/usecases/my_course/activate_course_usecase.dart';
import 'package:dio/dio.dart';

class ActivateCourseController with ChangeNotifier {
  // Use cases
  final CheckCourseCodeUseCase checkCourseCodeUseCase;
  final ActivateCourseUseCase activateCourseUseCase;

  // State variables
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  
  // Step tracking
  int _currentStep = 1; // 1: Enter Code, 2: Basic Info, 3: Study Time, 4: Learning Style
  
  // Form data
  String _email = '';
  String _activationCode = '';
  int _accountId = 0;
  int _birthday = 0; // Age in years
  String _gender = '0'; // Default to female (0)
  int _studyHoursPerWeek = 0;
  int _timeSpentOnSocialMedia = 0;
  int _sleepHoursPerNight = 0;
  int _preferredLearningStyle = 0; // 0: Practice, 1: Read/Write, 2: Audio, 3: Visual
  bool _useOfEducationalTech = false;
  int _selfReportedStressLevel = 0; // 0-4 scale

  // Getters
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  int get currentStep => _currentStep;
  
  ActivateCourseController({
    required this.checkCourseCodeUseCase,
    required this.activateCourseUseCase,
  });
  
  // Initialize with user data
  Future<void> initialize() async {
    final userId = await SharedPrefs.getUserId();
    if (userId != null) {
      _accountId = userId;
    }
    
    // Ensure gender is a string
    _gender = "0";  // Default to female
    
    notifyListeners();
  }
  
  // Set activation code
  void setActivationCode(String code) {
    _activationCode = code.trim();
  }
  
  // Set email
  void setEmail(String email) {
    _email = email.trim();
  }
  
  // Set birthday (age)
  void setBirthday(int age) {
    _birthday = age;
  }
  
  // Set gender
  void setGender(String gender) {
    // Ensure it's a string
    _gender = gender == "1" ? "1" : "0";
  }
  
  // Set study hours per week
  void setStudyHoursPerWeek(int hours) {
    _studyHoursPerWeek = hours;
  }
  
  // Set time spent on social media
  void setTimeSpentOnSocialMedia(int hours) {
    _timeSpentOnSocialMedia = hours;
  }
  
  // Set sleep hours per night
  void setSleepHoursPerNight(int hours) {
    _sleepHoursPerNight = hours;
  }
  
  // Set preferred learning style
  void setPreferredLearningStyle(int style) {
    _preferredLearningStyle = style;
  }
  
  // Set use of educational technology
  void setUseOfEducationalTech(bool value) {
    _useOfEducationalTech = value;
  }
  
  // Set self-reported stress level
  void setSelfReportedStressLevel(int level) {
    _selfReportedStressLevel = level;
  }
  
  // Navigate to next step
  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }
  
  // Navigate to previous step
  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }
  
  // Check if course code is valid
  Future<bool> checkActivationCode() async {
    if (_activationCode.isEmpty) {
      _errorMessage = 'Vui lòng nhập mã kích hoạt';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final request = CheckCourseCodeRequest(
        code: _activationCode.trim().toUpperCase(), // Ensure code is properly formatted
        accountId: _accountId,
      );
      
      final response = await checkCourseCodeUseCase.execute(request);
      
      _isLoading = false;
      
      if (response.status == 200 && response.data.valid) {
        // Valid code, proceed to next step
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        // Invalid code
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      
      // Handle specific error messages
      String errorMsg = e.toString();
      
      // Extract the core error message without the Exception wrapper
      errorMsg = errorMsg.replaceAll('Exception: ', '');
      
      if (errorMsg.contains('đã đăng ký khóa học này rồi')) {
        _errorMessage = 'Bạn đã đăng ký khóa học này rồi';
      } else if (errorMsg.contains('đã được kích hoạt')) {
        _errorMessage = 'Mã khóa học đã được kích hoạt';
      } else if (errorMsg.contains('đã hết hạn')) {
        _errorMessage = 'Mã khóa học đã hết hạn';
      } else if (errorMsg.contains('không tồn tại')) {
        _errorMessage = 'Mã khóa học không tồn tại. Vui lòng kiểm tra lại mã.';
      } else if (errorMsg.contains('thu thập dữ liệu sinh viên')) {
        _errorMessage = 'Đã thu thập dữ liệu sinh viên cho mã này';
      } else if (errorMsg.contains('Lỗi xác thực')) {
        _errorMessage = 'Vui lòng đăng nhập lại để tiếp tục';
      } else {
        _errorMessage = errorMsg;
      }
      
      notifyListeners();
      return false;
    }
  }
  
  // Activate course
  Future<bool> activateCourse() async {
    try {
      // Update loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Print activation data for debugging
      final activationData = {
        'email': _email,
        'code': _activationCode,
        'accountId': _accountId,
        'birthday': _birthday,
        'studyHoursPerWeek': _studyHoursPerWeek,
        'timeSpentOnSocialMedia': _timeSpentOnSocialMedia,
        'sleepHoursPerNight': _sleepHoursPerNight,
        'gender': _gender,
        'preferredLearningStyle': _preferredLearningStyle,
        'useOfEducationalTech': _useOfEducationalTech,
        'selfReportedStressLevel': _selfReportedStressLevel,
      };
      print('Activating course with data: $activationData');

      // Create request model
      final request = ActivateCourseRequest(
        email: _email,
        code: _activationCode,
        accountId: _accountId,
        birthday: _birthday,
        studyHoursPerWeek: _studyHoursPerWeek,
        timeSpentOnSocialMedia: _timeSpentOnSocialMedia,
        sleepHoursPerNight: _sleepHoursPerNight,
        gender: _gender,
        preferredLearningStyle: _preferredLearningStyle,
        useOfEducationalTech: _useOfEducationalTech,
        selfReportedStressLevel: _selfReportedStressLevel,
      );

      // Call the use case to activate the course
      await activateCourseUseCase.execute(request);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      
      // Handle specific error cases with user-friendly messages
      if (e.toString().contains('Mã khóa học đã được kích hoạt')) {
        _errorMessage = 'Mã khóa học này đã được kích hoạt trước đó.';
      } else if (e.toString().contains('Mã khóa học đã hết hạn')) {
        _errorMessage = 'Mã khóa học đã hết hạn sử dụng.';
      } else if (e.toString().contains('Tài khoản đã đăng ký khóa học này')) {
        _errorMessage = 'Tài khoản của bạn đã đăng ký khóa học này.';
      } else if (e.toString().contains('Mã khóa học không tồn tại')) {
        _errorMessage = 'Mã khóa học không tồn tại trong hệ thống.';
      } else if (e.toString().contains('Không phải sinh viên HUIT')) {
        _errorMessage = 'Mã kích hoạt này chỉ dành cho sinh viên HUIT.';
      } else if (e.toString().contains('Tài khoản không tồn tại')) {
        _errorMessage = 'Tài khoản không tồn tại trong hệ thống.';
      } else if (e.toString().contains('Kết nối tới server bị gián đoạn')) {
        _errorMessage = 'Kết nối tới máy chủ bị gián đoạn, vui lòng thử lại.';
      } else if (e.toString().contains('Không thể kết nối tới máy chủ')) {
        _errorMessage = 'Không thể kết nối tới máy chủ, vui lòng kiểm tra kết nối mạng.';
      } else {
        _errorMessage = 'Có lỗi xảy ra khi kích hoạt khóa học. Vui lòng thử lại sau.';
      }
      
      notifyListeners();
      return false;
    }
  }
  
  // Reset the controller state
  void reset() {
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = null;
    _currentStep = 1;
    _activationCode = '';
    // Keep account ID and email as they are user specific
    _birthday = 0;
    _gender = '0';
    _studyHoursPerWeek = 0;
    _timeSpentOnSocialMedia = 0;
    _sleepHoursPerNight = 0;
    _preferredLearningStyle = 0;
    _useOfEducationalTech = false;
    _selfReportedStressLevel = 0;
    notifyListeners();
  }
} 