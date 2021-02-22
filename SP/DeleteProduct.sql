CREATE OR ALTER PROCEDURE GiftShop.DeleteProduct
   @ProductID TINYINT
AS
/***************************************************************************************************
File: DeleteProduct.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.DeleteProduct
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Deletes a Product
Call by:        TBD, UI, Add hoc
Steps:          N/A
Parameter(s):   @ProductID
Usage:          GiftShop.DeleteProduct 26
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

SET @SP = OBJECT_NAME(@@PROCID);
SET @StartTime = GETDATE();

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed DELETE from Product table.';

IF(NOT EXISTS(SELECT 1
   FROM GiftShop.Product))
BEGIN
   SET @ErrorText = 'Product table is Empty Rasing Error!';
   RAISERROR(@ErrorText, 16,1);
END;

DELETE FROM GiftShop.Product
WHERE ProductID = @ProductID;
IF @@ROWCOUNT = 0  
BEGIN
   SET @ErrorText = 'ProductID = ' + CONVERT(VARCHAR(10), @ProductID) + ' Not found! Rasing Error!';
   RAISERROR(@ErrorText, 16,1);
END;

SET @Message = 'Completed DELETE from Product table for ProductID = ' + CONVERT(VARCHAR(10), @ProductID) ;   
RAISERROR(@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message
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

