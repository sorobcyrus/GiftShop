CREATE OR ALTER PROCEDURE GiftShop.InsertEmployeeTask
    @EmployeeID INT,
    @TaskID     TINYINT
AS
/***************************************************************************************************
File: InsertCustomer.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.InsertEmployeeTask
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Insert an EmployeeTask
Call by:        GiftShop.InsertEmployeeTask, Add hoc

Steps:          1- Insert to table GiftShop.EmployeeTask

Parameter(s):   @EmployeeID  
                @TaskID      

Usage:          GiftShop.InsertEmployeeTask @EmployeeID = 1001,
                                            @TaskID = 'TBD'   

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
IF NOT EXISTS(SELECT 1
    FROM GiftShop.[Employee]
WHERE EmployeeID = @EmployeeID)
BEGIN
    SET @ErrorText = 'EmployeeID = ' + CONVERT(VARCHAR(10), @EmployeeID) + ' not found in table Employee! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

-- Check to give a friendly error for RI Issue.
IF NOT EXISTS(SELECT 1
    FROM GiftShop.Task
WHERE TaskID = @TaskID)
BEGIN
    SET @ErrorText = 'TaskID = ' + CONVERT(VARCHAR(10), @TaskID) + ' not found in table Task! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;


SET @ErrorText = 'Failed INSERT to table EmployeeTask!';
INSERT INTO GiftShop.EmployeeTask
    (EmployeeID, TaskID)
VALUES
    (@EmployeeID, @TaskID)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table EmployeeTask using EmployeeID = ' + CONVERT(VARCHAR(10), @EmployeeID);   
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