import 'package:flutter/material.dart';
import 'package:vanphongpham/view/product/widgets/widget_bottomNavigationbar.dart';


class ThongBao extends StatelessWidget {
  const ThongBao({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Thông báo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: const [
          NotificationItem(
            icon: '🔥',
            title: '25.3 FAHASA LƯƠNG VỀ SALE TO',
            date: '22/03/2025',
            content: [
              Content(icon: '⏰', text: 'Lưu ngay loạt ưu đãi cực hot:'),
              Content(icon: '🎁', text: 'Săn Voucher giảm 97.000Đ'),
              Content(icon: '🔥', text: 'Manga Hot chỉ còn 3.000Đ'),
              Content(
                  icon: '📚',
                  text:
                      'Đa dạng thể loại sách HOT thuộc các chủ đề: Văn học, Tham Khảo, Luyện Thi, Kinh Tế... với ưu đãi lên đến 50%'),
            ],
            backgroundColor: Colors.white,
          ),
          NotificationItem(
            icon: '🎮',
            title: 'Tham gia "CẢNH CỰT THẦN TỐC" rinh quà khủng',
            date: '22/03/2025',
            content: [
              Content(
                  icon: '▶️',
                  text:
                      'Chỉ cần mua sắm từ 100.000Đ Fahasa.com, bạn sẽ nhận ngay 5 lượt chơi "CẢNH CỰT THẦN TỐC" đầy kịch tính'),
              Content(
                  icon: '🎁',
                  text:
                      'Bạn đã sẵn sàng chinh phục Máy Lọc Không Khí Kangaroo KG36AP và 6 triệu F-Point chưa?'),
            ],
            backgroundColor: Colors.white,
          ),
          NotificationItem(
            icon: '🎮',
            title: 'Tham gia "CẢNH CỰT THẦN TỐC" rinh quà khủng',
            date: '22/03/2025',
            content: [
              Content(
                  icon: '▶️',
                  text:
                      'Chỉ cần mua sắm từ 250.000Đ Fahasa.com, bạn sẽ nhận ngay 5 lượt chơi "CẢNH CỰT THẦN TỐC" đầy kịch tính'),
              Content(
                  icon: '🎁',
                  text:
                      'Bạn đã sẵn sàng chinh phục Máy Lọc Không Khí Kangaroo KG36AP và 6 triệu F-Point chưa?'),
            ],
            backgroundColor: Colors.white,
          ),
          NotificationItem(
            icon: '🎁',
            title: 'NHANH TAY NHẬN QUÀ HỘI SÁCH',
            date: '20/03/2025',
            content: [
              Content(
                  icon: '🎁',
                  text:
                      'Quà tặng cực chất: Bộ sticker độc quyền dành riêng cho mọi đơn hàng'),
              Content(
                  icon: '🧑‍🎨',
                  text:
                      'Chỉ cần chốt đơn, Bạn sẽ nhận ngay bộ sticker siêu dễ thương để tô điểm góc đọc sách của mình'),
              Content(
                  icon: '🚀',
                  text:
                      'Hàng ngàn tựa sách hay đang chờ bạn khám phá tại Hội Sách Online Tháng 3'),
            ],
            backgroundColor: Color(0xFFFFF9E6),
          ),
          NotificationItem(
            icon: '🔔',
            title: '[Số mới] Hoa Học Trò Số 1454',
            date: '20/03/2025',
            content: [
              Content(
                  icon: '👑',
                  text:
                      'Các Rockin ơi, S.T Sơn Thạch chính thức xuất hiện trên bìa báo Hoa Học Trò'),
              Content(
                  icon: '👑',
                  text:
                      'Ngoài ra, còn có Hòa Minzy mang \'Bắc Bling\' lên báo nhá mọi người'),
              Content(icon: '😎', text: 'Đừng bỏ lỡ!'),
            ],
            backgroundColor: Color(0xFFFFF9E6),
          ),
          NotificationItem(
            icon: '🔔',
            title: 'Thông Báo Bảo Trì Hệ Thống',
            date: '20/03/2025',
            content: [
              Content(
                  text:
                      'Quý khách thân mến, nhằm mang đến trải nghiệm tốt hơn cho khách hàng, Fahasa xin thông báo bảo trì hệ thống website và app Fahasa từ 23h ngày 20/03/2025 đến 6h sáng ngày 21/03/2025.'),
            ],
            backgroundColor: Color(0xFFFFF9E6),
          ),
        ],
      ),
      bottomNavigationBar: widget_bottomNavigationbar(currentIndex: 2),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String icon;
  final String title;
  final String date;
  final List<Content> content;
  final Color backgroundColor;

  const NotificationItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.date,
    required this.content,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ...content
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.icon != null)
                                    Text(
                                      item.icon!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  if (item.icon != null)
                                    const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.text,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Content {
  final String? icon;
  final String text;

  const Content({
    this.icon,
    required this.text,
  });
}
