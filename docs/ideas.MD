Mỗi màn là một đoạn hội thoại để nhận nhiệm vụ
Cơ chế game loop: nhặt đồ
Bắt đầu -> nhận nhiệm vụ nhặt vật phẩm rác -> di chuyển mất năng lượng -> nhặt sữa uống -> nhặt được rác -> mang về nơi chứa -> nếu gặp chướng ngại vật là chó và chạm thì bị chó đuổi -> kích hoạt chạy nhanh gấp 1.5 lần  nhưng năng lượng mất gấp đôi. Hoàn thành nhiệm vụ nhặt của 1 level sẽ có điểm để nâng cấp thêm (mở rộng túi đồ, mất năng lượng ít khi di chuyển)
Các loại vật phẩm trong game: túi nilong nhiều màu, chai nhựa, lá  cây
NPC con chó: chạm vào thì bị chó đuổi, phạm vi hoạt động bán kính 50cm, tốc độ nhanh gấp 1,3 lần người chơi và chạy trong bán kính đó, nếu người chơi thoát khỏi bán kính đó thì con chó sẽ chậm lại và đi ngủ
Vật phẩm hồi năng lượng: sữa dâu, nho, dưa lưới

Cơ chế nhiệm vụ màn chơi : 3 level
level 1 : điều kiện nhặt 2 món đồ túi nilong màu vàng + chai nhựa , nhặt đc 1 món qua màn nhưng chỉ có 1 sao
level 2: nhặt 3 món đồ túi nilong màu xanh lá cây + chai nhựa + túi nilong màu đỏ , nhặt 2 món qua màn nhưng chỉ có 1 sao, 3 món 2 sao, 3 nón trong 5 phút thì 3 sao 
level  3: nhặt 3 món đồ trong vòng 3p lá cây, túi nilong màu đỏ + chai nhựa, nếu nhặt đc 1 món trong 3p thì qua màn nhưng 1 sao, 2 món 3p 2 sao, 3 món 3p thì 3 sao
Khi đủ điều kiện qua màn sẽ hiển thị thông báo qua màn tiếp theo, hoặc chơi tiếp để đạt thành tích cao
Hình ảnh vật phẩm cần nhặt sẽ hiển thị xuyên suốt màn chơi góc trên bên phải, khi hoànthành nhặt xong 1 món đồ sẽ check để biết là đã xong
HUD : 
góc trên bên trái : thanh năng lượng ,màu xanh lá, khi năng lượng còn 20% sẽ chuyển thành màu đỏ
góc trên bên phải : nhiệm vụ
