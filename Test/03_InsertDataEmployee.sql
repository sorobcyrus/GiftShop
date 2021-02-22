/***************************************************************************************************
File: 03_InsertDataEmployee.sql
----------------------------------------------------------------------------------------------------
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Inserts needed data to table GiftShop.Employee 
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

SET @SP = 'Script-03_InsertDataEmployee';
SET @StartTime = GETDATE(); 
   
SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Error',
   @Message = @Message;

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed INSERT table Employee table.';

INSERT INTO GiftShop.Employee
    (EmployeeID, ManagerID, TaskID, FirstName, LastName, Title)
VALUES
    (1001, 1001, 1,  'John', 'White', 'Manager'),
    (1002, 1001, 2,  'Joe', 'SalesGuy', 'Sales'),
    (1003, 1001, 2,  'Jill', 'SalesGuy', 'Sales'),
    (1004, 1001, 2,  'Jan', 'SalesGuy', 'Sales'),
    (1005, 1001, 2,  'Tery', 'SalesGuy', 'Sales'),
    (1006, 1001, 2,  'Sherry', 'SalesGuy', 'Sales'),
    (1007, 1001, 2,  'Cherry', 'SalesGuy', 'Sales'),
    (1008, 1001, 2,  'Apple', 'SalesGuy', 'Sales'),
    (1009, 1001, 2,  'Grapes', 'SalesGuy', 'Sales'),
    (1020, 1001, 2,  'Rob', 'SalesGuy', 'Sales')


SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Employee';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Complete',
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
