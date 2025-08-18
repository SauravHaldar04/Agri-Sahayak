import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfPreviewCard extends StatelessWidget {
  const PdfPreviewCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? 'PDF Document';
    final description = data['description']?.toString();
    final pdfUrl = data['pdfUrl']?.toString();
    final pdfAsset = data['pdfAsset']?.toString(); // New field for local assets
    final voiceOverview = data['voiceOverview']?.toString();
    final fileSize = data['fileSize']?.toString();
    final pages = data['pages']?.toString();
    final category = data['category']?.toString();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () async {
          if (pdfAsset != null) {
            // Handle local asset PDF
            await _openLocalPdf(context, title, pdfAsset, voiceOverview);
          } else if (pdfUrl != null) {
            // Handle remote URL PDF
            final Uri url = Uri.parse(pdfUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open PDF'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No PDF source available'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      pdfAsset != null ? Icons.folder : Icons.picture_as_pdf,
                      color: Colors.red.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (pdfAsset != null)
                        Icon(
                          Icons.storage,
                          color: Colors.green.shade600,
                          size: 16,
                        )
                      else
                        Icon(
                          Icons.open_in_new,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        pdfAsset != null ? 'Local' : 'External',
                        style: TextStyle(
                          color: pdfAsset != null
                              ? Colors.green.shade600
                              : Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (voiceOverview != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        color: Colors.blue.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Voice Overview Available',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (fileSize != null) ...[
                    Icon(Icons.storage, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      fileSize,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (pages != null) ...[
                    Icon(Icons.pages, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '$pages pages',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLocalPdf(
    BuildContext context,
    String title,
    String assetPath,
    String? voiceOverview,
  ) async {
    try {
      // Always use the correct asset path for the PDF in your project
      String actualAssetPath = 'assets/pdf/agriculture.pdf';
      
      print('Loading PDF from asset: $actualAssetPath');
      
      // Check if the asset exists, if not show error
      try {
        final ByteData data = await rootBundle.load(actualAssetPath);
        print('PDF asset loaded successfully, size: ${data.lengthInBytes} bytes');
        
        final bytes = data.buffer.asUint8List();
        
        final tempDir = await getTemporaryDirectory();
        final fileName = 'agriculture.pdf';
        final tempFile = File('${tempDir.path}/$fileName');
        
        await tempFile.writeAsBytes(bytes);
        print('PDF written to temp file: ${tempFile.path}');
        
        // Verify temp file exists
        if (await tempFile.exists()) {
          final fileSize = await tempFile.length();
          print('Temp file exists with size: $fileSize bytes');
          
          // Navigate to PDF viewer screen
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(
                  title: title,
                  pdfPath: tempFile.path,
                  voiceOverview: voiceOverview,
                  isLocal: true,
                ),
              ),
            );
          }
        } else {
          throw Exception('Failed to create temporary PDF file');
        }
      } catch (assetError) {
        print('Failed to load PDF asset: $assetError');
        throw Exception('PDF file not found in assets. Please ensure agriculture.pdf exists in assets/pdf/ folder.');
      }
    } catch (e) {
      print('Error opening local PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PDF not available'),
                Text('Error: ${e.toString()}', style: TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    }
  }
}

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.title,
    this.pdfUrl,
    this.pdfPath,
    this.voiceOverview,
    this.isLocal = false,
  });

  final String title;
  final String? pdfUrl;
  final String? pdfPath;
  final String? voiceOverview;
  final bool isLocal;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  bool isVoiceAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        isPlaying = false;
      });
    });

    setState(() {
      isVoiceAvailable = widget.voiceOverview != null;
    });
  }

  Future<void> _playVoiceOverview() async {
    if (widget.voiceOverview == null) return;

    if (isPlaying) {
      await flutterTts.stop();
    } else {
      await flutterTts.speak(widget.voiceOverview!);
    }
  }

  Future<void> _openPdf() async {
    if (widget.isLocal && widget.pdfPath != null) {
      // For local PDFs, try to open with system PDF viewer
      final file = File(widget.pdfPath!);
      if (await file.exists()) {
        try {
          final uri = Uri.file(widget.pdfPath!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            _showPdfUnavailableMessage();
          }
        } catch (e) {
          print('Error opening local PDF: $e');
          _showPdfUnavailableMessage();
        }
      } else {
        _showPdfUnavailableMessage();
      }
    } else if (widget.pdfUrl != null) {
      // For remote PDFs, open URL
      final Uri url = Uri.parse(widget.pdfUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showPdfUnavailableMessage();
      }
    } else {
      _showPdfUnavailableMessage();
    }
  }

  void _showPdfUnavailableMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open PDF. Please install a PDF reader app.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isVoiceAvailable)
            IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              onPressed: _playVoiceOverview,
              tooltip: isPlaying
                  ? 'Stop Voice Overview'
                  : 'Play Voice Overview',
            ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openPdf,
            tooltip: widget.isLocal
                ? 'Open with PDF Reader'
                : 'Open PDF in Browser',
          ),
        ],
      ),
      body: Column(
        children: [
          if (isVoiceAvailable && widget.voiceOverview != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Voice Overview',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (isPlaying)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.voiceOverview!,
                    style: TextStyle(color: Colors.blue.shade800, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isLocal ? Icons.folder_open : Icons.picture_as_pdf,
                    size: 100,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.isLocal ? 'Local PDF Document' : 'PDF Document',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isLocal
                        ? 'Click the button above to open this PDF with your default PDF reader'
                        : 'Click the button above to open this PDF in your browser',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _openPdf,
                    icon: Icon(
                      widget.isLocal ? Icons.launch : Icons.open_in_new,
                    ),
                    label: Text(
                      widget.isLocal
                          ? 'Open with PDF Reader'
                          : 'Open PDF in Browser',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
