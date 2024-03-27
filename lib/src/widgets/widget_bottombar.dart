import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';
import 'package:lecle_yoyo_player/src/utils/utils.dart';
import 'package:video_player/video_player.dart';

/// Widget use to display the bottom bar buttons and the time texts
class PlayerBottomBar extends StatefulWidget {
  /// Constructor
  const PlayerBottomBar({
    Key? key,
    required this.controller,
    required this.showBottomBar,
    this.onPlayButtonTap,
    this.rePlayVideo,
    this.onPlaySpeedTap,
    this.onPlayVolumeTap,
    this.videoDuration = "00:00:00",
    this.videoSeek = "00:00:00",
    this.videoStyle = const VideoStyle(),
    this.onFastForward,
    this.onRewind,
  }) : super(key: key);

  /// The controller of the playing video.
  final VideoPlayerController controller;

  /// If set to [true] the bottom bar will appear and if you want that user can not interact with the bottom bar you can set it to [false].
  /// Default value is [true].
  final bool showBottomBar;

  /// The text to display the current position progress.
  final String videoSeek;

  /// The text to display the video's duration.
  final String videoDuration;

  /// The callback function execute when user tapped the play button.
  final void Function()? onPlayButtonTap;

  final void Function()? rePlayVideo;

  final void Function()? onPlaySpeedTap;

  final void Function()? onPlayVolumeTap;

  /// The model to provide custom style for the video display widget.
  final VideoStyle videoStyle;

  /// The callback function execute when user tapped the rewind button.
  final ValueChanged<VideoPlayerValue>? onRewind;

  /// The callback function execute when user tapped the forward button.
  final ValueChanged<VideoPlayerValue>? onFastForward;

  @override
  State<PlayerBottomBar> createState() => _PlayerBottomBarState();
}

class _PlayerBottomBarState extends State<PlayerBottomBar> {
  void toggleVolumeOverlay() {
    setState(() {
      _isVolumeOverlayVisible = !_isVolumeOverlayVisible;
    });
  }

  bool _isVolumeOverlayVisible = false;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.showBottomBar,
      child: Padding(
        padding: widget.videoStyle.bottomBarPadding,
        child: SizedBox(
          height: 300,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: VideoProgressIndicator(
                      widget.controller,
                      allowScrubbing: widget.videoStyle.allowScrubbing ?? true,
                      colors: widget.videoStyle.progressIndicatorColors ??
                          const VideoProgressColors(
                            playedColor: Color.fromARGB(250, 0, 255, 112),
                          ),
                      padding: widget.videoStyle.progressIndicatorPadding ?? EdgeInsets.zero,
                    ),
                  ),
                  Padding(
                    padding: widget.videoStyle.videoDurationsPadding ?? const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                PersianText(widget.videoSeek).convert(),
                                style: widget.videoStyle.videoSeekStyle ??
                                    const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              child: InkWell(
                                onTap: widget.videoStyle.onHelperSpeed ?? widget.onPlaySpeedTap,
                                child: widget.videoStyle.speedIcon ??
                                    Icon(
                                      Icons.fast_rewind_rounded,
                                      color: widget.videoStyle.forwardIconColor,
                                      size: widget.videoStyle.forwardAndBackwardBtSize,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Transform.translate(
                          offset: const Offset(0.0, -4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  widget.controller.rewind().then((value) {
                                    widget.onRewind?.call(widget.controller.value);
                                  });
                                },
                                child: widget.videoStyle.backwardIcon ??
                                    Icon(
                                      Icons.fast_rewind_rounded,
                                      color: widget.videoStyle.forwardIconColor,
                                      size: widget.videoStyle.forwardAndBackwardBtSize,
                                    ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: widget.videoStyle.spaceBetweenBottomBarButtons, left: widget.videoStyle.spaceBetweenBottomBarButtons, bottom: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    bool videoEnded = widget.controller.value.position >= widget.controller.value.duration;
                                    if (videoEnded && widget.videoStyle.onHelperRePlay != null) {
                                      // If the video has ended and a replay callback is provided, call it
                                      widget.videoStyle.onHelperRePlay!();
                                      widget.rePlayVideo!();
                                    } else {
                                      // If the video is still playing or hasn't ended, toggle play/pause
                                      if (widget.onPlayButtonTap != null) {
                                        widget.onPlayButtonTap!();
                                      }
                                    }
                                  },
                                  child: widget.controller.value.isPlaying
                                      ? widget.videoStyle.pauseIcon ?? Icon(Icons.pause_circle_outline)
                                      : widget.controller.value.position >= widget.controller.value.duration
                                          ? widget.videoStyle.rePlayIcon ?? Icon(Icons.replay)
                                          : widget.videoStyle.playIcon ?? Icon(Icons.play_circle_outline),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  widget.controller.fastForward().then((value) {
                                    widget.onFastForward?.call(widget.controller.value);
                                  });
                                },
                                child: widget.videoStyle.forwardIcon ??
                                    Icon(
                                      Icons.fast_forward_rounded,
                                      color: widget.videoStyle.forwardIconColor,
                                      size: widget.videoStyle.forwardAndBackwardBtSize,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                toggleVolumeOverlay();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                child: widget.videoStyle.volumeIcon ??
                                    Icon(
                                      Icons.volume_up,
                                      color: widget.videoStyle.forwardIconColor,
                                      size: widget.videoStyle.forwardAndBackwardBtSize,
                                    ),
                              ),
                            ),
                            // Container(
                            //   margin: const EdgeInsets.only(bottom: 16.0),
                            //   child: InkWell(
                            //     onTap: onPlayVolumeTap,
                            //     child: videoStyle.volumeIcon ??
                            //         Icon(
                            //           Icons.fast_rewind_rounded,
                            //           color: videoStyle.forwardIconColor,
                            //           size: videoStyle.forwardAndBackwardBtSize,
                            //         ),
                            //   ),
                            // ),
                            const SizedBox(width: 16),
                            Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                PersianText(widget.videoDuration).convert(),
                                style: widget.videoStyle.videoDurationStyle ??
                                    const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _isVolumeOverlayVisible
                  ? Positioned(
                      left: 35,
                      bottom: 35,
                      child: SizedBox(
                        height: 150,
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 5.0,
                              ),
                            ),
                            child: Slider(
                              activeColor: Color(0xFF8D8C8C),
                              value: widget.controller.value.volume,
                              onChanged: (value) {
                                setState(() {
                                  widget.controller.setVolume(value);
                                });
                              },
                              min: 0.0,
                              max: 1.0,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class PersianText {
  final String text;
  final bool isMoney;

  PersianText(this.text, {this.isMoney = true});

  String convert() {
    final List<String> persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    // // If isMoney is true and the text can be parsed to a number, format it.
    // if (isMoney) {
    //   double? parsedDouble = double.tryParse(text.replaceAll(',', ''));
    //   if (parsedDouble != null) {
    //     String formattedText = NumberFormat("#,###").format(parsedDouble);
    //     // Convert formatted text to Persian numbers
    //     return formattedText.split('').map((character) {
    //       int? digit = int.tryParse(character);
    //       return digit != null ? persianNumbers[digit] : character;
    //     }).join('');
    //   }
    // }

    // Directly convert each character for non-money or if the above condition is not met
    return text.split('').map((character) {
      int? digit = int.tryParse(character);
      return digit != null ? persianNumbers[digit] : character; // Convert numeric characters to Persian
    }).join('');
  }
}
