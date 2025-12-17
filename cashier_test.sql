USE NHA_HANG;
GO
-- Test file for Cashier role (thungan)
-- Replace 'thungan' with actual username if different.
PRINT '--- CASHIER TEST (thungan) ---';
BEGIN TRY
    EXECUTE AS USER = 'thungan';

    PRINT '>>> sp_ViewOrder (pick an order)';
    DECLARE @ord INT;
    SELECT TOP 1 @ord = OrderID FROM dbo.Orders;
    IF @ord IS NULL
    BEGIN
        PRINT 'No orders found to view. Consider creating one first.';
    END
    ELSE
    BEGIN
        EXEC dbo.sp_ViewOrder @OrderID = @ord;

        PRINT '>>> sp_PayOrder (attempt to pay selected order)';
        EXEC dbo.sp_PayOrder @OrderID = @ord, @PaymentMethod = N'Cash';
        SELECT OrderID, Status, PaymentTime, PaymentMethod, TotalAmount FROM dbo.Orders WHERE OrderID = @ord;
    END

    PRINT '>>> sp_RevenueReport (sample)';
    EXEC dbo.sp_RevenueReport @FromDate='2025-01-01', @ToDate='2025-12-31';

    REVERT;
END TRY
BEGIN CATCH
    PRINT 'Cashier test error: ' + ERROR_MESSAGE();
    REVERT;
END CATCH;
GO
