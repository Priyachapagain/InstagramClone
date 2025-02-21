import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoControllerService{
  static Future<ChewieController>
  initializeChewieController(String videoUrl) async {
    File? videoFile;
    var fileInfo = await DefaultCacheManager().getFileFromCache(videoUrl);

    if(fileInfo != null){
      videoFile = fileInfo.file;

    } else {
      videoFile = await DefaultCacheManager().getSingleFile(videoUrl);
    }

    var videoPlayerController =
        VideoPlayerController.file(videoFile!);
    await videoPlayerController.initialize();

    return ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true
    );


  }
}