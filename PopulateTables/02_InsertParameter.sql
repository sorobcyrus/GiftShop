/***************************************************************************************************
File: 02_InsertParameter.sql
----------------------------------------------------------------------------------------------------
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Inserts needed parameters to table GiftShop.Parameter 
Call by:        TBD, Add hoc
Steps:          N/A 
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

SET @SP = 'Script-02_InsertParameter';
SET @StartTime = GETDATE();

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message;

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed INSERT to table Parameter!';
INSERT INTO GiftShop.Parameter
   (Name, NumValue, CharValue, Note)
VALUES
   ('StartCustomerID', 100001001, NULL, 'Start ID for CustomerID'),
   ('StartEmployeeID', 1001, NULL, 'Start ID for EmployeeID'),
   ('StartOrderID', 100001001, NULL, 'Start ID for OrderID'),
   ('StartLocationID', 1, NULL, 'Start ID for LocationID'),
   ('StartProductID', 1, NULL, 'Start ID for ProductID'),
   ('StartOrderStatusID', 1, NULL, 'Start ID for OrderStatusID')

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Parameter';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message;
-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + '. Duration in minutes:  '   
   + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    
RAISERROR(@Message, 0,1) WITH NOWAIT;
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
