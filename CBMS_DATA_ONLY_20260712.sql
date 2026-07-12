/* ======================================================================
   CBMS FULL DATA EXPORT - generated from local SQL Server on 2026-07-12
   Run after database/schema exists. This refreshes all table data.
   ====================================================================== */
SET NOCOUNT ON;
GO
USE [CBMS];
GO

EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

DELETE FROM [dbo].[Vouchers];
DELETE FROM [dbo].[Users];
DELETE FROM [dbo].[Toppings];
DELETE FROM [dbo].[Sizes];
DELETE FROM [dbo].[Roles];
DELETE FROM [dbo].[Reviews];
DELETE FROM [dbo].[Refunds];
DELETE FROM [dbo].[ProductToppings];
DELETE FROM [dbo].[Products];
DELETE FROM [dbo].[PointTransactions];
DELETE FROM [dbo].[Payments];
DELETE FROM [dbo].[OrderStatusHistory];
DELETE FROM [dbo].[Orders];
DELETE FROM [dbo].[OrderDetailToppings];
DELETE FROM [dbo].[OrderDetails];
DELETE FROM [dbo].[Notifications];
DELETE FROM [dbo].[Deliveries];
DELETE FROM [dbo].[Combos];
DELETE FROM [dbo].[ComboItems];
DELETE FROM [dbo].[Categories];
GO

/* [dbo].[Categories] - 5 rows */
SET IDENTITY_INSERT [dbo].[Categories] ON;
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (1, N'Cà phê', N'Cà phê máy và cà phê phin Việt Nam', NULL);
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (2, N'Trà sữa', N'Trà sữa và thức uống từ sữa', NULL);
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (3, N'Trà trái cây', N'Trà thanh mát kết hợp trái cây', NULL);
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (4, N'Nước ép', N'Nước ép trái cây tươi', NULL);
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (5, N'Đồ ăn nhẹ', N'Bánh và món ăn kèm', NULL);
SET IDENTITY_INSERT [dbo].[Categories] OFF;
GO

