import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// Service chuyên xử lý video và cung cấp các tiện ích phát video
class VideoPlayerService {
  /// Kiểm tra URL video có phải URL Firebase Storage không
  static bool isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com') ||
        url.contains('alt=media');
  }

  /// Kiểm tra URL video có phải URL YouTube không
  static bool isYoutubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  /// Lấy ID video YouTube từ URL
  static String? getYoutubeId(String url) {
    if (!isYoutubeUrl(url)) return null;

    RegExp regExp = RegExp(
        r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
        caseSensitive: false);
    Match? match = regExp.firstMatch(url);
    return (match != null && match.groupCount >= 7) ? match.group(7) : null;
  }

  /// Lấy thumbnail YouTube dựa trên ID
  static String getYoutubeThumbnail(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }

  /// Xử lý URL video để đảm bảo có thể phát được
  static String processVideoUrl(String url) {
    if (url.isEmpty) return url;

    // Nếu là URL Firebase Storage, giữ nguyên
    if (isFirebaseStorageUrl(url)) {
      return url;
    }

    // Thử giải mã URL nếu chứa ký tự đặc biệt
    try {
      if (url.contains('%')) {
        return Uri.decodeFull(url);
      }
    } catch (e) {
      debugPrint('Lỗi khi decode URL video: $e');
    }

    return url;
  }

  /// Tạo controller cho video player
  static Future<ChewieController?> initializeChewieController({
    required String videoUrl,
    bool autoPlay = true,
    bool looping = false,
    bool allowFullScreen = true,
    bool allowMuting = true,
    bool showControls = true,
  }) async {
    try {
      // Xử lý URL video
      final processedUrl = processVideoUrl(videoUrl);

      // Khởi tạo VideoPlayerController
      final videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(processedUrl));

      // Thiết lập volume
      videoPlayerController.setVolume(1.0);

      // Thiết lập loop
      videoPlayerController.setLooping(looping);

      // Khởi tạo
      await videoPlayerController.initialize();

      // Tạo và trả về ChewieController
      return ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: videoPlayerController.value.aspectRatio,
        autoPlay: autoPlay,
        looping: looping,
        allowFullScreen: allowFullScreen,
        allowMuting: allowMuting,
        showControls: showControls,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'Không thể phát video',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Lỗi khi khởi tạo Chewie controller: $e');
      return null;
    }
  }

  /// Lấy định dạng video từ URL
  static String? getVideoFormat(String url) {
    if (url.isEmpty) return null;

    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    if (path.endsWith('.mp4')) return 'mp4';
    if (path.endsWith('.mov')) return 'mov';
    if (path.endsWith('.avi')) return 'avi';
    if (path.endsWith('.mkv')) return 'mkv';
    if (path.endsWith('.webm')) return 'webm';

    // Nếu không thể xác định từ phần mở rộng, kiểm tra các tham số
    if (uri.queryParameters.containsKey('format')) {
      return uri.queryParameters['format'];
    }

    // Mặc định cho Firebase Storage
    if (isFirebaseStorageUrl(url)) {
      return 'mp4';
    }

    return null;
  }

  /// Kiểm tra khả năng tương thích của URL video
  static bool canPlayUrl(String url) {
    // Kiểm tra các định dạng video được hỗ trợ
    final lowercaseUrl = url.toLowerCase();

    // Kiểm tra đuôi file hỗ trợ
    if (lowercaseUrl.endsWith('.mp4') ||
        lowercaseUrl.endsWith('.mov') ||
        lowercaseUrl.endsWith('.m4v') ||
        lowercaseUrl.endsWith('.3gp') ||
        lowercaseUrl.contains('youtube.com') ||
        lowercaseUrl.contains('youtu.be')) {
      return true;
    }

    // Kiểm tra Firebase Storage URL
    if (lowercaseUrl.contains('firebasestorage.googleapis.com') &&
        lowercaseUrl.contains('?alt=media')) {
      return true;
    }

    return false;
  }

  /// Kiểm tra và tạo VideoPlayerController
  static Future<VideoPlayerController?> createController(String url) async {
    try {
      final processedUrl = processVideoUrl(url);

      if (!canPlayUrl(processedUrl)) {
        // Không hỗ trợ định dạng video này
        print('⚠️ Không hỗ trợ định dạng URL video: $processedUrl');
        return null;
      }

      final controller =
          VideoPlayerController.networkUrl(Uri.parse(processedUrl));
      await controller.initialize();
      return controller;
    } catch (e) {
      print('❌ Lỗi khi tạo VideoPlayerController: $e');
      return null;
    }
  }

  /// Lấy thumbnail URL từ video URL
  static String getThumbnailUrl(String videoUrl) {
    // Nếu là YouTube, lấy thumbnail từ URL
    final lowercaseUrl = videoUrl.toLowerCase();

    if (lowercaseUrl.contains('youtube.com') ||
        lowercaseUrl.contains('youtu.be')) {
      // Trích xuất ID video
      String? videoId;

      if (lowercaseUrl.contains('youtube.com/watch?v=')) {
        final uri = Uri.parse(videoUrl);
        videoId = uri.queryParameters['v'];
      } else if (lowercaseUrl.contains('youtu.be/')) {
        videoId = Uri.parse(videoUrl).pathSegments.last;
      }

      if (videoId != null) {
        return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
      }
    }

    // Thumbnail mặc định
    return 'https://via.placeholder.com/640x360?text=Video';
  }
}
