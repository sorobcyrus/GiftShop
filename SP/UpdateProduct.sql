CREATE OR ALTER PROCEDURE GiftShop.UpdateProduct
    @ProductID TINYINT,
    @Name  NVARCHAR(50) = NULL,
    @UnitPrice MONEY = NULL,
    @Note NVARCHAR(250) = NULL
AS
/***************************************************************************************************
File: UpdateProduct.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.UpdateProduct
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Updatre a Product
Call by:        UI, Add hoc

Steps:          1- Check the @ProductID for RI issue in GiftShop.Product table
                2- Update table GiftShop.Product

Parameter(s):   @ProductID
                @Name      NULL
                @UnitPrice NULL
                @Note      NULL

Usage:          EXEC GiftShop.UpdateProduct @ProductID = 25,
                                          @Name = 'Some update test1';
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText   VARCHAR(MAX),      
        @Message     VARCHAR(255),    
        @StartTime   DATETIME,
        @SP          VARCHAR(50)

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @SP = OBJECT_NAME(@@PROCID);
SET @StartTime = GETDATE();
    
SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message;

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed to SELECT from table Product!';
IF NOT EXISTS(SELECT 1
	FROM GiftShop.Product
	WHERE ProductID = @ProductID)
BEGIN
    SET @ErrorText = 'Did not find the Product! ProductID = ' + CONVERT(VARCHAR(10), @ProductID) + ' not found in table Product! Please check the ProductID and try again. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Product!';

UPDATE GiftShop.Product
SET Name = ISNULL(@Name, Name),
    UnitPrice = ISNULL(@UnitPrice, UnitPrice),
    Note = ISNULL(@Note, Note)
WHERE ProductID = @ProductID
SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed UPDATE to table Product using ProductID = ' + CONVERT(VARCHAR(10), @ProductID) ;   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '    
      + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    
RAISERROR (@Message, 0,1) WITH NOWAIT;    
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'End',
   @Message = @Message;

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
        @Message = @ErrorText;
     
   RAISERROR(@ErrorText,18,127) WITH NOWAIT;      
END CATCH;      

