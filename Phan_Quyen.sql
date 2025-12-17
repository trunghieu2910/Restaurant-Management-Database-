USE NHA_HANG 
GO 

CREATE LOGIN hieu
WITH PASSWORD = '123';

CREATE USER hieunt
FOR LOGIN hieu;


/* Thêm user vào vai trò đọc dữ liệu */
ALTER ROLE db_datareader ADD MEMBER hieunt;

/* Thêm user vào vai trò ghi/sửa/xóa dữ liệu */
ALTER ROLE db_datawriter ADD MEMBER hieunt; 
/*=====================================================================================================================================*/

-- ĐẦU BẾP  
CREATE LOGIN chef 
WITH PASSWORD = 'chef123';

CREATE USER chef
FOR LOGIN chef;
--GRANT EXECUTE ON [Tên_Hàm_Hoặc_Stored_Procedure] TO [Tên_Tài_Khoản_Hoặc_Role];
GRANT EXECUTE ON sp_PendingKitchenItems  TO chef;
GRANT EXECUTE ON sp_MarkItemUnavailable  TO chef;

-- quản lí 
CREATE LOGIN manager 
WITH PASSWORD = 'manage123';

CREATE USER manager
FOR LOGIN manager;



-- 1. Nhân viên
GRANT EXECUTE ON OBJECT::dbo.sp_AddEmployee TO manager;
GRANT EXECUTE ON OBJECT::dbo.sp_UpdateEmployee TO manager;

-- 2. Thực đơn
GRANT EXECUTE ON OBJECT::dbo.sp_AddMenuItem TO manager;
GRANT EXECUTE ON OBJECT::dbo.sp_UpdateMenuItem TO manager;

-- 3. Bàn ăn
GRANT EXECUTE ON OBJECT::dbo.sp_AddTable TO manager;
GRANT EXECUTE ON OBJECT::dbo.sp_UpdateTable TO manager;
GRANT EXECUTE ON OBJECT::dbo.sp_DeleteTable TO manager;

-- 4. Báo cáo
GRANT EXECUTE ON OBJECT::dbo.sp_RevenueReport TO manager;
GRANT EXECUTE ON OBJECT::dbo.sp_EmployeePerformance TO manager;
GRANT EXECUTE ON OBJECT::dbo.sp_ShiftReport TO manager;

-- 5. Quản lý khách hàng / đơn hàng
GRANT EXECUTE ON OBJECT::dbo.sp_ViewCustomerHistory TO manager;
GRANT EXECUTE ON OBJECT::dbo.sp_CancelOrder TO manager;
GO

--LỄ TÂN 
CREATE LOGIN  letan
WITH PASSWORD = 'letan123';

CREATE USER letan
FOR LOGIN letan;



-- 1. Đăng ký khách hàng
GRANT EXECUTE ON OBJECT::dbo.sp_RegisterAccount TO letan;

-- 2. Tạo đặt bàn
GRANT EXECUTE ON OBJECT::dbo.sp_CreateReservation TO letan;

-- 3. Xác nhận khách đến
GRANT EXECUTE ON OBJECT::dbo.sp_ConfirmArrival TO letan;

-- 4. Gán bàn cho khách
GRANT EXECUTE ON OBJECT::dbo.sp_AssignTableToReservation TO letan;

-- 5. Mở đơn hàng
GRANT EXECUTE ON OBJECT::dbo.sp_OpenOrder TO letan;

-- 6. Xem chi tiết hóa đơn
GRANT EXECUTE ON OBJECT::dbo.sp_ViewOrder TO letan;

-- 7. Xem lịch sử khách hàng
GRANT EXECUTE ON OBJECT::dbo.sp_ViewCustomerHistory TO letan;

-- 8. (Tuỳ chọn) Đặt bàn online
GRANT EXECUTE ON OBJECT::dbo.sp_OnlineBook TO letan;
GO


-- THU NGÂN 
CREATE LOGIN thungan
WITH PASSWORD = 'thungan123';

CREATE USER thungan
FOR LOGIN thungan;

USE NHA_HANG;
GO

-- 1. Hóa đơn / đơn hàng
GRANT EXECUTE ON OBJECT::dbo.sp_ViewOrder TO thungan;
GRANT EXECUTE ON OBJECT::dbo.sp_PayOrder TO thungan;
GRANT EXECUTE ON OBJECT::dbo.sp_CancelOrder TO thungan;

-- 2. Báo cáo doanh thu / ca làm việc
GRANT EXECUTE ON OBJECT::dbo.sp_RevenueReport TO thungan;
GRANT EXECUTE ON OBJECT::dbo.sp_ShiftReport TO thungan;
GO

GRANT SELECT ON dbo.Orders TO thungan;
GRANT SELECT ON dbo.OrderDetails TO thungan;
GRANT SELECT ON dbo.MenuItems TO thungan;
GRANT SELECT ON dbo.Customers TO thungan;
GRANT SELECT ON dbo.Employees TO thungan;
GRANT SELECT ON dbo.Reservations TO thungan;

-- KHÁCH HÀNG 
CREATE LOGIN khachhang 
WITH PASSWORD = 'khachhang123';

CREATE USER khachhang 
FOR LOGIN khachhang ;


-- 1. Đăng ký tài khoản
GRANT EXECUTE ON OBJECT::dbo.sp_RegisterAccount TO khachhang;

-- 2. Đặt bàn online
GRANT EXECUTE ON OBJECT::dbo.sp_OnlineBook TO khachhang;

-- 3. Xem lịch sử của bản thân
GRANT EXECUTE ON OBJECT::dbo.sp_ViewCustomerHistory TO khachhang;
GO


/*=================================================================================================================================================*/






-- cấp quyền cho Nam 
GRANT EXECUTE ON [dbo].[sp_GetCustomerHistory] TO [Nam];
GRANT EXECUTE ON [dbo].[sp_CustomerCreateReservation] TO [Nam];
GRANT EXECUTE ON [dbo].[sp_RegisterCustomer] TO [Nam];



