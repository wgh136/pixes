import 'package:pixes/appdata.dart';

class Account {
  String accessToken;
  String refreshToken;
  final User user;

  Account(this.accessToken, this.refreshToken, this.user);

  Account.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'],
        refreshToken = json['refresh_token'],
        user = User.fromJson(json['user']);

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user': user.toJson()
      };
}

class User {
  String profile;
  final String id;
  String name;
  String account;
  String email;
  bool isPremium;

  User(this.profile, this.id, this.name, this.account, this.email,
      this.isPremium);

  User.fromJson(Map<String, dynamic> json)
      : profile = json['profile_image_urls']['px_170x170'],
        id = json['id'],
        name = json['name'],
        account = json['account'],
        email = json['mail_address'],
        isPremium = json['is_premium'];

  Map<String, dynamic> toJson() => {
        'profile_image_urls': {'px_170x170': profile},
        'id': id,
        'name': name,
        'account': account,
        'mail_address': email,
        'is_premium': isPremium
      };
}

class UserDetails {
  final int id;
  final String name;
  final String account;
  final String avatar;
  final String comment;
  final bool isFollowed;
  final bool isBlocking;
  final String? webpage;
  final String gender;
  final String birth;
  final String region;
  final String job;
  final int totalFollowUsers;
  final int myPixivUsers;
  final int totalIllusts;
  final int totalMangas;
  final int totalNovels;
  final int totalIllustBookmarks;
  final String? backgroundImage;
  final String? twitterUrl;
  final bool isPremium;
  final String? pawooUrl;

  UserDetails(
      this.id,
      this.name,
      this.account,
      this.avatar,
      this.comment,
      this.isFollowed,
      this.isBlocking,
      this.webpage,
      this.gender,
      this.birth,
      this.region,
      this.job,
      this.totalFollowUsers,
      this.myPixivUsers,
      this.totalIllusts,
      this.totalMangas,
      this.totalNovels,
      this.totalIllustBookmarks,
      this.backgroundImage,
      this.twitterUrl,
      this.isPremium,
      this.pawooUrl);

  UserDetails.fromJson(Map<String, dynamic> json)
      : id = json['user']['id'],
        name = json['user']['name'],
        account = json['user']['account'],
        avatar = json['user']['profile_image_urls']['medium'],
        comment = json['user']['comment'],
        isFollowed = json['user']['is_followed'],
        isBlocking = json['user']['is_access_blocking_user'],
        webpage = json['profile']['webpage'],
        gender = json['profile']['gender'],
        birth = json['profile']['birth'],
        region = json['profile']['region'],
        job = json['profile']['job'],
        totalFollowUsers = json['profile']['total_follow_users'],
        myPixivUsers = json['profile']['total_mypixiv_users'],
        totalIllusts = json['profile']['total_illusts'],
        totalMangas = json['profile']['total_manga'],
        totalNovels = json['profile']['total_novels'],
        totalIllustBookmarks = json['profile']['total_illust_bookmarks_public'],
        backgroundImage = json['profile']['background_image_url'],
        twitterUrl = json['profile']['twitter_url'],
        isPremium = json['profile']['is_premium'],
        pawooUrl = json['profile']['pawoo_url'];
}

class IllustAuthor {
  final int id;
  final String name;
  final String account;
  final String avatar;
  bool isFollowed;

  IllustAuthor(
      this.id, this.name, this.account, this.avatar, this.isFollowed);
}

class Tag {
  final String name;
  final String? translatedName;

  const Tag(this.name, this.translatedName);
}

class IllustImage {
  final String squareMedium;
  final String medium;
  final String large;
  final String original;

  const IllustImage(this.squareMedium, this.medium, this.large, this.original);
}

class Illust {
  final int id;
  final String title;
  final String type;
  final List<IllustImage> images;
  final String caption;
  final int restrict;
  final IllustAuthor author;
  final List<Tag> tags;
  final String createDate;
  final int pageCount;
  final int width;
  final int height;
  final int totalView;
  final int totalBookmarks;
  bool isBookmarked;
  final bool isAi;

  Illust.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        type = json['type'],
        images = (() {
          List<IllustImage> images = [];
          for (var i in json['meta_pages']) {
            images.add(IllustImage(
                i['image_urls']['square_medium'],
                i['image_urls']['medium'],
                i['image_urls']['large'],
                i['image_urls']['original']));
          }
          if (images.isEmpty) {
            images.add(IllustImage(
                json['image_urls']['square_medium'],
                json['image_urls']['medium'],
                json['image_urls']['large'],
                json['meta_single_page']['original_image_url']));
          }
          return images;
        }()),
        caption = json['caption'],
        restrict = json['restrict'],
        author = IllustAuthor(
            json['user']['id'],
            json['user']['name'],
            json['user']['account'],
            json['user']['profile_image_urls']['medium'],
            json['user']['is_followed'] ?? false),
        tags = (json['tags'] as List)
            .map((e) => Tag(e['name'], e['translated_name']))
            .toList(),
        createDate = json['create_date'],
        pageCount = json['page_count'],
        width = json['width'],
        height = json['height'],
        totalView = json['total_view'],
        totalBookmarks = json['total_bookmarks'],
        isBookmarked = json['is_bookmarked'],
        isAi = json['is_ai'] != 1;
}

class TrendingTag {
  final Tag tag;
  final Illust illust;

  TrendingTag(this.tag, this.illust);
}

enum KeywordMatchType {
  tagsPartialMatches("Tags partial matches"),
  tagsExactMatch("Tags exact match"),
  titleOrDescriptionSearch("Title or description search");

  final String text;

  const KeywordMatchType(this.text);

  @override
  toString() => text;
}

enum FavoriteNumber {
  unlimited(-1),
  f500(500),
  f1000(1000),
  f2000(2000),
  f5000(5000),
  f7500(7500),
  f10000(10000),
  f20000(20000),
  f50000(50000),
  f100000(100000);

  final int number;
  const FavoriteNumber(this.number);

  @override
  toString() => this == FavoriteNumber.unlimited ? "Unlimited" : "$number Bookmarks";
}

enum SearchSort {
  newToOld,
  oldToNew,
  popular;

  @override
  toString() {
    if(this == SearchSort.popular) {
      return appdata.account?.user.isPremium == true ? "Popular" : "Popular(limited)";
    } else if(this == SearchSort.newToOld) {
      return "New to old";
    } else {
      return "Old to new";
    }
  }
}

enum AgeLimit {
  unlimited("Unlimited"),
  allAges("All ages"),
  r18("R18");

  final String text;

  const AgeLimit(this.text);

  @override
  toString() => text;
}

class SearchOptions {
  KeywordMatchType matchType = KeywordMatchType.tagsPartialMatches;
  FavoriteNumber favoriteNumber = FavoriteNumber.unlimited;
  SearchSort sort = SearchSort.newToOld;
  DateTime? startTime;
  DateTime? endTime;
  AgeLimit ageLimit = AgeLimit.unlimited;
}
