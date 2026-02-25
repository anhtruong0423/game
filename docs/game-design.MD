## 📝 GAME DESIGN DOCUMENT: PICK MI UP (Bản Cập Nhật)

### 1. Thông tin chung

* **Góc nhìn:** Thứ nhất (First-Person Perspective).
* **Môi trường:** Một bản đồ cố định cho cả 3 level.
* **Vị trí vật phẩm:** Thay đổi (respawn) theo kịch bản của từng level để tăng độ khó.

### 2. Cơ chế Game Loop & Kinh tế

* **Tiền tệ (Credits/Points):** Tích lũy được sau khi hoàn thành nhiệm vụ và nhặt rác.
* **Hệ thống nâng cấp (Shop):** Chỉ xuất hiện ở giao diện **Bắt đầu màn chơi**. Người chơi dùng tiền tích lũy để nâng cấp:
* *Sức chứa túi đồ:* Nhặt được nhiều rác hơn trước khi phải về điểm tập kết.
* *Độ bền bỉ:* Giảm tốc độ tiêu hao năng lượng khi di chuyển/chạy nhanh.



### 3. Cơ chế Năng lượng & Vật phẩm hồi phục

* **Thanh năng lượng (HUD):**
* Màu xanh (>20%), chuyển đỏ và nhấp nháy (<20%).
* Khi cạn kiệt: Người chơi di chuyển cực chậm (Slow motion).


* **Sữa FRUMI (Dâu, Nho, Dưa lưới):**
* Cả 3 loại đều có **chỉ số hồi phục như nhau**.
* Sự khác biệt chủ yếu nằm ở mặt hình ảnh để quảng bá đa dạng dòng sản phẩm.



### 4. NPC Con Chó (AI State Machine)

* **Trạng thái 1 (Ngủ/Idle):** Đứng yên tại vị trí cố định.
* **Trạng thái 2 (Đuổi):** Kích hoạt khi người chơi vào bán kính 50cm. Tốc độ = 1.3 lần người chơi.
* **Trạng thái 3 (Ngừng đuổi):** Khi người chơi thoát khỏi bán kính 50cm, con chó sẽ dừng lại ngay lập tức tại vị trí đó và quay lại trạng thái **Đứng yên**.

### 5. Chi tiết nhiệm vụ 3 Level (Map Layout)

| Level | Yêu cầu nhiệm vụ | Điều kiện thời gian (để đạt 3 sao) |
| --- | --- | --- |
| **1** | 1 Túi vàng + 1 Chai nhựa | Không giới hạn thời gian |
| **2** | 1 Túi xanh + 1 Chai + 1 Túi đỏ | Dưới 5 phút |
| **3** | 1 Lá cây + 1 Túi đỏ + 1 Chai | Dưới 3 phút |

---

### 6. Cấu trúc Logic trong Godot (Gợi ý)

Vì bạn đang dùng **Godot**, mình gợi ý cấu trúc các Node để bạn dễ quản lý:

* **Player (CharacterBody3D):** Chứa Camera3D, Raycast3D (để nhặt đồ) và Script quản lý Stamina.
* **ItemManager (Node):** Quản lý việc xuất hiện của rác và sữa theo từng Level ID.
* **DogNPC (CharacterBody3D):** Sử dụng `Area3D` với bán kính 0.5m (50cm) để làm vùng phát hiện (Detection Zone).
* **UIManager (CanvasLayer):** Quản lý thanh năng lượng và danh sách nhiệm vụ ở góc màn hình.