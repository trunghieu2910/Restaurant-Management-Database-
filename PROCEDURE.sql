USE NHA_HANG;
GO

------------------------------------------------------------------------------
-- Unified stored procedures file (fixed)
-- - Replaced incorrect "OUTPUT ... INTO @Scalar" with table variables @Out
-- - Created procedures in safe order (dependencies first)
------------------------------------------------------------------------------

/*******************************
  sp_RegisterCustomer (dependency for reservations/online book)
*******************************/
IF OBJECT_ID('dbo.sp_RegisterCustomer','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegisterCustomer;
GO
CREATE PROCEDURE dbo.sp_RegisterCustomer
    @FullName NVARCHAR(100),
    @Phone NVARCHAR(15),
    @Email NVARCHAR(100) = NULL,
    @NewCustomerID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.Customers WHERE Phone = @Phone)
        BEGIN
            SELECT @NewCustomerID = CustomerID FROM dbo.Customers WHERE Phone = @Phone;
            SELECT @NewCustomerID AS CustomerID;
            RETURN;
        END

        DECLARE @Out TABLE (CustomerID INT);

        INSERT INTO dbo.Customers (FullName, Phone, Email)
        OUTPUT INSERTED.CustomerID INTO @Out(CustomerID)
        VALUES (@FullName, @Phone, @Email);

        SELECT TOP 1 @NewCustomerID = CustomerID FROM @Out ORDER BY CustomerID DESC;
        SELECT @NewCustomerID AS CustomerID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_RegisterAccount (wrapper)
