import 'dart:io';

import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;


class LearningPage extends StatefulWidget {
  final Function() onComplete;

  const LearningPage({super.key, required this.onComplete});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _showVideoError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/video.mp4')
        ..addListener(() {
          if (_videoController.value.hasError) {
            setState(() {
              _showVideoError = true;
            });
          }
        });

      await _videoController.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      setState(() {
        _showVideoError = true;
      });
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _toggleVideoPlay() {
    if (_showVideoError) return;

    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }

  Future<void> _openPptFile() async {
    try {
      // Load the PPT file from assets
      final byteData = await rootBundle.load('assets/TFile.ppt');

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, 'TFile.ppt');

      // Write the file to the documents directory
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Open the file
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        _showErrorDialog('Файл кушода нашуд. Лутфан PowerPoint доред ё файли диро кӯшиш кунед.');
      }
    } on PlatformException catch (e) {
      _showErrorDialog('Хатоги системавӣ: ${e.message}');
      debugPrint('Platform error: ${e.toString()}');
    } catch (e) {
      _showErrorDialog('Хатоги номаълум дар кушодани файл');
      debugPrint('Error opening file: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Хатоги'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Омӯзиши модул 1',
          style: TextStyle(
            fontSize: 20,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              // Video Player
              AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: CupertinoColors.systemGrey5,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_showVideoError)
                        _buildVideoErrorWidget()
                      else if (_isVideoInitialized)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: VideoPlayer(_videoController),
                        )
                      else
                        const CupertinoActivityIndicator(),

                      if (!_showVideoError)
                        GestureDetector(
                          onTap: _toggleVideoPlay,
                          child: Container(
                            color: Colors.transparent,
                            child: Center(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: _isPlaying ? 0.0 : 1.0,
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // PPT File Button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _openPptFile,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: CupertinoColors.systemGrey5,
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.doc,
                          size: 40,
                          color: CupertinoColors.systemGrey),
                      const SizedBox(width: 16),
                      const Expanded(
                          child: Text('TFile.ppt',
                              style: TextStyle(fontSize: 16))),
                      Icon(CupertinoIcons.chevron_right,
                          size: 20,
                          color: CupertinoColors.systemGrey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Learning Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Маводҳои омӯзишӣ',
                        style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context)
                              .textTheme.textStyle.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Дар ин модул шумо бо қоидаҳои асосии ҳаракат дар роҳ, аломатҳои роҳи нақлиёт ва қонунҳои аҳамиятнок ошно мешавед.',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.none,
                          color: CupertinoTheme.of(context)
                              .textTheme.textStyle.color,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Қоидаҳои асосӣ:',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context)
                              .textTheme.textStyle.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint(
                          'Ҳамаи ронандагон бояд қоидаҳои роҳи нақлиётро риоя кунанд'),
                      _buildBulletPoint(
                          'Суръати ҳаракат бояд ба шароити роҳ мувофиқ бошад'),
                      _buildBulletPoint(
                          'Истифодаи телефон ҳангоми ронандагӣ манъ аст'),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Start Test Button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onComplete,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Оғоз кардани санҷиш',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              decoration: TextDecoration.none,
              color: CupertinoTheme.of(context).textTheme.textStyle.color,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                decoration: TextDecoration.none,
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline,
            size: 50,
            color: CupertinoColors.systemRed),
        const SizedBox(height: 8),
        const Text(
          'Видео боргузонии нашуд',
          style: TextStyle(color: CupertinoColors.systemRed),
        ),
        const SizedBox(height: 16),
        CupertinoButton(
          child: const Text('Аз нав кӯшиш кунед'),
          onPressed: () {
            setState(() {
              _showVideoError = false;
              _isVideoInitialized = false;
            });
            _initializeVideo();
          },
        ),
      ],
    );
  }
}