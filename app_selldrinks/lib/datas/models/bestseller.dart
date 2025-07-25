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
        hinhAnh: "assets/images/phin-den-da.webp",
        gia: 25000,
        giaGoc: 30000,
        moTa: "Cà phê đen đá truyền thống đậm đà",
        danhGia: 4.8,
        soLuongBan: 1250,
        coGiamGia: true,
      ),
      BestSeller(
        id: "2",
        tenSanPham: "Cà phê sữa",
        hinhAnh:
            "assets/images/phin-sua-da-eae59734-6d54-471e-a34f-7ffe0fb68e6c.webp",
        gia: 45000,
        giaGoc: 45000,
        moTa: "Cà phê đen đá truyền thống đậm đà",
        danhGia: 4.9,
        soLuongBan: 980,
        coGiamGia: false,
      ),
      BestSeller(
        id: "3",
        tenSanPham: "Latte",
        hinhAnh: "assets/images/latte.webp",
        gia: 35000,
        giaGoc: 40000,
        moTa: "Cà phê đen đá truyền thống đậm đà",
        danhGia: 4.7,
        soLuongBan: 750,
        coGiamGia: true,
      ),
      BestSeller(
        id: "4",
        tenSanPham: "Americano",
        hinhAnh: "assets/images/americano.webp",
        gia: 42000,
        giaGoc: 42000,
        moTa: "Cà phê đen đá truyền thống đậm đà",
        danhGia: 4.6,
        soLuongBan: 620,
        coGiamGia: false,
      ),
      BestSeller(
        id: "5",
        tenSanPham: "Cappuccino",
        hinhAnh: "assets/images/cappucino-nong.webp",
        gia: 38000,
        giaGoc: 45000,
        moTa: "Cappuccino Italia đậm đà với foam sữa mịn",
        danhGia: 4.8,
        soLuongBan: 890,
        coGiamGia: true,
      ),
      BestSeller(
        id: "6",
        tenSanPham: "Bánh mì pate",
        hinhAnh: "assets/images/bmq-pate.webp",
        gia: 32000,
        giaGoc: 32000,
        moTa: "Bánh mì pate thơm ngon",
        danhGia: 4.5,
        soLuongBan: 540,
        coGiamGia: false,
      ),
    ];
  }
}
