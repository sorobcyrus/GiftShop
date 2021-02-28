CREATE OR ALTER PROCEDURE GiftShop.InsertTask
    @TaskID     TINYINT,
    @Name  NVARCHAR(50),
    @Note   NVARCHAR(200)
AS
/***************************************************************************************************
File: InsertCustomer.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.InsertTask
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Insert an Employee
Call by:        GiftShop.InsertTask, Add hoc

Steps:          1- Insert to table GiftShop.Task

Parameter(s):   @TaskID  
                @Name      
                @Note  

Usage:          GiftShop.InsertTask @TaskID = 1001,
                                      @Name = 'TBD'',
                                      @Note = 'TBD'   

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

-- Check to give a friendly error for RI Issue.
SET @ErrorText = 'Failed to SELECT from table Task!';
IF EXISTS(SELECT 1
    FROM GiftShop.Task
WHERE TaskID = @TaskID)
BEGIN
    SET @ErrorText = 'Task = ' + @TaskID + ' already is in table Task! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Task!';
INSERT INTO GiftShop.Task
    (TaskID, [Name], Note)
VALUES
    (@TaskID, @Name, @Note)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Task using TaskID = ' + CONVERT(VARCHAR(10), @TaskID) ;   
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

