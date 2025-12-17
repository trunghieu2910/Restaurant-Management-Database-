USE NHA_HANG;
GO
-- Test file for Manager role (manager)
-- Replace 'manager' with actual username if different.
PRINT '--- MANAGER TEST (manager) ---';
BEGIN TRY
    EXECUTE AS USER = 'manager';

    PRINT '>>> sp_AddEmployee';
    DECLARE @newEmp INT;
    EXEC dbo.sp_AddEmployee 
        @FullName = N'Test Manager NV',
        @Role = N'Waiter',
        @HireDate = '2025-11-01',
        @Salary = 6000000,
        @NewEmployeeID = @newEmp OUTPUT;
    PRINT 'New EmployeeID = ' + ISNULL(CAST(@newEmp AS NVARCHAR(20)),'NULL');

    PRINT '>>> sp_UpdateEmployee (change salary)';
    IF @newEmp IS NOT NULL
        EXEC dbo.sp_UpdateEmployee @EmployeeID = @newEmp, @Salary = 6500000;

    PRINT '>>> sp_AddMenuItem';
    DECLARE @newItem INT;
    EXEC dbo.sp_AddMenuItem 
        @ItemName = N'Test Dish Manager',
        @Category = N'Food',
        @Price = 99000,
        @IsAvailable = 1,
        @NewItemID = @newItem OUTPUT;
    PRINT 'New ItemID = ' + ISNULL(CAST(@newItem AS NVARCHAR(20)),'NULL');

    PRINT '>>> sp_RevenueReport (sample period)';
    EXEC dbo.sp_RevenueReport @FromDate='2025-01-01', @ToDate='2025-12-31';

    PRINT '>>> sp_CancelOrder (sample) - will succeed only if order exists';
    DECLARE @sampleOrder INT;
    SELECT TOP 1 @sampleOrder = OrderID FROM dbo.Orders;
    IF @sampleOrder IS NOT NULL
    BEGIN
        EXEC dbo.sp_CancelOrder @OrderID = @sampleOrder, @Reason = N'Test cancel by manager';
    END
    ELSE
        PRINT 'No orders to cancel in DB.';

    REVERT;
END TRY
BEGIN CATCH
    PRINT 'Manager test error: ' + ERROR_MESSAGE();
    REVERT;
END CATCH;
GO
