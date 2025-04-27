// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:tms_app/presentation/screens/login/login.dart';
// import 'package:tms_app/presentation/screens/homePage/home.dart';
// import 'package:tms_app/domain/repositories/account_repository.dart';
// import 'package:mockito/mockito.dart';
// import 'package:tms_app/data/services/auth_service.dart';
// import 'package:tms_app/data/services/user_service.dart';
// import 'package:tms_app/data/dto/user_dto.dart';

// // Tạo lớp Mock cho AccountRepository
// class MockAccountRepository extends Mock implements AccountRepository {
//   @override
//   Future<Map<String, dynamic>?> login(Map<String, dynamic> body) {
//     return super.noSuchMethod(
//       Invocation.method(#login, [body]),
//       returnValue: Future.value({
//         'jwt': 'mock_jwt_token',
//         'userInfo': {'email': 'test@test.com'}
//       }),
//     );
//   }

//   @override
//   Future<Map<String, dynamic>?> register(Map<String, dynamic> body) {
//     return super.noSuchMethod(
//       Invocation.method(#register, [body]),
//       returnValue: Future.value({
//         'jwt': 'mock_jwt_token',
//         'userInfo': {'email': 'test@test.com'}
//       }),
//     );
//   }

//   @override
//   Future<Map<String, String?>> getUserData() {
//     return super.noSuchMethod(
//       Invocation.method(#getUserData, []),
//       returnValue:
//           Future.value({'email': 'test@test.com', 'phone': '123456789'}),
//     );
//   }

//   @override
//   Future<bool> sendOtpToEmail(Map<String, dynamic> body) {
//     return super.noSuchMethod(
//       Invocation.method(#sendOtpToEmail, [body]),
//       returnValue: Future.value(true),
//     );
//   }

//   @override
//   Future<List<UserDto>> getUsers() {
//     return super.noSuchMethod(
//       Invocation.method(#getUsers, []),
//       returnValue: Future.value([
//         UserDto(id: 1, name: 'John Doe', email: 'john.doe@test.com'),
//       ]),
//     );
//   }
// }

// void main() {
//   late MockAccountRepository mockAccountRepository;

//   // Set up the mock repository before each test
//   setUp(() {
//     mockAccountRepository = MockAccountRepository();
//   });

//   testWidgets('Test login screen UI and login functionality',
//       (WidgetTester tester) async {
//     // Arrange: Mock the login response
//     when(mockAccountRepository.login(any)).thenAnswer((_) async => {
//           'jwt': 'mock_jwt_token',
//           'userInfo': {'email': 'test@test.com'}
//         });

//     // Act: Build our app and trigger a frame.
//     await tester.pumpWidget(
//       MaterialApp(
//         home: LoginScreen(accountRepository: mockAccountRepository),
//       ),
//     );

//     // Verify that the login screen is displayed
//     expect(find.byType(LoginScreen), findsOneWidget);
//     expect(find.text('Đăng nhập'), findsOneWidget);

//     // Act: Enter credentials and perform login.
//     await tester.enterText(find.byKey(Key('emailField')), 'test@test.com');
//     await tester.enterText(find.byKey(Key('passwordField')), 'password123');

//     // Tap the login button
//     await tester.tap(find.byKey(Key('loginButton')));
//     await tester.pumpAndSettle();

//     // Verify: Check that we are now showing the home screen (after login).
//     expect(find.byType(HomeScreen), findsOneWidget);

//     // Verify that login was attempted with the correct credentials
//     verify(mockAccountRepository.login({
//       'email': 'test@test.com',
//       'password': 'password123',
//     })).called(1);
//   });
// }
