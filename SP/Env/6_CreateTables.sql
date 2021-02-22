CREATE OR ALTER PROCEDURE GiftShop.CreateTables
AS
/***************************************************************************************************
File: CreateTables.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.CreateTables
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Creates all needed GiftShop tables  
Call by:        TBD, UI, Add hoc
Steps:          NA
Parameter(s):   None
Usage:          EXEC GiftShop.CreateTables
****************************************************************************************************
SUMMARY OF CHANGES
Date			Author				Comments 
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText VARCHAR(MAX),      
        @Message   VARCHAR(255),   
        @StartTime DATETIME,
        @SP        VARCHAR(50)

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';  

SET @SP = OBJECT_NAME(@@PROCID)
SET @StartTime = GETDATE();    
SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');  
 
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
    @Status = 'Start',
    @Message = @Message;
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table GiftShop.Customer.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.Customer') AND type in (N'U'))
BEGIN
		SET @Message = 'Table GiftShop.Customer already exist, skipping....';
		RAISERROR(@Message, 0,1) WITH NOWAIT;
		EXEC GiftShop.InsertHistory @SP = @SP,
			@Status = 'Run',
			@Message = @Message;
END
ELSE
BEGIN
	    CREATE TABLE GiftShop.Customer
    (
        CustomerID INT NOT NULL,
        CountryID TINYINT NOT NULL,
        Email NVARCHAR(50) NOT NULL,
        FirstName NVARCHAR(50) NOT NULL,
        LastName NVARCHAR(50) NOT NULL,
        ID NVARCHAR(20) NOT NULL,
        Tel1 NVARCHAR(20) NULL,
        Tel2 NVARCHAR(20) NULL,
        Website NVARCHAR(50) NULL,
        Address NVARCHAR(250) NULL,
        Note NVARCHAR(250) NULL,
        CONSTRAINT PK_Customer_CustomerID PRIMARY KEY CLUSTERED (CustomerID),
        CONSTRAINT UK_Customer_Email UNIQUE (Email)
    );

    SET @Message = 'Completed CREATE TABLE GiftShop.Customer.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table GiftShop.Country.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.Country') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.Country already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE GiftShop.Country
    (
        CountryID	TINYINT			NOT NULL,
        [Name]		NVARCHAR(50)	NOT NULL,
        CONSTRAINT PK_CustomerCountry_CountryID PRIMARY KEY CLUSTERED (CountryID),
        CONSTRAINT UK_CustomerCountry_Name UNIQUE (Name)
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.Country.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table GiftShop.Order.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.Order') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.Order already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE GiftShop.[Order]
    (
        OrderID			INT				NOT NULL,
        CustomerID		INT				NOT NULL,
        EmployeeID      INT             NOT NULL,
        OrderStatusID	TINYINT			NOT NULL,
        OrderDate		DATETIME		NOT NULL,
        FinalDate		DATETIME		NULL,
        TotalAmount		MONEY			NOT NULL,
        Note			NVARCHAR(250)	NULL,
        CONSTRAINT PK_Order_OrderID PRIMARY KEY CLUSTERED (OrderID),
        CONSTRAINT CK_Order_TotalAmount CHECK (TotalAmount >= 0)
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.Order.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table GiftShop.OrderDetail.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.OrderDetail') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.OrderDetail already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE GiftShop.OrderDetail
    (
        OrderID		INT				NOT NULL,
        LocationID	TINYINT			NOT NULL,
        ProductID	TINYINT			NOT NULL,
        UnitPrice	MONEY			NOT NULL,
        Quantity	TINYINT			NOT NULL,
        Note		NVARCHAR(250)	NULL,
        CONSTRAINT PK_OrderDetail_OrderIDLocationIDProductID PRIMARY KEY CLUSTERED (OrderID, LocationID, ProductID),
        CONSTRAINT CK_OrderDetail_UnitPrice CHECK (UnitPrice >= 0),
        CONSTRAINT CK_OrderDetail_Quantity CHECK (Quantity >= 0)
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.OrderDetail.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table GiftShop.Product.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.Product') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.Product already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN

    CREATE TABLE GiftShop.Product
    (
        ProductID	TINYINT			NOT NULL,
        [Name]		NVARCHAR(100)	NOT NULL,
        UnitPrice	MONEY			NOT NULL,
        Note		VARCHAR(250)	NULL,
        CONSTRAINT PK_Product_ProductID PRIMARY KEY CLUSTERED (ProductID),
        CONSTRAINT UK_Product_Name UNIQUE (Name),
        CONSTRAINT CK_Product_UnitPrice CHECK (UnitPrice >= 0)
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.Product.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table GiftShop.Employee.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.Employee') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.Employee already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE GiftShop.[Employee]
    (
        EmployeeID      INT             NOT NULL,
        ManagerID       INT             NOT NULL,
        TaskID          INT             NOT NULL,
        FirstName       VARCHAR(50)     NOT NULL,
        LastName        VARCHAR(50)     NOT NULL,
        Title           VARCHAR(100)    NOT NULL,
        CONSTRAINT PK_Employee_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID)
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.Employee.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END

-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table GiftShop.Task.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.Task') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.Task already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE GiftShop.[Task]
    (
        TaskID          INT             NOT NULL,
        [Name]          VARCHAR(50)     NOT NULL,
        Note            VARCHAR(100)     NULL,
        CONSTRAINT PK_Task_TaskID PRIMARY KEY CLUSTERED (TaskID)
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.Task.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END

-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table GiftShop.EmployeeTask.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.EmployeeTask') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.EmployeeTask already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE GiftShop.[EmployeeTask]
    (
        EmployeeID      INT             NOT NULL,
        TaskID          INT             NOT NULL,
        CONSTRAINT PK_EmployeeTask_EmployeeIDTaskID PRIMARY KEY CLUSTERED (EmployeeID, TaskID)
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.EmployeeTask.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed CREATE Table GiftShop.OrderStatus.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.OrderStatus') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.OrderStatus already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE GiftShop.OrderStatus
    (
        OrderStatusID	TINYINT			NOT NULL,
        [Name]			NVARCHAR(50)	NOT NULL,
        CONSTRAINT PK_OrderStatus_OrderStatusID PRIMARY KEY CLUSTERED (OrderStatusID),
        CONSTRAINT UK_OrderStatus_Name UNIQUE (Name)
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.OrderStatus.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed CREATE Table GiftShop.Location.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.Location') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.Location already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE GiftShop.Location
    (
        LocationID	TINYINT			NOT NULL,
        [Name]		NVARCHAR(50)	NOT NULL,
        CONSTRAINT PK_Location_LocationID PRIMARY KEY CLUSTERED (LocationID),
        CONSTRAINT UK_Location_Name UNIQUE (Name)
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.Location.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------

SET @ErrorText = 'Failed CREATE Table GiftShop.CustomerOrder.';

IF EXISTS (SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'GiftShop.CustomerOrder') AND type in (N'U'))
BEGIN
    SET @Message = 'Table GiftShop.CustomerOrder already exist, skipping....';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
    CREATE TABLE GiftShop.CustomerOrder
    (
        Email		NVARCHAR(50)	NOT NULL,
        LocationID	TINYINT			NOT NULL,
        ProductID	TINYINT			NOT NULL,
        EmployeeID  INT             NOT NULL,
        UnitPrice	MONEY			NOT NULL,
        Quantity	TINYINT			NOT NULL,
        Note		NVARCHAR(250)	NULL
    )
    SET @Message = 'Completed CREATE TABLE GiftShop.CustomerOrder.';
    RAISERROR(@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message
END
-------------------------------------------------------------------------------


SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '   
   + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));   
RAISERROR(@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
    @Status = 'End',
    @Message = @Message

END TRY

BEGIN CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

SET @ErrorText = 'Error: '+CONVERT(VARCHAR,ISNULL(ERROR_NUMBER(),'NULL'))      
                  +', Severity = '+CONVERT(VARCHAR,ISNULL(ERROR_SEVERITY(),'NULL'))      
                  +', State = '+CONVERT(VARCHAR,ISNULL(ERROR_STATE(),'NULL'))      
                  +', Line = '+CONVERT(VARCHAR,ISNULL(ERROR_LINE(),'NULL'))      
                  +', Procedure = '+CONVERT(VARCHAR,ISNULL(ERROR_PROCEDURE(),'NULL'))      
                  +', Server Error Message = '+CONVERT(VARCHAR(100),ISNULL(ERROR_MESSAGE(),'NULL'))      
                  +', SP Defined Error Text = '+@ErrorText;

EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Error',
   @Message = @ErrorText

RAISERROR(@ErrorText,18,127) WITH NOWAIT;
END CATCH;      

