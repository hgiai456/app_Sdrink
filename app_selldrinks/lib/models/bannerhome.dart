class BannerHome {
  final String id;
  final String hinhAnh;
  final String linkDen;

  BannerHome({
    required this.id,
    required this.hinhAnh,
    required this.linkDen,
  });

  // Sample data
  static List<BannerHome> getSampleData() {
    return [
      BannerHome(
        id: "1",
        hinhAnh: "assets/images/banner1.jpg",
        linkDen: "/promotion1",
      ),
      BannerHome(
        id: "2", 
        hinhAnh: "assets/images/banner2.jpg",
        linkDen: "/summer_menu",
      ),
      BannerHome(
        id: "3",
        hinhAnh: "assets/images/banner3.jpg",
        linkDen: "/combo",
      ),
      BannerHome(
        id: "4",
        hinhAnh: "assets/images/banner4.jpg", 
        linkDen: "/vip_member",
      ),
    ];
  }
}
