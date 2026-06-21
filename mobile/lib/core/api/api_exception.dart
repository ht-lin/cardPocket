sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

final class NetworkException extends ApiException {
  const NetworkException([super.message = 'Network error']);
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}

final class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Forbidden']);
}

final class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Not found']);
}

final class UnprocessableException extends ApiException {
  const UnprocessableException(this.errors, [super.message = 'Validation failed']);
  final Map<String, List<String>> errors;
}

final class ServerException extends ApiException {
  const ServerException([super.message = 'Server error']);
}
