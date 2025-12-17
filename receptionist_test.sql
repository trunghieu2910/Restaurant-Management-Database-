USE NHA_HANG;
GO
-- Test file for Receptionist role (letan)
-- Replace 'letan' with actual username if different.
PRINT '--- RECEPTIONIST TEST (letan) ---';
BEGIN TRY
    EXECUTE AS USER = 'letan';

    PRINT '>>> sp_RegisterAccount';
    DECLARE @custID INT;
    EXEC dbo.sp_RegisterAccount 
        @FullName = N'Test Guest LT',
        @Phone = N'0909000001',
        @Email = N'testlt@example.com',
        @NewCustomerID = @custID OUTPUT;
    PRINT 'New CustomerID = ' + ISNULL(CAST(@custID AS NVARCHAR(20)),'NULL');

    PRINT '>>> sp_CreateReservation';
    DECLARE @resID INT;
    EXEC dbo.sp_CreateReservation 
        @CustomerID = @custID,
        @ReservationTime = '2025-12-30 19:00',
        @GuestCount = 3,
        @Notes = N'Test reservation by lễ tân',
        @ReservationID = @resID OUTPUT;
    PRINT 'ReservationID = ' + ISNULL(CAST(@resID AS NVARCHAR(20)),'NULL');

    PRINT '>>> sp_ConfirmArrival';
    EXEC dbo.sp_ConfirmArrival @ReservationID = @resID;

    PRINT '>>> sp_AssignTableToReservation';
    DECLARE @aTableID INT;
    SELECT TOP 1 @aTableID = TableID FROM dbo.Tables;
    IF @aTableID IS NOT NULL
    BEGIN
        EXEC dbo.sp_AssignTableToReservation @ReservationID = @resID, @TableID = @aTableID;
    END
    ELSE
        PRINT 'No tables exist to assign.';

    PRINT '>>> sp_OpenOrder';
    DECLARE @orderID INT;
    EXEC dbo.sp_OpenOrder @CustomerID = @custID, @EmployeeID = NULL, @ReservationID = @resID, @NewOrderID = @orderID OUTPUT;
    PRINT 'OrderID = ' + ISNULL(CAST(@orderID AS NVARCHAR(20)),'NULL');

    PRINT '>>> sp_ViewOrder';
    IF @orderID IS NOT NULL
        EXEC dbo.sp_ViewOrder @OrderID = @orderID;

    REVERT;
END TRY
BEGIN CATCH
    PRINT 'Receptionist test error: ' + ERROR_MESSAGE();
    REVERT;
END CATCH;
GO
