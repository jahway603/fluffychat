import 'package:file_picker/file_picker.dart';
import 'package:fluffychat/utils/client_wallpaper.dart';
import 'package:fluffychat/widgets/app_lock.dart';
import 'package:flutter/material.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/widgets/theme_builder.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import '../../widgets/matrix.dart';
import 'settings_style_view.dart';

class SettingsStyle extends StatefulWidget {
  const SettingsStyle({super.key});

  @override
  SettingsStyleController createState() => SettingsStyleController();
}

class SettingsStyleController extends State<SettingsStyle> {
  void setChatColor(Color? color) async {
    AppConfig.colorSchemeSeed = color;
    ThemeController.of(context).setPrimaryColor(color);
  }

  void setWallpaper() async {
    final client = Matrix.of(context).client;
    final picked = await AppLock.of(context).pauseWhile(
      FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      ),
    );
    final pickedFile = picked?.files.firstOrNull;
    if (pickedFile == null) return;

    await showFutureLoadingDialog(
      context: context,
      future: () async {
        final url = await client.uploadContent(
          pickedFile.bytes!,
          filename: pickedFile.name,
        );
        final chatWallpaper = client.chatWallpaper;
        await client.setChatWallpaper(
          ChatWallpaper(url: url, blur: chatWallpaper.blur),
        );
      },
    );
  }

  void toggleChatWallpaperBlur(bool blur) {
    final client = Matrix.of(context).client;
    showFutureLoadingDialog(
      context: context,
      future: () => client.setChatWallpaper(
        ChatWallpaper(url: client.chatWallpaper.url, blur: blur),
      ),
    );
  }

  void deleteChatWallpaper() => showFutureLoadingDialog(
        context: context,
        future: () => Matrix.of(context).client.setChatWallpaper(
              const ChatWallpaper(url: null, blur: null),
            ),
      );

  ThemeMode get currentTheme => ThemeController.of(context).themeMode;
  Color? get currentColor => ThemeController.of(context).primaryColor;

  static final List<Color?> customColors = [
    null,
    AppConfig.chatColor,
    Colors.indigo,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.blueGrey,
  ];

  void switchTheme(ThemeMode? newTheme) {
    if (newTheme == null) return;
    switch (newTheme) {
      case ThemeMode.light:
        ThemeController.of(context).setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.dark:
        ThemeController.of(context).setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.system:
        ThemeController.of(context).setThemeMode(ThemeMode.system);
        break;
    }
    setState(() {});
  }

  void changeFontSizeFactor(double d) {
    setState(() => AppConfig.fontSizeFactor = d);
    Matrix.of(context).store.setString(
          SettingKeys.fontSizeFactor,
          AppConfig.fontSizeFactor.toString(),
        );
  }

  @override
  Widget build(BuildContext context) => SettingsStyleView(this);
}
