import 'package:matrix/matrix.dart';

extension ClientChatWallpaper on Client {
  static const String accountDataKey = 'im.fluffychat.chat_wallpaper';

  ChatWallpaper get chatWallpaper =>
      ChatWallpaper.fromJson(accountData[accountDataKey]?.content ?? {});

  Future<void> setChatWallpaper(ChatWallpaper chatWallpaper) => setAccountData(
        userID!,
        accountDataKey,
        chatWallpaper.toJson(),
      );
}

class ChatWallpaper {
  final Uri? url;
  final bool? blur;

  const ChatWallpaper({
    this.url,
    this.blur,
  });

  factory ChatWallpaper.fromJson(Map<String, dynamic> json) => ChatWallpaper(
        url: json['url'] is String ? Uri.tryParse(json['url']) : null,
        blur: json.tryGet<bool>('blur'),
      );

  Map<String, dynamic> toJson() => {
        if (url != null) 'url': url.toString(),
        if (blur != null) 'blur': blur,
      };
}
