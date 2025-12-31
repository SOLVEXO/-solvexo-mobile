class BannerModel {
  final String title;
  final String desc;
  final String image;

  BannerModel({required this.title, required this.desc, required this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      title: json['title'],
      desc: json['desc'],
      image: json['prod_image'],
    );
  }
}
