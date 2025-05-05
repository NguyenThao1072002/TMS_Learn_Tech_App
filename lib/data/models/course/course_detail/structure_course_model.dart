class StructureCourseModel {
  final int chapterId;
  final String chapterTitle;
  final int lessonCount;
  final List<VideoDTOUserView> videoDTOUserViewList;

  StructureCourseModel({
    required this.chapterId,
    required this.chapterTitle,
    required this.lessonCount,
    required this.videoDTOUserViewList,
  });

  factory StructureCourseModel.fromJson(Map<String, dynamic> json) {
    return StructureCourseModel(
      chapterId: json['chapterId'] ?? 0,
      chapterTitle: json['chapterTitle'] ?? '',
      lessonCount: json['lessonCount'] ?? 0,
      videoDTOUserViewList: (json['videoDTOUserViewList'] as List?)
              ?.map((e) => VideoDTOUserView.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'lessonCount': lessonCount,
      'videoDTOUserViewList':
          videoDTOUserViewList.map((e) => e.toJson()).toList(),
    };
  }
}

class VideoDTOUserView {
  final int videoId;
  final String videoTitle;
  final int videoDuration;
  final bool viewTest;

  VideoDTOUserView({
    required this.videoId,
    required this.videoTitle,
    required this.videoDuration,
    required this.viewTest,
  });

  factory VideoDTOUserView.fromJson(Map<String, dynamic> json) {
    return VideoDTOUserView(
      videoId: json['videoId'] ?? 0,
      videoTitle: json['videoTitle'] ?? '',
      videoDuration: json['videoDuration'] ?? 0,
      viewTest: json['viewTest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'videoTitle': videoTitle,
      'videoDuration': videoDuration,
      'viewTest': viewTest,
    };
  }
}
