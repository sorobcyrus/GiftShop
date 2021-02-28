CREATE OR ALTER PROCEDURE GiftShop.FindEmployeeByEmployeeID
    @EmployeeID INT
AS
/***************************************************************************************************
File: FindEmployeeByEmployeeID.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.FindEmployeeByEmployeeID
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Finds a Employee info by EmployeeID 
Call by:        TBD, UI, Add hoc
Steps:          N/A
Parameter(s):   @EmployeeID
Usage:          GiftShop.FindEmployeeByEmployeeID 1001
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
SET @ErrorText = 'Failed to SELECT from table Employee!';
SELECT ET.EmployeeID,
    ET.TaskID,
    EM.ManagerID,
    EM.FirstName,
    EM.LastName,
    EM.Title, 
    TA.Note
FROM GiftShop.EmployeeTask AS ET WITH (NOLOCK)
    INNER JOIN GiftShop.Employee EM WITH (NOLOCK)
    ON ET.EmployeeID = EM.EmployeeID
    INNER JOIN GiftShop.Task TA WITH (NOLOCK)
    ON ET.TaskID = TA.TaskID
WHERE EM.EmployeeID = @EmployeeID;

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed SELECT from table Employee using EmployeeID = ' + CONVERT(VARCHAR(10), @EmployeeID) ;   
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

