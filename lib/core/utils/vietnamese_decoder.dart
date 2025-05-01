import 'dart:convert';

class VietnameseDecoder {
  // Hàm sửa lỗi encoding tiếng Việt
  static String fixEncoding(String text) {
    // Bảng tra các từ thường gặp
    Map<String, String> replacements = {
      // Các từ cụ thể
      "CÃ´ng nghá»": "Công nghệ",
      "MÃ¡ng": "Mạng",
      "Báº£o": "Bảo",
      "má»›i": "mới",
      ".NET": ".NET",
      "thÃ´ng": "thông",
      "táº§": "tầ",
      "táº§n": "tần",
      "Há»": "Hệ",
      "mÃ¡y": "máy",
      "tÃ­nh": "tính",
      "lÆ°á»£ng": "lượng",

      // Các chữ cái riêng lẻ
      "Ã´": "ô",
      "Äƒ": "ă",
      "á»‹": "ị",
      "á»'": "ố",
      "há»": "hệ",
      "á»©ng": "ứng",
      "Ãª": "ê",
      "Ã¨": "è",
      "Ã¡": "á",
      "Ã­": "í",
      "Ãº": "ú",
      "Ã¢": "â",
      "áº£": "ả",
      "áº§": "ầ",
      "áº¡": "ạ",
      "áº·": "ặ",
      "á»¯": "ữ",
      "á»¥": "ụ",
      "á»³": "ỳ",
      "á»©": "ứ",
      "Æ°": "ư",
      "Æ¡": "ơ",
      "Æ": "Đ",

      // Thêm các từ khóa học từ log
      "Khóa há»c": "Khóa học",
      "há»c": "học",
      "Tiáº¿ng Viá»‡t": "Tiếng Việt",
      "viá»‡t": "việt",
      "cÆ¡ báº£n": "cơ bản",
      "nÃ¢ng cao": "nâng cao",
      "phÃ¡t triá»ƒn": "phát triển",
      "thiáº¿t káº¿": "thiết kế",
      "Æ°á»©ng dá»¥ng": "ứng dụng",
    };

    String result = text;
    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    return result;
  }

  // Hàm đệ quy để sửa lỗi encoding cho tất cả các trường trong JSON
  static dynamic fixEncodingInJson(dynamic json) {
    if (json is Map) {
      Map result = {};
      json.forEach((key, value) {
        if (value is String) {
          result[key] = fixEncoding(value);
        } else if (value is Map || value is List) {
          result[key] = fixEncodingInJson(value);
        } else {
          result[key] = value;
        }
      });
      return result;
    } else if (json is List) {
      return json.map((item) => fixEncodingInJson(item)).toList();
    }
    return json;
  }
}
