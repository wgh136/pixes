import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:pixes/appdata.dart';
import 'package:pixes/foundation/app.dart';
import 'package:pixes/foundation/log.dart';
import 'package:pixes/network/app_dio.dart';
import 'package:pixes/network/res.dart';

import 'models.dart';

export 'models.dart';
export 'res.dart';

class Network {
  static const hashSalt =
      "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";

  static const baseUrl = 'https://app-api.pixiv.net';
  static const oauthUrl = 'https://oauth.secure.pixiv.net';

  static const String clientID = "MOBrBDS8blbauoSck0ZfDbtuzpyT";
  static const String clientSecret = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj";
  static const String refreshClientID = "KzEZED7aC0vird8jWyHM38mXjNTY";
  static const String refreshClientSecret =
      "W9JZoJe00qPvJsiyCGT3CCtC6ZUtdpKpzMbNlUGP";

  static Network? instance;

  factory Network() => instance ?? (instance = Network._create());

  Network._create();

  String? codeVerifier;

  String? get token => appdata.account?.accessToken;

  final dio = AppDio();

  Map<String, String> get _headers {
    final time =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'").format(DateTime.now());
    final hash = md5.convert(utf8.encode(time + hashSalt)).toString();
    return {
      "X-Client-Time": time,
      "X-Client-Hash": hash,
      "User-Agent": "PixivAndroidApp/5.0.234 (Android 14.0; Pixes)",
      "accept-language": App.locale.toLanguageTag(),
      "Accept-Encoding": "gzip",
      if (token != null) "Authorization": "Bearer $token"
    };
  }

  Future<String> generateWebviewUrl() async {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    codeVerifier =
        List.generate(128, (i) => chars[Random.secure().nextInt(chars.length)])
            .join();
    final codeChallenge = base64Url
        .encode(sha256.convert(ascii.encode(codeVerifier!)).bytes)
        .replaceAll('=', '');
    return "https://app-api.pixiv.net/web/v1/login?code_challenge=$codeChallenge&code_challenge_method=S256&client=pixiv-android";
  }

  Future<Res<bool>> loginWithCode(String code) async {
    try {
      var res = await dio.post<String>("$oauthUrl/auth/token",
          data: {
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code,
            "code_verifier": codeVerifier,
            "grant_type": "authorization_code",
            "include_policy": "true",
            "redirect_uri":
                "https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback",
          },
          options: Options(
              contentType: Headers.formUrlEncodedContentType,
              headers: _headers));
      if (res.statusCode != 200) {
        throw "Invalid Status code ${res.statusCode}";
      }
      final data = json.decode(res.data!);
      appdata.account = Account.fromJson(data);
      appdata.writeData();
      return const Res(true);
    } catch (e, s) {
      Log.error("Network", "$e\n$s");
      return Res.error(e);
    }
  }

  Future<Res<bool>> refreshToken() async {
    try {
      var res = await dio.post<String>("$oauthUrl/auth/token",
          data: {
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": "refresh_token",
            "refresh_token": appdata.account?.refreshToken,
            "include_policy": "true",
          },
          options: Options(
              contentType: Headers.formUrlEncodedContentType,
              headers: _headers));
      var account = Account.fromJson(json.decode(res.data!));
      appdata.account = account;
      appdata.writeData();
      return const Res(true);
    } catch (e, s) {
      Log.error("Network", "$e\n$s");
      return Res.error(e);
    }
  }

