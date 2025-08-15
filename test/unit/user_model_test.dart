import 'package:flutter_test/flutter_test.dart';
import 'package:rico_user_app/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    late User testUser;
    
    setUp(() {
      testUser = User(
        id: '1',
        email: 'test@example.com',
        username: 'testuser',
        firstName: 'Test',
        lastName: 'User',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    });

    test('should create user with required fields', () {
      expect(testUser.id, '1');
      expect(testUser.email, 'test@example.com');
      expect(testUser.username, 'testuser');
      expect(testUser.isActive, true);
    });

    test('should return correct full name', () {
      expect(testUser.fullName, 'Test User');
      
      final userWithoutLastName = testUser.copyWith(lastName: null);
      expect(userWithoutLastName.fullName, 'Test');
      
      final userWithoutNames = testUser.copyWith(firstName: null, lastName: null);
      expect(userWithoutNames.fullName, 'testuser');
    });

    test('should convert to and from JSON correctly', () {
      final json = testUser.toJson();
      final userFromJson = User.fromJson(json);
      
      expect(userFromJson, testUser);
    });

    test('should copy with new values', () {
      final updatedUser = testUser.copyWith(
        email: 'new@example.com',
        firstName: 'New',
      );
      
      expect(updatedUser.email, 'new@example.com');
      expect(updatedUser.firstName, 'New');
      expect(updatedUser.lastName, 'User'); // unchanged
    });
  });
}
