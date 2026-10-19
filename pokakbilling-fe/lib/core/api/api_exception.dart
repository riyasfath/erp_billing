class ApiException implements Exception {
  final String message;
  final String prefix;

  ApiException([this.message = "", this.prefix = ""]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends ApiException {
  FetchDataException(String message)
      : super(message, "Error During Communication: ");
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message, "Invalid Request: ");
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, "Unauthorized: ");
}

// ── NEW: thrown when the server returns "Session expired" ─────────────────
// ApiHelper catches any 401 whose body contains "Session expired" and throws
// this instead of plain UnauthorizedException, so callers / the global
// handler can distinguish a token-expiry from a bad-credentials error.
class SessionExpiredException extends ApiException {
  SessionExpiredException(
      [String message = "Session expired. Please log in again."])
      : super(message, "");
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, "Forbidden: ");
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, "Not Found: ");
}

class InternalServerException extends ApiException {
  InternalServerException(String message) : super(message, "Internal Server: ");
}

class UnprocessableContentException extends ApiException {
  UnprocessableContentException(String message)
      : super(message, "Unprocessable Content: ");
}

class InvalidInputException extends ApiException {
  InvalidInputException(String message) : super(message, "Invalid Input: ");
}