  Future<Res<Map<String, dynamic>>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    try {
      if (!path.startsWith("http")) {
        path = "$baseUrl$path";
      }
      final res = await dio.get<Map<String, dynamic>>(path,
          queryParameters: query,
          options:
              Options(headers: _headers, validateStatus: (status) => true));
      if (res.statusCode == 200) {
        return Res(res.data!);
      } else if (res.statusCode == 400) {
        if (res.data.toString().contains("Access Token")) {
          var refresh = await refreshToken();
          if (refresh.success) {
            return apiGet(path, query: query);
          } else {
            return Res.error(refresh.errorMessage);
          }
        } else {
          return Res.error("Invalid Status Code: ${res.statusCode}");
        }
      } else if ((res.statusCode ?? 500) < 500) {
        return Res.error(res.data?["error"]?["message"] ??
            "Invalid Status code ${res.statusCode}");
      } else {
        return Res.error("Invalid Status Code: ${res.statusCode}");
      }
    } catch (e, s) {
      Log.error("Network", "$e\n$s");
      return Res.error(e);
    }
  }

  Future<Res<Map<String, dynamic>>> apiPost(String path,
      {Map<String, dynamic>? query, Map<String, dynamic>? data}) async {
    try {
      if (!path.startsWith("http")) {
        path = "$baseUrl$path";
      }
      final res = await dio.post<Map<String, dynamic>>(path,
          queryParameters: query,
          data: data,
          options: Options(
              headers: _headers,
              validateStatus: (status) => true,
              contentType: Headers.formUrlEncodedContentType));
      if (res.statusCode == 200) {
        return Res(res.data!);
      } else if (res.statusCode == 400) {
        if (res.data.toString().contains("Access Token")) {
          var refresh = await refreshToken();
          if (refresh.success) {
            return apiGet(path, query: query);
          } else {
            return Res.error(refresh.errorMessage);
          }
        } else {
          return Res.error("Invalid Status Code: ${res.statusCode}");
        }
      } else if ((res.statusCode ?? 500) < 500) {
        return Res.error(res.data?["error"]?["message"] ??
            "Invalid Status code ${res.statusCode}");
      } else {
        return Res.error("Invalid Status Code: ${res.statusCode}");
      }
    } catch (e, s) {
      Log.error("Network", "$e\n$s");
      return Res.error(e);
    }
  }

  /// get user details
  Future<Res<UserDetails>> getUserDetails(Object userId) async {
    var res = await apiGet("/v1/user/detail",
        query: {"user_id": userId, "filter": "for_android"});
    if (res.success) {
      return Res(UserDetails.fromJson(res.data));
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getRecommendedIllusts() async {
    var res = await apiGet(
        "/v1/illust/recommended?include_privacy_policy=true&filter=for_android&include_ranking_illusts=true");
    if (res.success) {
      return Res((res.data["illusts"] as List)
          .map((e) => Illust.fromJson(e))
          .toList());
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getBookmarkedIllusts(String restrict,
      [String? nextUrl]) async {
    var res = await apiGet(nextUrl ??
        "/v1/user/bookmarks/illust?user_id=49258688&restrict=$restrict");
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<bool>> addBookmark(String id, String method,
      [String type = "public"]) async {
    var res = method == "add"
        ? await apiPost("/v2/illust/bookmark/$method",
            data: {"illust_id": id, "restrict": type})
        : await apiPost("/v1/illust/bookmark/$method", data: {
            "illust_id": id,
          });
    if (!res.error) {
      return const Res(true);
    } else {
      return Res.fromErrorRes(res);
    }
  }

  Future<Res<bool>> follow(String uid, String method,
      [String type = "public"]) async {
    var res = method == "add"
        ? await apiPost("/v1/user/follow/add",
            data: {"user_id": uid, "restrict": type})
        : await apiPost("/v1/user/follow/delete", data: {
            "user_id": uid,
          });
    if (!res.error) {
      return const Res(true);
    } else {
      return Res.fromErrorRes(res);
    }
  }

  Future<Res<List<TrendingTag>>> getHotTags() async {
    var res = await apiGet(
        "/v1/trending-tags/illust?filter=for_android&include_translated_tag_results=true");
    if (res.error) {
      return Res.fromErrorRes(res);
    } else {
      return Res(List.from(res.data["trend_tags"].map((e) => TrendingTag(
          Tag(e["tag"], e["translated_name"]), Illust.fromJson(e["illust"])))));
    }
  }

  Future<Res<List<Illust>>> search(
      String keyword, SearchOptions options) async {
    String path = "";
    final encodedKeyword = Uri.encodeComponent(keyword +
        options.favoriteNumber.toParam() +
        options.ageLimit.toParam());
    if (options.sort == SearchSort.popular && !options.sort.isPremium) {
      path =
          "/v1/search/popular-preview/illust?filter=for_android&include_translated_tag_results=true&merge_plain_keyword_results=true&word=$encodedKeyword&search_target=${options.matchType.toParam()}";
    } else {
      path =
          "/v1/search/illust?filter=for_android&include_translated_tag_results=true&merge_plain_keyword_results=true&word=$encodedKeyword&sort=${options.sort.toParam()}&search_target=${options.matchType.toParam()}";
    }

    var res = await apiGet(path);
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getIllustsWithNextUrl(String nextUrl) async{
    var res = await apiGet(nextUrl);
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<UserPreview>>> searchUsers(String keyword, [String? nextUrl]) async{
    var path = nextUrl ?? "/v1/search/user?filter=for_android&word=${Uri.encodeComponent(keyword)}";
    var res = await apiGet(path);
    if (res.success) {
      return Res(
          (res.data["user_previews"] as List).map((e) => UserPreview.fromJson(e["user"])).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getUserIllusts(String uid) async {
    var res = await apiGet("/v1/user/illusts?filter=for_android&user_id=$uid&type=illust");
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<UserPreview>>> getFollowing(String uid, String type, [String? nextUrl]) async {
    var path = nextUrl ?? "/v1/user/following?filter=for_android&user_id=$uid&restrict=$type";
    var res = await apiGet(path);
    if (res.success) {
      return Res(
          (res.data["user_previews"] as List).map((e) => UserPreview.fromJson(e["user"])).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<Illust>>> getFollowingArtworks(String restrict, [String? nextUrl]) async {
    var res = await apiGet(nextUrl ?? "/v2/illust/follow?restrict=$restrict");
    if (res.success) {
      return Res(
          (res.data["illusts"] as List).map((e) => Illust.fromJson(e)).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }

  Future<Res<List<UserPreview>>> getRecommendationUsers() async {
    var res = await apiGet("/v1/user/recommended?filter=for_android");
    if (res.success) {
      return Res(
          (res.data["user_previews"] as List).map((e) => UserPreview.fromJson(e["user"])).toList(),
          subData: res.data["next_url"]);
    } else {
      return Res.error(res.errorMessage);
    }
  }
}
