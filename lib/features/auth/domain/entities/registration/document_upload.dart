/// Document type enumeration
enum DocumentType {
  medicalCouncilCertificate('Medical Council Certificate', true),
  qualificationCertificate('Qualification Certificate', true),
  identityProof('Identity Proof (Aadhar/PAN/Passport)', true),
  profilePhoto('Profile Photo', true),
  additionalCertificates('Additional Certificates', false);

  const DocumentType(this.displayName, this.isRequired);

  final String displayName;
  final bool isRequired;
}

/// Document upload entity for Step 4
///
/// Represents a single uploaded document
class DocumentUpload {
  final DocumentType type;
  final String localFilePath;
  final String fileName;
  final int fileSizeBytes;
  final DateTime uploadedAt;
  final String? serverUrl; // After upload to server

  const DocumentUpload({
    required this.type,
    required this.localFilePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.uploadedAt,
    this.serverUrl,
  });

  /// Get file size in MB
  double get fileSizeMB => fileSizeBytes / (1024 * 1024);

  /// Check if uploaded to server
  bool get isUploaded => serverUrl != null;

  DocumentUpload copyWith({
    DocumentType? type,
    String? localFilePath,
    String? fileName,
    int? fileSizeBytes,
    DateTime? uploadedAt,
    String? serverUrl,
  }) {
    return DocumentUpload(
      type: type ?? this.type,
      localFilePath: localFilePath ?? this.localFilePath,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentUpload &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          localFilePath == other.localFilePath &&
          fileName == other.fileName &&
          fileSizeBytes == other.fileSizeBytes &&
          uploadedAt == other.uploadedAt &&
          serverUrl == other.serverUrl;

  @override
  int get hashCode =>
      type.hashCode ^
      localFilePath.hashCode ^
      fileName.hashCode ^
      fileSizeBytes.hashCode ^
      uploadedAt.hashCode ^
      (serverUrl?.hashCode ?? 0);

  @override
  String toString() {
    return 'DocumentUpload(type: ${type.displayName}, fileName: $fileName, size: ${fileSizeMB.toStringAsFixed(2)}MB, uploaded: $isUploaded)';
  }
}

/// Document uploads collection
class DocumentUploads {
  final List<DocumentUpload> documents;

  const DocumentUploads({this.documents = const []});

  /// Check if all required documents are uploaded
  bool get isComplete {
    final requiredTypes = DocumentType.values.where((type) => type.isRequired);
    for (final requiredType in requiredTypes) {
      if (!documents.any((doc) => doc.type == requiredType)) {
        return false;
      }
    }
    return true;
  }

  /// Get document by type
  DocumentUpload? getDocument(DocumentType type) {
    try {
      return documents.firstWhere((doc) => doc.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Add or update document
  DocumentUploads addOrUpdate(DocumentUpload document) {
    final updatedDocs = documents.where((doc) => doc.type != document.type).toList();
    updatedDocs.add(document);
    return DocumentUploads(documents: updatedDocs);
  }

  /// Remove document
  DocumentUploads remove(DocumentType type) {
    final updatedDocs = documents.where((doc) => doc.type != type).toList();
    return DocumentUploads(documents: updatedDocs);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentUploads &&
          runtimeType == other.runtimeType &&
          documents.length == other.documents.length;

  @override
  int get hashCode => documents.hashCode;

  @override
  String toString() {
    return 'DocumentUploads(count: ${documents.length}, complete: $isComplete)';
  }
}
