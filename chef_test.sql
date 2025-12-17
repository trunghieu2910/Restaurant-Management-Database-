USE NHA_HANG;
GO
-- Test file for Chef role (user_chef)
-- Replace 'user_chef' with actual username if different.
PRINT '--- CHEF TEST (user_chef) ---';
BEGIN TRY
    EXECUTE AS USER = 'chef';

    PRINT '>>> sp_PendingKitchenItems';
    EXEC dbo.sp_PendingKitchenItems;

    PRINT '>>> sp_MarkItemUnavailable (pick a sample available ItemID)';
    DECLARE @sampleItemID INT;
    SELECT TOP 1 @sampleItemID = ItemID FROM dbo.MenuItems WHERE IsAvailable = 1;
    IF @sampleItemID IS NULL
    BEGIN
        PRINT 'No available menu item found to mark unavailable.';
    END
    ELSE
    BEGIN
        PRINT 'Marking ItemID = ' + CAST(@sampleItemID AS NVARCHAR(10));
        EXEC dbo.sp_MarkItemUnavailable @ItemID = @sampleItemID;
        SELECT ItemID, ItemName, IsAvailable FROM dbo.MenuItems WHERE ItemID = @sampleItemID;
    END

    REVERT;
END TRY
BEGIN CATCH
    PRINT 'Chef test error: ' + ERROR_MESSAGE();
    REVERT;
END CATCH;
GO
