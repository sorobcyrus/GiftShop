CREATE OR ALTER PROCEDURE GiftShop.CreateFKs
AS
/***************************************************************************************************
File: CreateFKs.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.CreateFKs
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Creates FKs for all needed GiftShop tables  
Call by:        TBD, UI, Add hoc
Steps:          NA
Parameter(s):   None
Usage:          EXEC GiftShop.CreateFKs
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
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
SET @ErrorText = 'Failed adding FOREIGN KEY for Table GiftShop.Customer.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'GiftShop.FK_Customer_Country_CountryID')
	AND parent_object_id = OBJECT_ID(N'GiftShop.Customer')
	)
BEGIN
  SET @Message = 'FOREIGN KEY for Table GiftShop.Customer already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC GiftShop.InsertHistory @SP = @SP,
        @Status = 'Run',
        @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE GiftShop.Customer
   ADD CONSTRAINT FK_Customer_Country_CountryID FOREIGN KEY (CountryID)
	REFERENCES GiftShop.Country (CountryID);

  SET @Message = 'Completed adding FOREIGN KEY for TABLE GiftShop.Customer.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed adding FOREIGN KEY for Table GiftShop.Order.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'GiftShop.FK_Order_Customer_CustomerID')
	AND parent_object_id = OBJECT_ID(N'GiftShop.Order')
	)
BEGIN
  SET @Message = 'FOREIGN KEY for Table GiftShop.Order already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE GiftShop.[Order]
  ADD CONSTRAINT FK_Order_Customer_CustomerID FOREIGN KEY (CustomerID)
	REFERENCES GiftShop.Customer (CustomerID),
  CONSTRAINT FK_Order_OrderStatus_OrderStatusID FOREIGN KEY (OrderStatusID)
	REFERENCES GiftShop.OrderStatus (OrderStatusID);

  SET @Message = 'Completed adding FOREIGN KEY for TABLE GiftShop.Order.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed adding FOREIGN KEY for Table GiftShop.OrderDetail.';

IF EXISTS (SELECT *
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'GiftShop.FK_OrderDetail_Order_OrderID')
	AND parent_object_id = OBJECT_ID(N'GiftShop.OrderDetail')
	)
BEGIN
  SET @Message = 'FOREIGN KEY for Table GiftShop.OrderDetail already exist, skipping....';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
END
ELSE
BEGIN
  ALTER TABLE GiftShop.OrderDetail
   ADD CONSTRAINT FK_OrderDetail_Order_OrderID FOREIGN KEY (OrderID)
      REFERENCES GiftShop.[Order] (OrderID),
    CONSTRAINT FK_OrderDetail_Location_LocationID FOREIGN KEY (LocationID)
      REFERENCES GiftShop.[Location] (LocationID),
    CONSTRAINT FK_OrderDetail_Product_ProductID FOREIGN KEY (ProductID)
      REFERENCES GiftShop.[Product] (ProductID);

  SET @Message = 'Completed adding FOREIGN KEY for TABLE GiftShop.OrderDetail.';
  RAISERROR(@Message, 0,1) WITH NOWAIT;
  EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
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

