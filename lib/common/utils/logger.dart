import 'package:logger/logger.dart';

class AppLogger {
  static late Logger _logger;
  
  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }
  
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }
  
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }
  
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
  
  static void f(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // 添加完整方法名的别名，便于使用
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    d(message, error, stackTrace);
  }
  
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    i(message, error, stackTrace);
  }
  
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    w(message, error, stackTrace);
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    e(message, error, stackTrace);
  }
  
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    f(message, error, stackTrace);
  }
}