*******************************/
IF OBJECT_ID('dbo.sp_RegisterAccount','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegisterAccount;
GO
CREATE PROCEDURE dbo.sp_RegisterAccount
    @FullName NVARCHAR(100),
    @Phone NVARCHAR(15),
    @Email NVARCHAR(100) = NULL,
    @NewCustomerID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC dbo.sp_RegisterCustomer @FullName, @Phone, @Email, @NewCustomerID OUTPUT;
        SELECT @NewCustomerID AS CustomerID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_AddEmployee
*******************************/
IF OBJECT_ID('dbo.sp_AddEmployee','P') IS NOT NULL DROP PROCEDURE dbo.sp_AddEmployee;
GO
CREATE PROCEDURE dbo.sp_AddEmployee
    @FullName NVARCHAR(100),
    @Role NVARCHAR(50),
    @HireDate DATE = NULL,
    @Salary DECIMAL(10,2) = NULL,
    @NewEmployeeID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Out TABLE (EmployeeID INT);

        INSERT INTO dbo.Employees (FullName, Role, HireDate, Salary)
        OUTPUT INSERTED.EmployeeID INTO @Out(EmployeeID)
        VALUES (@FullName, @Role, @HireDate, @Salary);

        SELECT TOP 1 @NewEmployeeID = EmployeeID FROM @Out ORDER BY EmployeeID DESC;
        SELECT @NewEmployeeID AS NewEmployeeID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_UpdateEmployee
*******************************/
IF OBJECT_ID('dbo.sp_UpdateEmployee','P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateEmployee;
GO
CREATE PROCEDURE dbo.sp_UpdateEmployee
    @EmployeeID INT,
    @FullName NVARCHAR(100) = NULL,
    @Role NVARCHAR(50) = NULL,
    @HireDate DATE = NULL,
    @Salary DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Employees
        SET FullName = COALESCE(@FullName, FullName),
            Role = COALESCE(@Role, Role),
            HireDate = COALESCE(@HireDate, HireDate),
            Salary = COALESCE(@Salary, Salary)
        WHERE EmployeeID = @EmployeeID;

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_AddMenuItem
*******************************/
IF OBJECT_ID('dbo.sp_AddMenuItem','P') IS NOT NULL DROP PROCEDURE dbo.sp_AddMenuItem;
GO
CREATE PROCEDURE dbo.sp_AddMenuItem
    @ItemName NVARCHAR(100),
    @Category NVARCHAR(50) = NULL,
    @Price DECIMAL(10,2),
    @IsAvailable BIT = 1,
    @NewItemID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Out TABLE (ItemID INT);

        INSERT INTO dbo.MenuItems (ItemName, Category, Price, IsAvailable)
        OUTPUT INSERTED.ItemID INTO @Out(ItemID)
        VALUES (@ItemName, @Category, @Price, @IsAvailable);

        SELECT TOP 1 @NewItemID = ItemID FROM @Out ORDER BY ItemID DESC;
        SELECT @NewItemID AS NewItemID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_UpdateMenuItem
*******************************/
IF OBJECT_ID('dbo.sp_UpdateMenuItem','P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateMenuItem;
GO
CREATE PROCEDURE dbo.sp_UpdateMenuItem
    @ItemID INT,
    @ItemName NVARCHAR(100) = NULL,
    @Category NVARCHAR(50) = NULL,
    @Price DECIMAL(10,2) = NULL,
    @IsAvailable BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.MenuItems
        SET ItemName = COALESCE(@ItemName, ItemName),
            Category = COALESCE(@Category, Category),
            Price = COALESCE(@Price, Price),
            IsAvailable = COALESCE(@IsAvailable, IsAvailable)
        WHERE ItemID = @ItemID;

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_AddTable
*******************************/
IF OBJECT_ID('dbo.sp_AddTable','P') IS NOT NULL DROP PROCEDURE dbo.sp_AddTable;
GO
CREATE PROCEDURE dbo.sp_AddTable
    @TableNumber INT,
    @Capacity INT,
    @Location NVARCHAR(50) = NULL,
    @NewTableID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Out TABLE (TableID INT);

        INSERT INTO dbo.Tables (TableNumber, Capacity, Location)
        OUTPUT INSERTED.TableID INTO @Out(TableID)
        VALUES (@TableNumber, @Capacity, @Location);

        SELECT TOP 1 @NewTableID = TableID FROM @Out ORDER BY TableID DESC;
        SELECT @NewTableID AS NewTableID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_UpdateTable
*******************************/
IF OBJECT_ID('dbo.sp_UpdateTable','P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateTable;
GO
CREATE PROCEDURE dbo.sp_UpdateTable
    @TableID INT,
    @TableNumber INT = NULL,
    @Capacity INT = NULL,
    @Location NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Tables
        SET TableNumber = COALESCE(@TableNumber, TableNumber),
            Capacity = COALESCE(@Capacity, Capacity),
            Location = COALESCE(@Location, Location)
        WHERE TableID = @TableID;

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_DeleteTable
*******************************/
IF OBJECT_ID('dbo.sp_DeleteTable','P') IS NOT NULL DROP PROCEDURE dbo.sp_DeleteTable;
GO
CREATE PROCEDURE dbo.sp_DeleteTable
    @TableID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.Tables WHERE TableID = @TableID;
        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_RevenueReport
*******************************/
IF OBJECT_ID('dbo.sp_RevenueReport','P') IS NOT NULL DROP PROCEDURE dbo.sp_RevenueReport;
GO
CREATE PROCEDURE dbo.sp_RevenueReport
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            SUM(o.TotalAmount) AS TotalRevenue,
            COUNT(o.OrderID) AS OrdersCount
        FROM dbo.Orders o
        WHERE o.PaymentTime BETWEEN @FromDate AND @ToDate
          AND o.Status = 'Completed';

        SELECT CONVERT(DATE, o.PaymentTime) AS SaleDate, 
               SUM(o.TotalAmount) AS Revenue,
               COUNT(o.OrderID) AS OrdersCount
        FROM dbo.Orders o
        WHERE o.PaymentTime BETWEEN @FromDate AND @ToDate
          AND o.Status = 'Completed'
        GROUP BY CONVERT(DATE, o.PaymentTime)
        ORDER BY SaleDate;

        SELECT TOP 10 mi.ItemID, mi.ItemName, SUM(od.Quantity) AS TotalQty, SUM(od.Quantity * od.Price) AS TotalSales
        FROM dbo.OrderDetails od
        JOIN dbo.Orders o ON od.OrderID = o.OrderID
        JOIN dbo.MenuItems mi ON od.ItemID = mi.ItemID
        WHERE o.PaymentTime BETWEEN @FromDate AND @ToDate
          AND o.Status = 'Completed'
        GROUP BY mi.ItemID, mi.ItemName
        ORDER BY TotalQty DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_EmployeePerformance
*******************************/
IF OBJECT_ID('dbo.sp_EmployeePerformance','P') IS NOT NULL DROP PROCEDURE dbo.sp_EmployeePerformance;
GO
CREATE PROCEDURE dbo.sp_EmployeePerformance
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT e.EmployeeID, e.FullName, e.Role,
               COUNT(DISTINCT o.OrderID) AS OrdersServed,
               SUM(ISNULL(o.TotalAmount,0)) AS TotalSales
        FROM dbo.Employees e
        LEFT JOIN dbo.Orders o ON e.EmployeeID = o.EmployeeID
            AND o.OrderTime BETWEEN @FromDate AND @ToDate
        GROUP BY e.EmployeeID, e.FullName, e.Role
        ORDER BY TotalSales DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_CreateReservation
  (uses sp_RegisterCustomer if needed)
*******************************/
IF OBJECT_ID('dbo.sp_CreateReservation','P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateReservation;
GO
CREATE PROCEDURE dbo.sp_CreateReservation
    @CustomerID INT = NULL,
    @CustomerName NVARCHAR(100) = NULL,
    @Phone NVARCHAR(15) = NULL,
    @ReservationTime DATETIME,
    @GuestCount INT,
    @Notes NVARCHAR(200) = NULL,
    @ReservationID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        IF @CustomerID IS NULL
        BEGIN
            IF @Phone IS NULL
            BEGIN
                RAISERROR('Phone required when no CustomerID supplied',16,1); ROLLBACK TRAN; RETURN;
            END

            IF EXISTS (SELECT 1 FROM dbo.Customers WHERE Phone = @Phone)
                SELECT @CustomerID = CustomerID FROM dbo.Customers WHERE Phone = @Phone;
            ELSE
            BEGIN
                DECLARE @tmpCust INT;
                EXEC dbo.sp_RegisterCustomer @CustomerName, @Phone, NULL, @tmpCust OUTPUT;
                SET @CustomerID = @tmpCust;
            END
        END

        DECLARE @Out TABLE (ReservationID INT);

        INSERT INTO dbo.Reservations (CustomerID, ReservationTime, GuestCount, Status, Notes)
        OUTPUT INSERTED.ReservationID INTO @Out(ReservationID)
        VALUES (@CustomerID, @ReservationTime, @GuestCount, 'Pending', @Notes);

        SELECT TOP 1 @ReservationID = ReservationID FROM @Out ORDER BY ReservationID DESC;

        COMMIT;
        SELECT @ReservationID AS ReservationID;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

/*******************************
  sp_OnlineBook
*******************************/
IF OBJECT_ID('dbo.sp_OnlineBook','P') IS NOT NULL DROP PROCEDURE dbo.sp_OnlineBook;
GO
CREATE PROCEDURE dbo.sp_OnlineBook
    @Phone NVARCHAR(15),
    @CustomerName NVARCHAR(100),
    @ReservationTime DATETIME,
    @GuestCount INT,
    @Notes NVARCHAR(200) = NULL,
    @ReservationID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @custId INT;

        IF EXISTS (SELECT 1 FROM dbo.Customers WHERE Phone = @Phone)
            SELECT @custId = CustomerID FROM dbo.Customers WHERE Phone = @Phone;
        ELSE
        BEGIN
            EXEC dbo.sp_RegisterCustomer @CustomerName, @Phone, NULL, @custId OUTPUT;
        END

        DECLARE @Out TABLE (ReservationID INT);

        INSERT INTO dbo.Reservations (CustomerID, ReservationTime, GuestCount, Status, Notes)
        OUTPUT INSERTED.ReservationID INTO @Out(ReservationID)
        VALUES (@custId, @ReservationTime, @GuestCount, 'Confirmed', @Notes);

        SELECT TOP 1 @ReservationID = ReservationID FROM @Out ORDER BY ReservationID DESC;
        SELECT @ReservationID AS ReservationID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_ConfirmArrival
*******************************/
IF OBJECT_ID('dbo.sp_ConfirmArrival','P') IS NOT NULL DROP PROCEDURE dbo.sp_ConfirmArrival;
GO
CREATE PROCEDURE dbo.sp_ConfirmArrival
    @ReservationID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Reservations
        SET Status = 'Arrived'
        WHERE ReservationID = @ReservationID;

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_AssignTableToReservation
*******************************/
IF OBJECT_ID('dbo.sp_AssignTableToReservation','P') IS NOT NULL DROP PROCEDURE dbo.sp_AssignTableToReservation;
GO
CREATE PROCEDURE dbo.sp_AssignTableToReservation
    @ReservationID INT,
    @TableID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.ReservationTables (ReservationID, TableID)
        VALUES (@ReservationID, @TableID);

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_OpenOrder
*******************************/
IF OBJECT_ID('dbo.sp_OpenOrder','P') IS NOT NULL DROP PROCEDURE dbo.sp_OpenOrder;
GO
CREATE PROCEDURE dbo.sp_OpenOrder
    @CustomerID INT,
    @EmployeeID INT,
    @ReservationID INT = NULL,
    @NewOrderID INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Out TABLE (OrderID INT);

        INSERT INTO dbo.Orders (CustomerID, EmployeeID, ReservationID)
        OUTPUT INSERTED.OrderID INTO @Out(OrderID)
        VALUES (@CustomerID, @EmployeeID, @ReservationID);

        SELECT TOP 1 @NewOrderID = OrderID FROM @Out ORDER BY OrderID DESC;
        SELECT @NewOrderID AS OrderID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_AddItemToOrder
*******************************/
IF OBJECT_ID('dbo.sp_AddItemToOrder','P') IS NOT NULL DROP PROCEDURE dbo.sp_AddItemToOrder;
GO
CREATE PROCEDURE dbo.sp_AddItemToOrder
    @OrderID INT,
    @ItemID INT,
    @Quantity INT,
    @Price DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @unitPrice DECIMAL(10,2);
        IF @Price IS NULL
        BEGIN
            SELECT @unitPrice = Price FROM dbo.MenuItems WHERE ItemID = @ItemID;
            IF @unitPrice IS NULL
                RAISERROR('Menu item not found',16,1);
        END
        ELSE SET @unitPrice = @Price;

        INSERT INTO dbo.OrderDetails (OrderID, ItemID, Quantity, Price)
        VALUES (@OrderID, @ItemID, @Quantity, @unitPrice);

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_UpdateOrderDetail
  sp_DeleteOrderDetail
*******************************/
IF OBJECT_ID('dbo.sp_UpdateOrderDetail','P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateOrderDetail;
GO
CREATE PROCEDURE dbo.sp_UpdateOrderDetail
    @OrderID INT,
    @ItemID INT,
    @Quantity INT = NULL,
    @Price DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.OrderDetails
        SET Quantity = COALESCE(@Quantity, Quantity),
            Price = COALESCE(@Price, Price)
        WHERE OrderID = @OrderID AND ItemID = @ItemID;

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sp_DeleteOrderDetail','P') IS NOT NULL DROP PROCEDURE dbo.sp_DeleteOrderDetail;
GO
CREATE PROCEDURE dbo.sp_DeleteOrderDetail
    @OrderID INT,
    @ItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.OrderDetails WHERE OrderID = @OrderID AND ItemID = @ItemID;
        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_ViewOrder
*******************************/
IF OBJECT_ID('dbo.sp_ViewOrder','P') IS NOT NULL DROP PROCEDURE dbo.sp_ViewOrder;
GO
CREATE PROCEDURE dbo.sp_ViewOrder
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT o.OrderID, o.OrderTime, o.Status, o.PaymentTime, o.PaymentMethod, o.TotalAmount,
               c.CustomerID, c.FullName AS CustomerName, e.EmployeeID, e.FullName AS EmployeeName, o.ReservationID
        FROM dbo.Orders o
        LEFT JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
        LEFT JOIN dbo.Employees e ON o.EmployeeID = e.EmployeeID
        WHERE o.OrderID = @OrderID;

        SELECT od.OrderID, od.ItemID, mi.ItemName, od.Quantity, od.Price, od.Quantity * od.Price AS LineTotal
        FROM dbo.OrderDetails od
        LEFT JOIN dbo.MenuItems mi ON od.ItemID = mi.ItemID
        WHERE od.OrderID = @OrderID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_PayOrder
*******************************/
IF OBJECT_ID('dbo.sp_PayOrder','P') IS NOT NULL DROP PROCEDURE dbo.sp_PayOrder;
GO
CREATE PROCEDURE dbo.sp_PayOrder
    @OrderID INT,
    @PaymentMethod NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Orders
        SET PaymentTime = SYSUTCDATETIME(), PaymentMethod = @PaymentMethod
        WHERE OrderID = @OrderID;

        SELECT OrderID, Status, PaymentTime, PaymentMethod, TotalAmount FROM dbo.Orders WHERE OrderID = @OrderID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_CancelOrder
*******************************/
IF OBJECT_ID('dbo.sp_CancelOrder','P') IS NOT NULL DROP PROCEDURE dbo.sp_CancelOrder;
GO
CREATE PROCEDURE dbo.sp_CancelOrder
    @OrderID INT,
    @Reason NVARCHAR(400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Orders SET Status = 'Cancelled' WHERE OrderID = @OrderID;

        INSERT INTO dbo.AuditLog (TableName, Action, KeyInfo, Details)
        VALUES ('Orders', 'CancelOrder', CAST(@OrderID AS NVARCHAR(50)), ISNULL(@Reason,'Cancelled by user'));

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_ShiftReport
*******************************/
IF OBJECT_ID('dbo.sp_ShiftReport','P') IS NOT NULL DROP PROCEDURE dbo.sp_ShiftReport;
GO
CREATE PROCEDURE dbo.sp_ShiftReport
    @EmployeeID INT,
    @FromTime DATETIME,
    @ToTime DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT @EmployeeID AS EmployeeID,
               COUNT(o.OrderID) AS OrdersHandled,
               SUM(ISNULL(o.TotalAmount,0)) AS RevenueCollected,
               SUM(CASE WHEN o.Status = 'Open' THEN 1 ELSE 0 END) AS OpenOrders,
               SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders
        FROM dbo.Orders o
        WHERE o.EmployeeID = @EmployeeID
          AND o.OrderTime BETWEEN @FromTime AND @ToTime;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_PendingKitchenItems
*******************************/
IF OBJECT_ID('dbo.sp_PendingKitchenItems','P') IS NOT NULL DROP PROCEDURE dbo.sp_PendingKitchenItems;
GO
CREATE PROCEDURE dbo.sp_PendingKitchenItems
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT o.OrderID, od.ItemID, mi.ItemName, od.Quantity, od.Price, o.OrderTime, o.Status
        FROM dbo.OrderDetails od
        JOIN dbo.Orders o ON od.OrderID = o.OrderID
        JOIN dbo.MenuItems mi ON od.ItemID = mi.ItemID
        WHERE o.Status = 'Open' AND mi.Category IS NOT NULL
        ORDER BY o.OrderTime;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_MarkItemUnavailable
*******************************/
IF OBJECT_ID('dbo.sp_MarkItemUnavailable','P') IS NOT NULL DROP PROCEDURE dbo.sp_MarkItemUnavailable;
GO
CREATE PROCEDURE dbo.sp_MarkItemUnavailable
    @ItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.MenuItems SET IsAvailable = 0 WHERE ItemID = @ItemID;
        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/*******************************
  sp_ViewCustomerHistory
*******************************/
IF OBJECT_ID('dbo.sp_ViewCustomerHistory','P') IS NOT NULL DROP PROCEDURE dbo.sp_ViewCustomerHistory;
GO
CREATE PROCEDURE dbo.sp_ViewCustomerHistory
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT r.ReservationID, r.ReservationTime, r.GuestCount, r.Status, r.Notes
        FROM dbo.Reservations r
        WHERE r.CustomerID = @CustomerID
        ORDER BY r.ReservationTime DESC;

        SELECT o.OrderID, o.OrderTime, o.Status, o.TotalAmount, o.PaymentTime, o.PaymentMethod
        FROM dbo.Orders o
        WHERE o.CustomerID = @CustomerID
        ORDER BY o.OrderTime DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

PRINT 'Unified procedures created/updated successfully.';
GO
