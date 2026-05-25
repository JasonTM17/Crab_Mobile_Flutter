import 'package:dio/dio.dart';

/// Maps any thrown error/exception (especially [DioException]) to a
/// human-friendly Vietnamese message suitable for snack bars and dialogs.
///
/// Falls back to a generic message for unknown error types so we never
/// leak raw stack traces or English-only library text into the UI.
String mapErrorToMessage(Object? error) {
  if (error == null) {
    return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  }

  if (error is DioException) {
    return _mapDioException(error);
  }

  return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
}

String _mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Kết nối quá chậm. Vui lòng kiểm tra mạng và thử lại.';
    case DioExceptionType.connectionError:
      return 'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.';
    case DioExceptionType.cancel:
      return 'Yêu cầu đã bị huỷ.';
    case DioExceptionType.badCertificate:
      return 'Chứng chỉ bảo mật của máy chủ không hợp lệ.';
    case DioExceptionType.badResponse:
      return _mapStatus(e);
    case DioExceptionType.unknown:
      return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  }
}

String _mapStatus(DioException e) {
  final status = e.response?.statusCode;
  final serverMessage = _extractServerMessage(e.response?.data);

  switch (status) {
    case 400:
      return serverMessage ?? 'Yêu cầu không hợp lệ.';
    case 401:
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    case 403:
      return 'Bạn không có quyền thực hiện thao tác này.';
    case 404:
      return serverMessage ?? 'Không tìm thấy dữ liệu.';
    case 409:
      return serverMessage ?? 'Dữ liệu đã tồn tại hoặc đang xung đột.';
    case 422:
      return serverMessage ?? 'Dữ liệu nhập không hợp lệ.';
    case 429:
      return 'Bạn thao tác quá nhanh. Vui lòng thử lại sau ít phút.';
    case 500:
    case 502:
    case 503:
    case 504:
      return 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.';
  }
  return serverMessage ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.';
}

String? _extractServerMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
  }
  return null;
}