/* [dbo].[ComboItems] - 10 rows */
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (1, 1, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (1, 10, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (2, 4, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (2, 5, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (3, 1, 2);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (3, 10, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (4, 6, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (4, 10, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (5, 3, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (5, 8, 1);
GO

/* [dbo].[Combos] - 5 rows */
SET IDENTITY_INSERT [dbo].[Combos] ON;
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (1, N'Combo sáng tỉnh táo', 52000.00, N'combo-sang.png', N'Cà phê sữa đá và Croissant', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (2, N'Combo đôi ngọt ngào', 82000.00, N'combo-doi.png', N'Hai ly trà sữa', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (3, N'Combo văn phòng', 95000.00, N'combo-van-phong.png', N'Đồ uống cho nhóm nhỏ', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (4, N'Combo trà chiều', 65000.00, N'combo-tra-chieu.png', N'Trà trái cây và bánh', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (5, N'Combo năng lượng', 88000.00, N'combo-nang-luong.png', N'Cà phê và nước ép', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
SET IDENTITY_INSERT [dbo].[Combos] OFF;
GO

/* [dbo].[Deliveries] - 5 rows */
SET IDENTITY_INSERT [dbo].[Deliveries] ON;
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (1, 1, 4, N'Delivered', '2026-06-20T09:30:00.0000000', '2026-06-20T09:40:00.0000000', '2026-06-20T10:05:00.0000000', N'Đã giao tận tay');
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (2, 3, NULL, N'Waiting', NULL, NULL, NULL, N'Chờ duyệt đơn');
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (3, 5, 4, N'Delivering', '2026-07-05T10:00:00.0000000', '2026-07-05T10:10:00.0000000', NULL, N'Đang trên đường giao');
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (4, 7, 4, N'Cancelled', '2026-06-26T11:10:00.0000000', NULL, NULL, N'Khách hủy trước khi lấy món');
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (5, 9, 4, N'Failed', '2026-06-28T13:30:00.0000000', '2026-06-28T13:40:00.0000000', NULL, N'Không liên hệ được khách');
SET IDENTITY_INSERT [dbo].[Deliveries] OFF;
GO

/* [dbo].[Notifications] - 8 rows */
SET IDENTITY_INSERT [dbo].[Notifications] ON;
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (1, 6, 1, N'Đơn hàng hoàn thành', N'Đơn #1 đã được giao thành công.', N'Order', 0, '2026-06-20T10:05:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (2, 6, 1, N'Đã cộng điểm', N'Bạn nhận được 70 điểm từ đơn #1.', N'Point', 0, '2026-06-20T10:06:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (3, 7, 2, N'Đơn hàng hoàn thành', N'Đơn #2 đã hoàn thành.', N'Order', NULL, '2026-06-21T10:35:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (4, 8, 3, N'Đã tiếp nhận đơn', N'Đơn #3 đang chờ thu ngân duyệt.', N'Order', 0, '2026-07-05T08:20:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (5, 9, 4, N'Đơn đang pha chế', N'Đơn #4 đang được chuẩn bị.', N'Order', 0, '2026-07-05T09:06:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (6, 10, 5, N'Đơn đang giao', N'Shipper đang giao đơn #5 đến bạn.', N'Order', 0, '2026-07-05T10:10:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (7, 6, NULL, N'Voucher mới', N'Voucher POINT6A đã được thêm vào ví.', N'Voucher', NULL, '2026-06-01T09:00:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (8, 7, NULL, N'Voucher mới', N'Voucher POINT7A đã được thêm vào ví.', N'Voucher', 0, '2026-06-05T09:00:00.0000000');
SET IDENTITY_INSERT [dbo].[Notifications] OFF;
GO

/* [dbo].[OrderDetails] - 15 rows */
SET IDENTITY_INSERT [dbo].[OrderDetails] ON;
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (1, 1, 4, 1, N'L', N'70%', N'70%', 50000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (2, 1, 6, 1, N'M', N'50%', N'70%', 42000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (3, 2, 1, 2, N'M', N'100%', N'100%', 29000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (4, 3, 6, 1, N'M', N'30%', N'70%', 42000.00, N'Ít đá');
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (5, 4, 4, 1, N'L', N'100%', N'100%', 50000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (6, 4, 5, 1, N'M', N'50%', N'70%', 47000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (7, 5, 7, 1, N'L', N'50%', N'50%', 44000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (8, 5, 8, 1, N'M', N'50%', N'100%', 35000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (9, 6, 3, 2, N'L', N'100%', N'100%', 44000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (10, 6, 10, 1, N'M', N'100%', N'100%', 28000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (11, 7, 5, 1, N'M', N'50%', N'50%', 47000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (12, 8, 2, 2, N'M', N'100%', N'100%', 32000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (13, 9, 6, 2, N'M', N'50%', N'70%', 42000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (14, 10, 8, 1, N'M', N'50%', N'100%', 35000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (15, 10, 9, 1, N'M', N'50%', N'100%', 35000.00, NULL);
SET IDENTITY_INSERT [dbo].[OrderDetails] OFF;
GO

/* [dbo].[OrderDetailToppings] - 10 rows */
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (1, 1, 1, 8000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (1, 6, 1, 12000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (2, 4, 1, 7000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (5, 2, 1, 8000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (6, 5, 1, 10000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (7, 7, 1, 7000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (9, 6, 1, 12000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (11, 5, 1, 10000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (13, 3, 2, 6000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (14, 7, 1, 7000.00);
GO

/* [dbo].[Orders] - 10 rows */
SET IDENTITY_INSERT [dbo].[Orders] ON;
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (1, 6, 2, 1, 70000.00, 15000.00, 15000.00, '2026-06-20T09:15:00.0000000', N'Completed', NULL, N'Online', N'Thạch Thất, Hà Nội', N'0909090909', N'QR-Code', N'Gọi trước khi giao');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (2, 7, 2, NULL, 58000.00, 0.00, 0.00, '2026-06-21T10:30:00.0000000', N'Completed', NULL, N'At-Counter', NULL, NULL, N'Cash', NULL);
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (3, 8, NULL, NULL, 42000.00, 0.00, 15000.00, '2026-07-05T08:20:00.0000000', N'Pending', 0, N'Online', N'Nam Từ Liêm, Hà Nội', N'0922113344', N'Cash', N'Ít đá');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (4, 9, 2, 2, 84000.00, 20000.00, 0.00, '2026-07-05T09:05:00.0000000', N'Approved', 0, N'At-Counter', NULL, NULL, N'Cash', NULL);
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (5, 10, 2, NULL, 89000.00, 0.00, 15000.00, '2026-07-05T09:45:00.0000000', N'Approved', 0, N'Online', N'Hà Đông, Hà Nội', N'0888999000', N'QR-Code', NULL);
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (6, 6, 2, 3, 120000.00, 30000.00, 0.00, '2026-06-25T14:10:00.0000000', N'Completed', NULL, N'At-Counter', NULL, NULL, N'Cash', NULL);
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (7, 7, 2, NULL, 47000.00, 0.00, 15000.00, '2026-06-26T11:00:00.0000000', N'Cancelled', 0, N'Online', N'Cầu Giấy, Hà Nội', N'0933221100', N'QR-Code', N'Khách đổi ý');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (8, 8, 2, NULL, 64000.00, 0.00, 0.00, '2026-06-27T16:20:00.0000000', N'Cancelled', 0, N'At-Counter', NULL, NULL, N'Cash', N'Sản phẩm lỗi');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (9, 9, 2, 4, 69000.00, 15000.00, 15000.00, '2026-06-28T13:15:00.0000000', N'Cancelled', 0, N'Online', N'Hoài Đức, Hà Nội', N'0955667788', N'QR-Code', N'Không liên hệ được');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (10, 10, 2, NULL, 70000.00, 0.00, 0.00, '2026-06-29T18:40:00.0000000', N'Cancelled', 0, N'At-Counter', NULL, NULL, N'Bank-Transfer', N'Hoàn theo yêu cầu');
SET IDENTITY_INSERT [dbo].[Orders] OFF;
GO

/* [dbo].[OrderStatusHistory] - 20 rows */
SET IDENTITY_INSERT [dbo].[OrderStatusHistory] ON;
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (1, 1, NULL, N'Pending', 6, '2026-06-20T09:15:00.0000000', N'Khách tạo đơn');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (2, 1, N'Pending', N'Approved', 2, '2026-06-20T09:20:00.0000000', N'Thu ngân duyệt');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (3, 1, N'Approved', N'Approved', 3, '2026-06-20T09:22:00.0000000', N'Bắt đầu pha chế');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (4, 1, N'Approved', N'Approved', 4, '2026-06-20T09:40:00.0000000', N'Nhận đơn giao');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (5, 1, N'Approved', N'Completed', 4, '2026-06-20T10:05:00.0000000', N'Giao thành công');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (6, 2, NULL, N'Approved', 2, '2026-06-21T10:30:00.0000000', N'Đơn tại quầy');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (7, 2, N'Approved', N'Completed', 2, '2026-06-21T10:35:00.0000000', N'Đã giao đồ uống');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (8, 3, NULL, N'Pending', 8, '2026-07-05T08:20:00.0000000', N'Khách tạo đơn');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (9, 4, NULL, N'Approved', 2, '2026-07-05T09:05:00.0000000', N'Đơn tại quầy');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (10, 5, NULL, N'Pending', 10, '2026-07-05T09:45:00.0000000', N'Khách tạo đơn');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (11, 5, N'Pending', N'Approved', 2, '2026-07-05T09:50:00.0000000', N'Đã duyệt');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (12, 5, N'Approved', N'Approved', 3, '2026-07-05T09:52:00.0000000', N'Đang pha chế');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (13, 5, N'Approved', N'Approved', 3, '2026-07-05T10:00:00.0000000', N'Đã pha xong');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (14, 5, N'Approved', N'Approved', 4, '2026-07-05T10:10:00.0000000', N'Đang giao');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (15, 6, NULL, N'Approved', 2, '2026-06-25T14:10:00.0000000', N'Đơn tại quầy');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (16, 6, N'Approved', N'Completed', 2, '2026-06-25T14:20:00.0000000', N'Hoàn thành');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (17, 7, N'Pending', N'Cancelled', 2, '2026-06-26T11:05:00.0000000', N'Khách hủy');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (18, 8, N'Completed', N'Cancelled', 2, '2026-06-27T16:45:00.0000000', N'Đã hoàn tiền');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (19, 9, N'Approved', N'Cancelled', 2, '2026-06-28T14:30:00.0000000', N'Giao thất bại');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (20, 10, N'Completed', N'Cancelled', 1, '2026-06-29T20:00:00.0000000', N'Quản lý duyệt hoàn tiền');
SET IDENTITY_INSERT [dbo].[OrderStatusHistory] OFF;
GO

/* [dbo].[Payments] - 8 rows */
SET IDENTITY_INSERT [dbo].[Payments] ON;
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (1, 1, N'QR-Code', 70000.00, 70000.00, 0.00, N'QR-20260620-001', N'Paid', '2026-06-20T09:17:00.0000000', '2026-06-20T09:16:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (2, 2, N'Cash', 58000.00, 100000.00, 42000.00, NULL, N'Paid', '2026-06-21T10:31:00.0000000', '2026-06-21T10:30:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (3, 4, N'Cash', 84000.00, 100000.00, 16000.00, NULL, N'Paid', '2026-07-05T09:06:00.0000000', '2026-07-05T09:05:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (4, 5, N'QR-Code', 89000.00, 89000.00, 0.00, N'QR-20260705-005', N'Paid', '2026-07-05T09:47:00.0000000', '2026-07-05T09:46:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (5, 6, N'Cash', 120000.00, 150000.00, 30000.00, NULL, N'Paid', '2026-06-25T14:11:00.0000000', '2026-06-25T14:10:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (6, 7, N'QR-Code', 47000.00, 47000.00, 0.00, N'QR-20260626-007', N'Refunded', '2026-06-26T11:02:00.0000000', '2026-06-26T11:01:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (7, 8, N'Cash', 64000.00, 100000.00, 36000.00, NULL, N'Refunded', '2026-06-27T16:21:00.0000000', '2026-06-27T16:20:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (8, 10, N'Bank-Transfer', 70000.00, 70000.00, 0.00, N'BANK-20260629-10', N'Refunded', '2026-06-29T18:42:00.0000000', '2026-06-29T18:41:00.0000000');
SET IDENTITY_INSERT [dbo].[Payments] OFF;
GO

/* [dbo].[PointTransactions] - 8 rows */
SET IDENTITY_INSERT [dbo].[PointTransactions] ON;
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (1, 6, 1, NULL, 70, 2270, N'Earn', N'Cộng điểm đơn #1', '2026-06-20T10:05:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (2, 7, 2, NULL, 58, 1908, N'Earn', N'Cộng điểm đơn #2', '2026-06-21T10:35:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (3, 6, 6, NULL, 120, 2390, N'Earn', N'Cộng điểm đơn #6', '2026-06-25T14:20:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (4, 6, NULL, 6, -1000, 2200, N'Redeem', N'Đổi voucher POINT6A', '2026-06-01T09:00:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (5, 7, NULL, 7, -2000, 1850, N'Redeem', N'Đổi voucher POINT7A', '2026-06-05T09:00:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (6, 8, NULL, NULL, 100, 760, N'Adjust', N'Điểm khuyến mại khai trương', '2026-05-01T08:00:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (7, 9, NULL, NULL, 200, 1200, N'Adjust', N'Điểm sinh nhật', '2026-05-20T08:00:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (8, 10, 10, NULL, -70, 540, N'Refund', N'Thu hồi điểm do hoàn đơn #10', '2026-06-29T20:00:00.0000000');
SET IDENTITY_INSERT [dbo].[PointTransactions] OFF;
GO

/* [dbo].[Products] - 15 rows */
SET IDENTITY_INSERT [dbo].[Products] ON;
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (1, N'Cà phê sữa đá', 1, 29000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652364053.jpg', N'Cà phê đậm vị cùng sữa đặc', NULL, '2026-01-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (2, N'Bạc xỉu', 1, 32000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652376341.jpg', N'Nhiều sữa, nhẹ vị cà phê', NULL, '2026-01-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (3, N'Cappuccino', 1, 39000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652386892.jpg', N'Espresso và bọt sữa mịn', NULL, '2026-01-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (4, N'Trà sữa trân châu đường đen', 2, 45000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652412242.jpg', N'Trà sữa cùng trân châu đường đen', NULL, '2026-01-11T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (5, N'Trà sữa Matcha', 2, 47000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652423318.jpg', N'Matcha Nhật Bản và sữa tươi', NULL, '2026-01-11T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (6, N'Trà đào cam sả', 3, 42000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652475947.jpg', N'Đào, cam và sả thanh mát', NULL, '2026-01-12T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (7, N'Trà vải', 3, 39000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652497062.jpg', N'Trà thơm kết hợp quả vải', NULL, '2026-01-12T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (8, N'Nước ép cam', 4, 35000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652520082.jpg', N'Nước cam ép nguyên chất', NULL, '2026-01-13T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (9, N'Nước ép dưa hấu', 4, 35000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652531970.jpg', N'Dưa hấu tươi mát', NULL, '2026-01-13T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (10, N'Bánh Croissant', 5, 28000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652557130.jpg', N'Bánh sừng bò thơm bơ', NULL, '2026-01-14T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (11, N'Americano', 1, 37000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671139443.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (12, N'Cà phê trứng', 1, 40000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671451182.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (13, N'Caramel Macchiato', 1, 28000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671502225.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (14, N'Espresso', 1, 21000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671533128.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (15, N'Cold Brew', 1, 24000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671575228.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
SET IDENTITY_INSERT [dbo].[Products] OFF;
GO

/* [dbo].[ProductToppings] - 18 rows */
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (1, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (2, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (3, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (4, 1);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (4, 2);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (4, 5);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (4, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (5, 2);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (5, 5);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (5, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (6, 3);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (6, 4);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (6, 7);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (7, 3);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (7, 4);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (7, 7);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (8, 7);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (9, 4);
GO

/* [dbo].[Refunds] - 5 rows */
SET IDENTITY_INSERT [dbo].[Refunds] ON;
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (1, 7, 6, 7, 2, 47000.00, N'Khách đổi ý trước khi giao', N'Completed', '2026-06-26T11:05:00.0000000', '2026-06-26T11:20:00.0000000');
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (2, 8, 7, 8, 2, 64000.00, N'Sản phẩm không đúng yêu cầu', N'Completed', '2026-06-27T16:30:00.0000000', '2026-06-27T16:45:00.0000000');
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (3, 9, NULL, 9, 2, 69000.00, N'Không thể giao hàng', N'Approved', '2026-06-28T14:10:00.0000000', '2026-06-28T14:30:00.0000000');
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (4, 10, 8, 10, 1, 70000.00, N'Khách yêu cầu hoàn tiền', N'Completed', '2026-06-29T19:00:00.0000000', '2026-06-29T20:00:00.0000000');
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (5, 4, 3, 9, NULL, 84000.00, N'Yêu cầu hủy khi đang pha chế', N'Pending', '2026-07-05T09:15:00.0000000', NULL);
SET IDENTITY_INSERT [dbo].[Refunds] OFF;
GO

/* [dbo].[Reviews] - 5 rows */
SET IDENTITY_INSERT [dbo].[Reviews] ON;
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (1, 6, 1, 5, N'Trà sữa ngon, giao nhanh', NULL, '2026-06-20T11:00:00.0000000');
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (2, 6, 2, 4, N'Trà đào thơm và vừa ngọt', NULL, '2026-06-20T11:02:00.0000000');
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (3, 7, 3, 5, N'Cà phê đậm vị', NULL, '2026-06-21T12:00:00.0000000');
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (4, 6, 9, 4, N'Cappuccino ổn, bọt sữa mịn', NULL, '2026-06-25T15:00:00.0000000');
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (5, 6, 10, 5, N'Bánh giòn và thơm bơ', NULL, '2026-06-25T15:02:00.0000000');
SET IDENTITY_INSERT [dbo].[Reviews] OFF;
GO

/* [dbo].[Roles] - 3 rows */
SET IDENTITY_INSERT [dbo].[Roles] ON;
INSERT INTO [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (1, N'Manager', N'Quản lý cửa hàng và báo cáo');
INSERT INTO [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (2, N'Staff', N'Nhân viên thu ngân, pha chế hoặc giao hàng');
INSERT INTO [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (3, N'Customer', N'Khách hàng đặt món và tích điểm');
SET IDENTITY_INSERT [dbo].[Roles] OFF;
GO

/* [dbo].[Sizes] - 3 rows */
SET IDENTITY_INSERT [dbo].[Sizes] ON;
INSERT INTO [dbo].[Sizes] ([size_id], [size_code], [size_name], [price_modifier], [status]) VALUES (1, N'S', N'Nhỏ', -3000.00, NULL);
INSERT INTO [dbo].[Sizes] ([size_id], [size_code], [size_name], [price_modifier], [status]) VALUES (2, N'M', N'Vừa', 0.00, NULL);
INSERT INTO [dbo].[Sizes] ([size_id], [size_code], [size_name], [price_modifier], [status]) VALUES (3, N'L', N'Lớn', 5000.00, NULL);
SET IDENTITY_INSERT [dbo].[Sizes] OFF;
GO

/* [dbo].[Toppings] - 8 rows */
SET IDENTITY_INSERT [dbo].[Toppings] ON;
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (1, N'Trân châu đen', 8000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (2, N'Trân châu trắng', 8000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (3, N'Thạch sương sáo', 6000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (4, N'Thạch trái cây', 7000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (5, N'Pudding trứng', 10000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (6, N'Kem cheese', 12000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (7, N'Nha đam', 7000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (8, N'Hạt thủy tinh', 9000.00, 0);
SET IDENTITY_INSERT [dbo].[Toppings] OFF;
GO

/* [dbo].[Users] - 10 rows */
SET IDENTITY_INSERT [dbo].[Users] ON;
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (1, N'admin01', N'123456', N'Nguyễn Quản Lý', N'admin@cbms.com', N'0912345678', N'Hà Nội', N'Nam', N'Manager', N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/avatars/uploads/avatar-1-1783753731072.jpg', NULL, 0, 1, '2026-01-02T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (2, N'cashier01', N'123456', N'Lê Thu Ngân', N'cashier@cbms.com', N'0987654321', N'Hà Nội', N'Nữ', N'Thu ngân', N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/avatars/uploads/avatar-2-1783656457343.jpg', NULL, 0, 2, '2026-01-05T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (3, N'barista01', N'123456', N'Trần Pha Chế', N'barista@cbms.com', N'0944556677', N'Hà Nội', N'Nam', N'Pha chế', NULL, NULL, 0, 2, '2026-01-06T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (4, N'shipper01', N'123456', N'Phạm Giao Hàng', N'shipper@cbms.com', N'0966112233', N'Hà Nội', N'Nam', N'Giao hàng', NULL, NULL, 0, 2, '2026-01-07T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (5, N'staff02', N'123456', N'Vũ Nhân Viên Nghỉ', N'staff02@cbms.com', N'0977001122', N'Hà Nội', N'Khác', N'Nhân viên', NULL, 0, 0, 2, '2026-01-08T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (6, N'customer01', N'123456', N'Phan Khách Hàng Online', N'customer01@gmail.com', N'0909090909', N'Thạch Thất', N'Nam', NULL, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/avatars/uploads/avatar-6-1783742549197.jpg', NULL, 2390, 3, '2026-02-01T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (7, N'customer02', N'123456', N'Hoàng Minh Anh', N'customer02@gmail.com', N'0933221100', N'Cầu Giấy', N'Nữ', NULL, NULL, NULL, 1908, 3, '2026-02-05T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (8, N'customer03', N'123456', N'Đỗ Hải Nam', N'customer03@gmail.com', N'0922113344', N'Nam Từ Liêm', N'Nam', NULL, NULL, NULL, 760, 3, '2026-02-10T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (9, N'customer04', N'123456', N'Bùi Thanh Hà', N'customer04@gmail.com', N'0955667788', N'Hoài Đức', N'Nữ', NULL, NULL, NULL, 1200, 3, '2026-03-01T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (10, N'customer05', N'123456', N'Ngô Gia Bảo', N'customer05@gmail.com', N'0888999000', N'Hà Đông', N'Khác', NULL, NULL, NULL, 540, 3, '2026-03-12T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
SET IDENTITY_INSERT [dbo].[Users] OFF;
GO

/* [dbo].[Vouchers] - 8 rows */
SET IDENTITY_INSERT [dbo].[Vouchers] ON;
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (1, N'WELCOME15', 15000.00, 40000.00, 0, '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (2, N'GIAM20K', 20000.00, 60000.00, 0, '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (3, N'GIAM30K', 30000.00, 100000.00, 0, '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (4, N'FREESHIP', 15000.00, 80000.00, 0, '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (5, N'EXPIRED10', 10000.00, 30000.00, 0, '2026-01-01T00:00:00.0000000', '2026-05-01T00:00:00.0000000', 0, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (6, N'POINT6A', 20000.00, 50000.00, 1000, '2026-06-01T00:00:00.0000000', '2027-06-01T00:00:00.0000000', NULL, 6, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (7, N'POINT7A', 30000.00, 70000.00, 2000, '2026-06-05T00:00:00.0000000', '2027-06-05T00:00:00.0000000', NULL, 7, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (8, N'USED6A', 20000.00, 50000.00, 1000, '2026-05-01T00:00:00.0000000', '2027-05-01T00:00:00.0000000', 0, 6, '2026-06-20T10:00:00.0000000', '2026-07-12T19:55:45.0000000');
SET IDENTITY_INSERT [dbo].[Vouchers] OFF;
GO

EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
GO
SET NOCOUNT OFF;
GO

/* Run after data import so image paths are shareable across machines. */
/* ======================================================================
   IMAGE URL ONLINE FIX 2026-07-12
   Äá»•i Ä‘Æ°á»ng dáº«n áº£nh local trong database sang raw GitHub URL Ä‘á»ƒ mÃ¡y khÃ¡c váº«n hiá»ƒn thá»‹ áº£nh.
   LÆ°u Ã½: cÃ¡c file áº£nh trong web/images pháº£i Ä‘Æ°á»£c commit vÃ  push lÃªn GitHub trÆ°á»›c.
   ====================================================================== */
DECLARE @ImageBase VARCHAR(255) = 'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web';

UPDATE dbo.Products
SET image_url = CASE
    WHEN image_url LIKE '/images/products/%' THEN @ImageBase + image_url
    WHEN image_url LIKE 'images/products/%' THEN @ImageBase + '/' + image_url
    WHEN image_url LIKE '/uploads/products/%' THEN @ImageBase + '/images/products' + image_url
    WHEN image_url LIKE 'uploads/products/%' THEN @ImageBase + '/images/products/' + image_url
    ELSE image_url
END
WHERE image_url IS NOT NULL
  AND image_url <> ''
  AND image_url NOT LIKE 'http://%'
  AND image_url NOT LIKE 'https://%';

UPDATE dbo.Users
SET avatar_url = CASE
    WHEN avatar_url LIKE '/images/avatars/%' THEN @ImageBase + avatar_url
    WHEN avatar_url LIKE 'images/avatars/%' THEN @ImageBase + '/' + avatar_url
    WHEN avatar_url LIKE '/uploads/avatars/%' THEN @ImageBase + '/images/avatars' + avatar_url
    WHEN avatar_url LIKE 'uploads/avatars/%' THEN @ImageBase + '/images/avatars/' + avatar_url
    ELSE avatar_url
END
WHERE avatar_url IS NOT NULL
  AND avatar_url <> ''
  AND avatar_url NOT LIKE 'http://%'
  AND avatar_url NOT LIKE 'https://%';
GO

