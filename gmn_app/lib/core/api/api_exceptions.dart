class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized'})
    : super(message: message, statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = 'Not found'})
    : super(message: message, statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({String message = 'Server error'})
    : super(message: message, statusCode: 500);
}

class NetworkException extends ApiException {
  NetworkException({
    String message = 'Network error. Please check your connection.',
  }) : super(message: message);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({String message = 'Validation error', this.errors})
    : super(message: message, statusCode: 422);
}
