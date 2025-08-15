import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/widget/markdown.dart';

import '../models/chat_message.dart';
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
      switch (widget.message.componentType) {
        case ChatComponentType.none:
          // Show markdown if available for agent messages, otherwise show plain text
          if (!isUser && widget.message.markdown != null) {
            try {
              child = SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarkdownWidget(
                      data: widget.message.markdown!,
                      shrinkWrap: true,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: widget.message.markdown!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Text copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.copy,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          tooltip: 'Copy text',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } catch (e) {
              // Fallback to plain text if markdown fails
              child = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    widget.message.text,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.message.text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Text copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        tooltip: 'Copy text',
                      ),
                    ],
                  ),
                ],
              );
            }
          } else {
            child = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  widget.message.text,
                  style: TextStyle(
                    color: isUser
                        ? Colors.green.shade800
                        : Colors.green.shade700,
                    fontSize: 16,
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.message.text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Text copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        tooltip: 'Copy text',
                      ),
                    ],
                  ),
                ],
              ],
            );
          }
          break;
        case ChatComponentType.chart:
          child = ChartComponent(
            data: widget.message.componentData ?? <String, dynamic>{},
          );
          break;
        case ChatComponentType.diagnosisCard:
          child = DiagnosisCard(
            data: widget.message.componentData ?? <String, dynamic>{},
          );
          break;
        case ChatComponentType.policyCard:
          child = PolicyCard(
            data: widget.message.componentData ?? <String, dynamic>{},
          );
          break;
        case ChatComponentType.communityPrompt:
          child = CommunityPrompt(
            data: widget.message.componentData ?? <String, dynamic>{},
          );
          break;
        case ChatComponentType.weatherCard:
          child = WeatherCard(data: widget.message.componentData ?? {});
          break;
        case ChatComponentType.cropReportCard:
          child = CropReportCard(data: widget.message.componentData ?? {});
          break;
        case ChatComponentType.timeSeriesChartCard:
          child = TimeSeriesChartCard(data: widget.message.componentData ?? {});
          break;
        case ChatComponentType.comparisonTableCard:
          child = ComparisonTableCard(data: widget.message.componentData ?? {});
          break;
        case ChatComponentType.soilAnalysisCard:
          child = SoilAnalysisCard(data: widget.message.componentData ?? {});
          break;
        case ChatComponentType.visualDiagnosisCard:
          child = VisualDiagnosisCard(data: widget.message.componentData ?? {});
          break;
        case ChatComponentType.stepByStepGuideCard:
          child = StepByStepGuideCard(data: widget.message.componentData ?? {});
          break;
        case ChatComponentType.interactiveChecklistCard:
          child = InteractiveChecklistCard(
            data: widget.message.componentData ?? {},
          );
          break;
        case ChatComponentType.contactAdvisorCard:
          child = ContactAdvisorCard(data: widget.message.componentData ?? {});
          break;
      }
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
