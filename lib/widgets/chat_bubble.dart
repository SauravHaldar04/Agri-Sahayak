import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'dart:io';

import '../models/chat_message.dart';
import 'audio_player_widget.dart';
import 'components/chart_component.dart';
import 'components/diagnosis_card.dart';
import 'components/policy_card.dart';
import 'components/community_prompt.dart';
import 'components/weather_card.dart';
import 'components/soil_analysis_card.dart';
import 'components/crop_report_card.dart';
import 'components/visual_diagnosis_card.dart';
import 'components/contact_advisor_card.dart';
import 'components/time_series_chart_card.dart';
import 'components/comparison_table_card.dart';
import 'components/step_by_step_guide_card.dart';
import 'components/interactive_checklist_card.dart';
import 'components/pdf_preview_card.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late AnimationController _contentController;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bubbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.elasticOut),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _bubbleController.forward();
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Build media attachment widget
  Widget _buildMediaAttachment() {
    if (widget.message.mediaAttachment == null) return const SizedBox.shrink();

    final media = widget.message.mediaAttachment!;

    switch (media.type) {
      case MediaType.image:
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(media.filePath),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade600,
                    size: 48,
                  ),
                );
              },
            ),
          ),
        );

      case MediaType.voice:
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: AudioPlayerWidget(
            audioPath: media.filePath,
            width: 250,
            height: 80,
          ),
        );

      case MediaType.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildComponent() {
    switch (widget.message.componentType) {
      case ChatComponentType.chart:
        return ChartComponent(
          data: widget.message.componentData ?? <String, dynamic>{},
        );
      case ChatComponentType.diagnosisCard:
        return DiagnosisCard(
          data: widget.message.componentData ?? <String, dynamic>{},
        );
      case ChatComponentType.policyCard:
        return PolicyCard(
          data: widget.message.componentData ?? <String, dynamic>{},
        );
      case ChatComponentType.communityPrompt:
        return CommunityPrompt(
          data: widget.message.componentData ?? <String, dynamic>{},
        );
      case ChatComponentType.weatherCard:
        return WeatherCard(data: widget.message.componentData ?? {});
      case ChatComponentType.cropReportCard:
        return CropReportCard(data: widget.message.componentData ?? {});
      case ChatComponentType.timeSeriesChartCard:
        return TimeSeriesChartCard(data: widget.message.componentData ?? {});
      case ChatComponentType.comparisonTableCard:
        return ComparisonTableCard(data: widget.message.componentData ?? {});
      case ChatComponentType.soilAnalysisCard:
        return SoilAnalysisCard(data: widget.message.componentData ?? {});
      case ChatComponentType.visualDiagnosisCard:
        return VisualDiagnosisCard(data: widget.message.componentData ?? {});
      case ChatComponentType.stepByStepGuideCard:
        return StepByStepGuideCard(data: widget.message.componentData ?? {});
      case ChatComponentType.interactiveChecklistCard:
        return InteractiveChecklistCard(
          data: widget.message.componentData ?? {},
        );
      case ChatComponentType.contactAdvisorCard:
        return ContactAdvisorCard(data: widget.message.componentData ?? {});
      case ChatComponentType.pdfPreviewCard:
        return PdfPreviewCard(data: widget.message.componentData ?? {});
      case ChatComponentType.none:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMessageContent() {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main message text
        if (widget.message.markdown != null)
          MarkdownWidget(
            data: widget.message.markdown!,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          )
        else
          Text(
            widget.message.text,
            style: TextStyle(
              fontSize: 16,
              color: widget.message.sender == ChatSender.user
                  ? Colors.white
                  : Colors.black87,
            ),
          ),

        // Location information
        if (widget.message.locationData != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        '${widget.message.locationData!['latitude']?.toStringAsFixed(6)}, ${widget.message.locationData!['longitude']?.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      if (widget.message.locationData!['address'] != null)
                        Text(
                          widget.message.locationData!['address'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Media attachment
        if (widget.message.mediaAttachment != null &&
            widget.message.mediaAttachment!.type != MediaType.none)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildMediaAttachment(),
          ),
      ],
    );

    // Add component if present
    if (widget.message.componentType != ChatComponentType.none) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [content, const SizedBox(height: 12), _buildComponent()],
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final bool isUser = widget.message.sender == ChatSender.user;
    final Color bubbleColor = isUser ? Colors.green.shade100 : Colors.white;
    final Color borderColor = isUser
        ? Colors.green.shade300
        : Colors.green.shade200;

    Widget child;
    if (widget.message.isTyping) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Typing...',
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    } else {
      child = _buildMessageContent();
    }

    return AnimatedBuilder(
      animation: _bubbleAnimation,
      builder: (context, _) {
        return Transform.scale(
          scale: _bubbleAnimation.value,
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: GestureDetector(
              onLongPress: () {
                // Show copy options on long press
                if (!isUser) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.copy,
                              color: Colors.green.shade600,
                            ),
                            title: const Text('Copy Text'),
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: widget.message.text),
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Text copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          if (widget.message.markdown != null)
                            ListTile(
                              leading: Icon(
                                Icons.copy,
                                color: Colors.green.shade600,
                              ),
                              title: const Text('Copy Markdown'),
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: widget.message.markdown!),
                                );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Markdown copied to clipboard',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 8),
                    bottomRight: Radius.circular(isUser ? 8 : 20),
                  ),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _contentAnimation,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: _contentAnimation.value,
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
