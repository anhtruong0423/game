# 📋 GAME DESIGN DOCUMENT (GDD)
## PICK MI UP 

---

## 1. Tổng quan game

| Mục | Thông tin |
|---|---|
| **Tên game** | PickMiUp |
| **Thể loại** | First-Person Exploration / Collection |
| **Engine** | Godot Engine 4.x |
| **Nền tảng** | PC (Windows) |
| **Góc nhìn** | Ngôi thứ nhất (First-Person) |
| **Đối tượng** | Mọi lứa tuổi, đặc biệt thiếu niên |
| **Đồ án** | Đồ Án Tốt Nghiệp |

### Tóm tắt game
PickMiUp là game thu thập trái cây góc nhìn thứ nhất, lấy bối cảnh nông trại rộng lớn. Người chơi vào vai nhân vật thu hoạch trái cây theo nhiệm vụ của từng level, quản lý năng lượng, tránh chó bảo vệ, và nâng cấp trang bị để hoàn thành thử thách.

### Thông điệp
- Khuyến khích vận động và khám phá
- Quảng bá sản phẩm sữa Frumi (Dâu, Nho, Dưa lưới)
- Cảnh báo không chơi game quá 180 phút liên tục

---

## 2. Game Loop chính

```
Bắt đầu → Chọn Pet → Nhận nhiệm vụ (Dialogue) → Gameplay
    ↓
Di chuyển khám phá map → Nhặt trái cây (E) → Mang về rổ giao hàng (E)
    ↓
Uống sữa Frumi hồi năng lượng (Q) → Tránh chó bảo vệ → Nâng cấp (Tab)
    ↓
Hoàn thành nhiệm vụ → Nhận sao → Level tiếp theo hoặc chơi lại
```

---

## 3. Nhân vật & Hệ thống Pet

### 3.1 Nhân vật chính
- **Điều khiển**: WASD di chuyển, chuột nhìn xung quanh
- **Tương tác**: E (nhặt trái cây / giao hàng), Q (nhặt sữa)
- **Sprint**: Shift (chạy nhanh, tốn NL gấp đôi)

### 3.2 Hệ thống Pet
Người chơi chọn 1 pet đồng hành mỗi lần chơi:

| Pet | Bonus | Đặc tính |
|---|---|---|
| 🦊 **Cáo** | +20% tốc độ, -30% NL sprint | Nhanh nhẹn, phù hợp speedrun |
| 🐢 **Rùa** | +2 slot túi, -50% sát thương chó, hồi NL 1/s | Tanky, phù hợp khám phá |

**Cáo**: Tăng tốc độ di chuyển, giảm tiêu hao năng lượng khi sprint. Follow nhanh (x2).

**Rùa**: Tăng sức chứa túi, giảm sát thương từ chó, hồi năng lượng thụ động khi đứng yên gần rùa (tối đa 30% NL). Follow chậm (x0.5).

---

## 4. Hệ thống chơi (Gameplay Systems)

### 4.1 Hệ thống năng lượng (Energy)
- **Max NL**: 100
- **Tiêu hao**: 5 NL/giây khi di chuyển, x2 khi sprint
- **Hồi phục**: Uống sữa Frumi
- **Cạn kiệt (0 NL)**: Game Over → chuyển màn hình thua
- **HUD**: Thanh xanh lá > 20%, đỏ nhấp nháy ≤ 20%

### 4.2 Hệ thống túi đồ (Inventory)
- **Sức chứa mặc định**: 1 slot (+ bonus pet)
- **Trọng lượng**: Mỗi item có weight, tổng weight giảm tốc độ
  - Giảm 5% tốc độ/kg, tối đa giảm 50%
- **Giao hàng**: Mang trái cây đến rổ (basket) nhấn E để giao

### 4.3 Hệ thống nâng cấp (Upgrade)
Mở bằng phím **Tab**, sử dụng điểm/xu để nâng cấp:

| Nâng cấp | Giá | Hiệu ứng |
|---|---|---|
| **Túi đồ** | 100 xu (tổng) | +1 slot/level |
| **Tốc độ** | 50 điểm/level | +10% tốc độ/level |
| **Năng lượng** | 200 điểm/level | -10% tiêu hao NL/level |

### 4.4 NPC Chó bảo vệ (Dog Chase)
- **Trạng thái Idle**: Đứng yên tại vị trí cố định
- **Trạng thái Chase**: Kích hoạt khi player vào bán kính 5m
  - Tốc độ: 3m/s, nhanh hơn player đi bộ
  - Cắn: Trong bán kính 1.2m, hút 15 NL/giây
