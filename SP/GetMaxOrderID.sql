CREATE OR ALTER PROCEDURE GiftShop.GetMaxOrderID
    @MaxOrderID INT OUTPUT
AS

/***************************************************************************************************
File: GetMaxOrderID.sql
----------------------------------------------------------------------------------------------------
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Gets latest Order ID for insert, etc.
Call by:        Add hoc
Steps:          N/A 
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
   @Message = @Message

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed SELECT from table Order!';

IF(NOT EXISTS(SELECT 1
    FROM GiftShop.[Order]))
BEGIN
    SET @ErrorText = 'Failed SELECT from table Order!';
    SET @MaxOrderID = (SELECT NumValue
    FROM GiftShop.Parameter
    WHERE NAME = 'StartOrderID');
END
ELSE
BEGIN
    SET @MaxOrderID = (SELECT MAX(OrderID) + 1
    FROM GiftShop.[Order]);
END;
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

