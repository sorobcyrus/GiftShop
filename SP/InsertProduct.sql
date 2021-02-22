CREATE OR ALTER PROCEDURE GiftShop.InsertProduct
    @Name       NVARCHAR(50),
    @UnitPrice  MONEY,
    @Note       NVARCHAR(50) = NULL
AS
/***************************************************************************************************
File: InsertProduct.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.InsertProduct
Create Date:    2021-01-01
Author:         Sorob Cyrus
Description:    Insert a Product
Call by:        UI, Add hoc

Steps:          1- Check the @Name for RI issue in GiftShop.Product
                2- Get Max ProductID by calling SP GiftShop.GetMaxProductID
                3- Error out if @ProductID <= 0
                4- Insert to table GiftShop.Product

Parameter(s):   @Name
                @UnitPrice
                @Note

Usage:          GiftShop.InsertProduct @Name = 'Test1',
                                     @UnitPrice = 500,
                                     @Note = NULL
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText   VARCHAR(MAX),      
        @Message     VARCHAR(255),    
        @StartTime   DATETIME,
        @SP          VARCHAR(50),
        @ProductID   TINYINT;

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @SP = OBJECT_NAME(@@PROCID);
SET @StartTime = GETDATE();

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed to SELECT from table Product!';
IF EXISTS(SELECT 1
FROM GiftShop.Product
WHERE Name = @Name)
BEGIN
    SET @ErrorText = 'Name = ' + @Name + ' already is in table Product! This is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed Calling SP GetMaxProductID!';
-- Call SP
EXEC GiftShop.GetMaxProductID @MaxProductID = @ProductID OUTPUT;

SET @Message = 'ProductID = ' + CONVERT(VARCHAR(10), @ProductID) + ' is the return value from SP GiftShop.GetMaxProductID.';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message

SET @ErrorText = 'Failed check for variable @ProductID!';
-- Check for value
IF @ProductID <= 0
BEGIN
    SET @ErrorText = 'ProductID = ' + CONVERT(VARCHAR(10), @ProductID) + ' This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Product!';
INSERT INTO GiftShop.Product
    (ProductID, Name, UnitPrice, Note)
VALUES
    (@ProductID, @Name, @UnitPrice, @Note)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Product using ProductID = ' + CONVERT(VARCHAR(10), @ProductID) ;   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message
-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '    
      + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    
RAISERROR (@Message, 0,1) WITH NOWAIT;    
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