- **Trạng thái Stop**: Khi player thoát bán kính chase → dừng ngay

### 4.5 Sữa Frumi (Milk)
3 loại sữa, hiệu ứng hồi NL **giống nhau**, khác nhau về hình ảnh:
- 🍓 Sữa Dâu (Strawberry)
- 🍇 Sữa Nho (Grape)
- 🍈 Sữa Dưa lưới (Melon)

Spawn ngẫu nhiên khắp map (80 chai), phân bố ở đường đi, nhà cửa, đồi, ngoại ô.

---

## 5. Hệ thống Level

### 5.1 Tổng quan 6 Levels

| Level | Trái cây yêu cầu | Qua màn | 3 sao | Thời gian |
|---|---|---|---|---|
| **1** | 🍎 Táo, 🍌 Chuối | 1 loại | 2 loại | Không giới hạn |
| **2** | 🍊 Cam, 🍋 Chanh, 🍇 Nho | 2 loại | 3 loại + ≤5p | 5 phút |
| **3** | 🍓 Dâu, 🥭 Xoài, 🍈 Dưa lưới | 2 loại | 3 loại + ≤3p | 4 phút |
| **4** | 🍎 Táo, 🍒 Cherry, 🍊 Cam, 🥭 Xoài | 3 loại | 4 loại + ≤3p | 4 phút |
| **5** | 🍌 Chuối, 🍋 Chanh, 🍇 Nho, 🍓 Dâu, 🍈 Dưa lưới | 3 loại | 5 loại + ≤3p | 3.5 phút |
| **6** | Tất cả 7 loại | 4 loại | 7 loại + ≤2.5p | 3 phút |

### 5.2 Hệ thống sao (Star System)
- ⭐ 1 sao: Nhặt đủ số lượng tối thiểu
- ⭐⭐ 2 sao: Nhặt nhiều hơn
- ⭐⭐⭐ 3 sao: Nhặt tất cả + hoàn thành trong thời gian giới hạn

### 5.3 Flow chuyển Level
```
Dialogue (nhận nhiệm vụ) → Gameplay → Đủ điều kiện?
  ├─ Có → Hiện panel chọn: "Màn tiếp theo" hoặc "Ở lại đạt 3 sao"
  └─ Hoàn thành tất cả → Level Complete (hiện sao + thời gian + điểm)
       ├─ Level tiếp theo
       ├─ Chơi lại
       ├─ Chọn level
       └─ Về menu chính
```

---

## 6. Bản đồ & Môi trường

### 6.1 Thế giới nông trại FARM
- **Kích thước**: ~1200m chiều ngang (x: -600 → 600), ~115m chiều sâu (z: 15 → 130)
- **Bản đồ cố định** cho tất cả levels
- **Các khu vực**:
  - Khu trung tâm (nhà cửa, shop Frumi)
  - Khu vườn trái cây (đường đi chính)
  - Khu ngoại ô xa (trái/phải)
  - Đồi cao

### 6.2 Các điểm nổi bật

| Vị trí | Tọa độ (xấp xỉ) | Mô tả |
|---|---|---|
| **Cổng Start** | (0, -135, 91) | Cổng vào bản đồ |
| **Frumi Shop** | (109.6, -134.1, 69.3) | Cửa hàng sữa Frumi |
| **Rổ giao hàng** | (112, -133.2, 74.6) | Nơi giao trái cây |
| **Spawn player** | (112.5, -133.6, 70.7) | Vị trí xuất phát |

### 6.3 Hệ thống ngày/đêm (Day-Night Cycle)
- **Chu kỳ**: 60 giây = 1 ngày đêm
- **Bắt đầu**: 6h sáng
- **Ban đêm**: Đèn đường tự động bật, bầu trời tối dần
- **Hoàng hôn/Bình minh**: Gradient màu cam → tím → xanh

---

## 7. UI/UX Design

### 7.1 Layout HUD trong game

```
┌──────────────────────────────────────────┐
│ Score: 0          │          [MINIMAP]    │
│ [=NĂNG LƯỢNG====] │           (180px)     │
│ Tab để nâng cấp   │            MAP        │
│ ┌─Nhiệm vụ──┐   │           [M] Ẩn      │
│ │ Level 1    │   │                       │
│ │ [ ] Táo    │   │                       │
│ │ [ ] Chuối  │   │                       │
│ └────────────┘   │                       │
│                  │      [E nhặt]         │
│                  │      [Q sữa]          │
│ ┌─────────┐      │              Timer    │
│ │🎒Túi 0/2│      │                       │
│ └─────────┘      │                       │
└──────────────────────────────────────────┘
```

