USE NHA_HANG;
GO
-- Test file for Customer role (khachhang)
-- Replace 'khachhang' with actual username if different.
PRINT '--- CUSTOMER TEST (khachhang) ---';
BEGIN TRY
    EXECUTE AS USER = 'khachhang';

    PRINT '>>> sp_RegisterAccount (customer self-register)';
    DECLARE @custC INT;
    EXEC dbo.sp_RegisterAccount 
        @FullName = N'Customer Test',
        @Phone = N'0988000111',
        @Email = N'custtest@example.com',
        @NewCustomerID = @custC OUTPUT;
    PRINT 'CustomerID = ' + ISNULL(CAST(@custC AS NVARCHAR(20)),'NULL');

    PRINT '>>> sp_OnlineBook (place an online reservation)';
    DECLARE @resonline INT;
    EXEC dbo.sp_OnlineBook 
        @Phone = N'0988000111',
        @CustomerName = N'Customer Test',
        @ReservationTime = '2025-12-24 18:00',
        @GuestCount = 2,
        @Notes = N'Dat online test',
        @ReservationID = @resonline OUTPUT;
    PRINT 'Online ReservationID = ' + ISNULL(CAST(@resonline AS NVARCHAR(20)),'NULL');

    PRINT '>>> sp_ViewCustomerHistory';
    IF @custC IS NOT NULL
        EXEC dbo.sp_ViewCustomerHistory @CustomerID = @custC;

    REVERT;
END TRY
BEGIN CATCH
    PRINT 'Customer test error: ' + ERROR_MESSAGE();
    REVERT;
END CATCH;
GO
