class General_document_acount {
  final int? id;
  final DateTime? date_download;
  final int? account_id;
  final int? generaldocument_id;

  General_document_acount({
    this.id,
    this.date_download,
    this.account_id,
    this.generaldocument_id,
  });

  factory General_document_acount.fromJson(Map<String, dynamic> json) {
    return General_document_acount(
      id: json['id'],
      date_download: json['date_download'],
      account_id: json['account_id'],
      generaldocument_id: json['generaldocument_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_download': date_download,
      'account_id': account_id,
      'generaldocument_id': generaldocument_id,
    };
  }
}