### 7.2 Các màn hình

| Màn hình | Mô tả |
|---|---|
| **Main Menu** | Premium dark theme, floating fruits, 4 nút chính |
| **Character Select** | Chọn pet (Cáo/Rùa) |
| **Level Select** | Chọn level 1-6, hiện sao đã đạt |
| **Dialogue** | Visual Novel style, typing effect, auto advance |
| **Loading** | Màn hình tải scene |
| **Gameplay HUD** | Score, NL, Túi, Nhiệm vụ, Minimap, prompts |
| **Upgrade Menu** | Mở Tab, 3 nút nâng cấp |
| **Pause Menu** | ESC, Continue/Restart/Settings/MainMenu/Quit |
| **Settings** | Brightness, Volume (Master/Music/SFX), Mouse Sensitivity |
| **Level Complete** | Sao, thời gian, điểm, 4 nút điều hướng |
| **Game Over** | Score, Best Score, Restart/Menu/Quit |

### 7.3 Minimap
- **Vị trí**: Góc trên phải, 180x180px
- **Camera**: Orthographic, nhìn từ trên xuống
- **Toggle**: Phím M
- **Icons**: Player (xanh dg), Pet (tím), Basket (vàng), Shop (xanh lục), Fruits (cam), Milk (trắng), Dogs (đỏ)

---

## 8. Các loại vật phẩm

### 8.1 Trái cây (9 loại)

| Trái cây | Tên VN | Chức năng |
|---|---|---|
| 🍎 Apple | Táo | Thu thập nhiệm vụ |
| 🍌 Banana | Chuối | Thu thập nhiệm vụ |
| 🍒 Cherry | Cherry | Thu thập nhiệm vụ |
| 🍇 Grape | Nho | Thu thập nhiệm vụ |
| 🍋 Lemon | Chanh | Thu thập nhiệm vụ |
| 🥭 Mango | Xoài | Thu thập nhiệm vụ |
| 🍈 Melon | Dưa lưới | Thu thập nhiệm vụ |
| 🍊 Orange | Cam | Thu thập nhiệm vụ |
| 🍓 Strawberry | Dâu | Thu thập nhiệm vụ |

### 8.2 Vật phẩm recovery

| Vật phẩm | Hiệu ứng | Spawn |
|---|---|---|
| Sữa Frumi Dâu | Hồi NL | 80 chai ngẫu nhiên |
| Sữa Frumi Nho | Hồi NL | khắp map |
| Sữa Frumi Dưa lưới | Hồi NL | |

---

## 9. Nhân vật NPC

### 9.1 NPC Dialogue
- **Bác Bảo Vệ**: Giao nhiệm vụ, hướng dẫn luật chơi
- **Minh**: Nhân vật hỗ trợ, comment về nhiệm vụ
- **Lan**: Nhân vật hỗ trợ, tạo không khí vui vẻ
- **Hùng**: Nhân vật hỗ trợ, thể hiện quyết tâm

### 9.2 NPC trên map
- **NPC đi lại ngẫu nhiên**: Tạo sự sống động cho bản đồ
- **Chó bảo vệ**: Chướng ngại vật AI

---

## 10. Cảnh báo sức khỏe

Game tích hợp hệ thống cảnh báo thời gian chơi:
- **Sau 180 phút (3 giờ)**: Hiện banner cảnh báo đỏ
  - "⚠️ Cảnh báo: Không chơi game quá 180 phút!"
- Banner tự ẩn sau 10 giây
- Đây là yêu cầu bắt buộc cho đồ án tốt nghiệp

---

## 11. Điều khiển

| Phím | Hành động |
|---|---|
| **W/A/S/D** | Di chuyển |
| **Chuột** | Nhìn xung quanh |
| **E** | Nhặt trái cây / Giao hàng |
| **Q** | Nhặt sữa |
| **Shift** | Chạy nhanh (Sprint) |
| **Tab** | Mở menu nâng cấp |
| **M** | Ẩn/hiện Minimap |
| **ESC** | Pause menu |
| **Space** | Nhảy |

---

## 12. Lưu trữ dữ liệu

Game lưu vào file `user://save_data.cfg`:
- Best score, total coins
- Level hiện tại, sao từng level
- Pet đã chọn
- Tất cả settings (âm lượng, độ sáng, sensitivity, v.v.)