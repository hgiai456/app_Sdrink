class BestSeller {
  final String id;
  final String tenSanPham;
  final String hinhAnh;
  final double gia;
  final double giaGoc;
  final String moTa;
  final double danhGia;
  final int soLuongBan;
  final bool coGiamGia;

  BestSeller({
    required this.id,
    required this.tenSanPham,
    required this.hinhAnh,
    required this.gia,
    required this.giaGoc,
    required this.moTa,
    required this.danhGia,
    required this.soLuongBan,
    required this.coGiamGia,
  });

  // Sample data
  static List<BestSeller> getSampleData() {
    return [
      BestSeller(
        id: "1",
        tenSanPham: "Cà phê đen đá",
        hinhAnh: "assets/images/coff.png",
        gia: 25000,
        giaGoc: 30000,
        moTa: "Cà phê đen đá truyền thống đậm đà",
        danhGia: 4.8,
        soLuongBan: 1250,
        coGiamGia: true,
      ),
      BestSeller(
        id: "2",
        tenSanPham: "Trà sữa trân châu",
        hinhAnh: "assets/images/coffee.png",
        gia: 45000,
        giaGoc: 45000,
        moTa: "Trà sữa trân châu đường đen thơm ngon",
        danhGia: 4.9,
        soLuongBan: 980,
        coGiamGia: false,
      ),
      BestSeller(
        id: "3",
        tenSanPham: "Bánh croissant",
        hinhAnh: "assets/images/coffee.png",
        gia: 35000,
        giaGoc: 40000,
        moTa: "Bánh croissant bơ thơm giòn tan",
        danhGia: 4.7,
        soLuongBan: 750,
        coGiamGia: true,
      ),
      BestSeller(
        id: "4",
        tenSanPham: "Sinh tố bơ",
        hinhAnh: "assets/images/coffee.png",
        gia: 42000,
        giaGoc: 42000,
        moTa: "Sinh tố bơ béo ngậy, bổ dưỡng",
        danhGia: 4.6,
        soLuongBan: 620,
        coGiamGia: false,
      ),
      BestSeller(
        id: "5",
        tenSanPham: "Cappuccino",
        hinhAnh: "assets/images/coffee.png",
        gia: 38000,
        giaGoc: 45000,
        moTa: "Cappuccino Italia đậm đà với foam sữa mịn",
        danhGia: 4.8,
        soLuongBan: 890,
        coGiamGia: true,
      ),
      BestSeller(
        id: "6",
        tenSanPham: "Bánh mì sandwich",
        hinhAnh: "assets/images/coffee.png",
        gia: 32000,
        giaGoc: 32000,
        moTa: "Bánh mì sandwich với nhân thịt nguội và rau củ",
        danhGia: 4.5,
        soLuongBan: 540,
        coGiamGia: false,
      ),
    ];
  }
}
