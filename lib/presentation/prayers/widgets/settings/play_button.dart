part of '../../prayers.dart';

class PlayButton extends StatelessWidget {
  final List<AdhanData> adhanData;
  final int index;

  PlayButton({super.key, required this.adhanData, required this.index});

  final notificationCtrl = PrayersNotificationsCtrl.instance;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          StreamBuilder<PlayerState>(
            stream: notificationCtrl.state.audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final isCurrentlyPlaying =
                  notificationCtrl.state.currentlyPlayingIndex.value == index;
              final isPlaying = playerState?.playing ?? false;

              if (playerState?.processingState == ProcessingState.buffering &&
                  isCurrentlyPlaying) {
                return const CircularProgressIndicator(
                  constraints: BoxConstraints(maxWidth: 20.0, maxHeight: 20.0),
                );
              } else if (isCurrentlyPlaying && isPlaying) {
                return IconButton(
                  icon: customSvg(
                    SvgPath.svgPrayerPauseArrow,
                    height: 26,
                  ),
                  onPressed: () {
                    notificationCtrl.state.audioPlayer.pause();
                    notificationCtrl.state.currentlyPlayingIndex.value = null;
                  },
                );
              } else {
                return IconButton(
                  icon: customSvg(
                    SvgPath.svgPrayerPlayArrow,
                    height: 26,
                  ),
                  onPressed: () async {
                    notificationCtrl.state.currentlyPlayingIndex.value = index;
                    await notificationCtrl.playButtonOnTap(adhanData, index);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
