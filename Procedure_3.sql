USE NHA_HANG;
GO

-- 1) Create/replace sp_RegisterCustomer (must exist first)
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
        -- If phone exists, return existing id
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

-- 2) Recreate sp_CreateReservation (depends on sp_RegisterCustomer)
IF OBJECT_ID('dbo.sp_CreateReservation','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreateReservation;
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

            -- reuse existing or create
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

-- 3) Recreate sp_OnlineBook (depends on sp_RegisterCustomer)
IF OBJECT_ID('dbo.sp_OnlineBook','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_OnlineBook;
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

-- 4) Recreate sp_RegisterAccount (wrapper that calls sp_RegisterCustomer)
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

PRINT 'sp_RegisterCustomer, sp_CreateReservation, sp_OnlineBook, sp_RegisterAccount recreated successfully (in correct order).';
GO
