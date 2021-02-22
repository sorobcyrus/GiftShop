CREATE OR ALTER PROCEDURE GiftShop.UpdateEmployee
    @EmployeeID INT,
    @ManagerID  INT,
    @TaskID     INT,
    @FirstName  VARCHAR(50),
    @LastName   VARCHAR(50),
    @Title      VARCHAR(100)
AS
/***************************************************************************************************
File: UpdateEmployee.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.UpdateEmployee
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Updates a Employee info by EmployeeID 
Call by:        TBD, UI, Add hoc
Steps:          N/A
Parameter(s):   @EmployeeID
Usage:          GiftShop.UpdateEmployee @EmployeeID = 1001,
                                        @ManagerID = 2001,
                                        @TaskID = 1,
                                        @FirstName = 'TBD',
                                        @LastName = 'TBD',
                                        @Title = 'TBD'
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText   VARCHAR(MAX),      
        @Message     VARCHAR(255),    
        @StartTime   DATETIME,
        @RowCount    INT,
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
SET @ErrorText = 'Failed to SELECT from table Employee!';
IF NOT EXISTS(SELECT 1
    FROM GiftShop.[Employee]
WHERE EmployeeID = @EmployeeID)
BEGIN
    SET @ErrorText = 'Did not find the Employee! EmployeeID = ' + CONVERT(VARCHAR(10), @EmployeeID) + ' not found in table Employee! Please check the EmployeeID and try again. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;


SET @ErrorText = 'Failed UPDATE to table Employee!';
UPDATE GiftShop.Employee
SET EmployeeID = ISNULL(@EmployeeID, EmployeeID),
    ManagerID = ISNULL(@ManagerID, ManagerID),
    TaskID = ISNULL(@TaskID, TaskID),
    FirstName = ISNULL(@FirstName, FirstName),
    LastName = ISNULL(@LastName, LastName),
    Title = ISNULL(@Title, Title)
WHERE EmployeeID = @EmployeeID
SET @RowCount = @@ROWCOUNT
IF @RowCount <> 1  
BEGIN
    SET @ErrorText = CONVERT(VARCHAR(10), @RowCount) + ' rows effected! EmployeeID = ' + CONVERT(VARCHAR(10), @EmployeeID) + ' Should be only one row! UNEXPECTED RESULT! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END
ELSE
BEGIN
    SET @Message = CONVERT(VARCHAR(10), @RowCount) + ' rows effected. Completed UPDATE to table Order using EmployeeID = ' + CONVERT(VARCHAR(10), @EmployeeID);
    RAISERROR (@Message, 0,1) WITH NOWAIT;
    EXEC GiftShop.InsertHistory @SP = @SP,
    @Status = 'Run',
    @Message = @Message;
END
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
