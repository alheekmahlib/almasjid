import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get_utils/get_utils.dart';

import '/core/utils/constants/lottie_constants.dart';
import '../../../../../core/utils/constants/extensions/extensions.dart';
import '../../../../../core/utils/constants/lottie.dart';
import '../../../../core/widgets/container_button_widget.dart';
import '../../controller/our_apps_controller.dart';
import '../../data/models/our_app_model.dart';

class OurAppsBuild extends StatelessWidget {
  OurAppsBuild({super.key});

  final ourApps = OurAppsController.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OurAppInfo>>(
      future: ourApps.fetchApps(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<OurAppInfo>? apps = snapshot.data;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ListView.separated(
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: apps!.length,
              separatorBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: context.hDivider(width: 10.0),
              ),
              itemBuilder: (context, index) {
                return ContainerButtonWidget(
                  onPressed: () =>
                      ourApps.launchURL(context, index, apps[index]),
                  height: 55,
                  horizontalMargin: 32.0,
                  verticalPadding: 0.0,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shapeColor:
                      context.theme.colorScheme.surface.withValues(alpha: .1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.network(
                        apps[index].appLogo,
                        height: 40,
                        width: 40,
                      ),
                      const Gap(24.0),
                      context.vDivider(height: 40.0),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              apps[index].appTitle,
                              style: TextStyle(
                                color: context.theme.colorScheme.inversePrimary,
                                fontSize: 13,
                                height: 1.7,
                                fontFamily: 'cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(8.0),
                            Text(
                              apps[index].body,
                              style: TextStyle(
                                color: context.theme.colorScheme.surface
                                    .withValues(alpha: .7),
                                fontSize: 11,
                                height: 1.7,
                                fontFamily: 'cairo',
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return customLottie(LottieConstants.assetsLottieNoInternet,
              width: 150.0, height: 150.0);
        }
        return customLottie(LottieConstants.assetsLottieSplashLoading,
            width: 200.0, height: 200.0);
      },
    );
  }
}
