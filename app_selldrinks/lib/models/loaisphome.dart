class LoaiSpHome {
  final String id;
  final String tenLoai;
  final String hinhAnh;
  final String moTa;

  LoaiSpHome({
    required this.id,
    required this.tenLoai,
    required this.hinhAnh,
    required this.moTa,
  });

  // Sample data
  static List<LoaiSpHome> getSampleData() {
    return [
      LoaiSpHome(
        id: "1",
        tenLoai: "Cà phê",
        hinhAnh: "assets/images/coffee.png",
        moTa: "Các loại cà phê ngon",
      ),
      LoaiSpHome(
        id: "2",
        tenLoai: "Trà sữa",
        hinhAnh: "assets/images/coffee.png",
        moTa: "Trà sữa đặc biệt",
      ),
      LoaiSpHome(
        id: "3",
        tenLoai: "Sinh tố",
        hinhAnh: "assets/images/coffee.png",
        moTa: "Sinh tố tươi mát",
      ),
      LoaiSpHome(
        id: "4",
        tenLoai: "Bánh ngọt",
        hinhAnh: "assets/images/coffee.png",
        moTa: "Bánh ngọt thơm ngon",
      ),
      LoaiSpHome(
        id: "5",
        tenLoai: "Nước ép",
        hinhAnh: "assets/images/coffee.png",
        moTa: "Nước ép tươi",
      ),
      LoaiSpHome(
        id: "6",
        tenLoai: "Đồ ăn nhẹ",
        hinhAnh: "assets/images/coffee.png",
        moTa: "Đồ ăn nhẹ ngon miệng",
      ),
    ];
  }
}
