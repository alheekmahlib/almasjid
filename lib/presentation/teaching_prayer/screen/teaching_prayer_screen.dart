part of '../teaching.dart';

class TeachingPrayerScreen extends StatelessWidget {
  const TeachingPrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TeachingPrayerController.instance; // ensure init
    final ctrl = TeachingPrayerController.instance;

    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: SafeArea(
        child: Container(
          color: context.theme.colorScheme.primaryContainer,
          child: Column(
            children: [
              const AppBarWidget(withBackButton: false),
              GetBuilder<TeachingPrayerController>(
                id: 'loading_state',
                builder: (_) => ctrl.isLoading.value
                    ? Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: context.theme.colorScheme.surface,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              GetBuilder<TeachingPrayerController>(
                id: 'content_state',
                builder: (_) {
                  final sections = ctrl.sections;
                  if (sections.isEmpty && !ctrl.isLoading.value) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          'noData'.trParams({'x': 'TeachingPrayer'}),
                          style: TextStyle(
                            color: context.theme.colorScheme.inversePrimary,
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView(
                      children: [
                        const Gap(16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            customSvgWithColor(
                              height: 180,
                              SvgPath.svgHomeTeachingPrayer,
                              color: context.theme.colorScheme.surface
                                  .withValues(alpha: .1),
                            ),
                            Column(
                              children: [
                                customSvgWithColor(
                                  height: 60,
                                  SvgPath.svgLiatafaqahuu,
                                  color: context.theme.colorScheme.surface,
                                ),
                                Text(
                                  'understanding'.tr,
                                  style: TextStyle(
                                    color: context
                                        .theme.colorScheme.inversePrimary
                                        .withValues(alpha: .9),
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'cairo',
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Gap(8),
                        const SunnahsAndHeresies(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            final section = sections[index];
                            final title = section.resolveName(ctrl.currentLang);
                            return _SectionCard(title: title, index: index);
                          },
                        ),
                        const Gap(80),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
