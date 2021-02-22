CREATE OR ALTER PROCEDURE GiftShop.InsertEmployee
    @EmployeeID INT,
    @ManagerID  TINYINT,
    @TaskID     TINYINT,
    @FirstName  NVARCHAR(50),
    @LastName   NVARCHAR(50),
    @Title      NVARCHAR(20)
AS
/***************************************************************************************************
File: InsertCustomer.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.InsertEmployee
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Insert an Employee
Call by:        GiftShop.InsertEmployee, Add hoc

Steps:          1- Check the @EmployeeID for RI issue in GiftShop.Country table
                3- Error out if @EmployeeID <= 1000
                4- Insert to table GiftShop.Employee

Parameter(s):   @EmployeeID  
                @ManagerID      
                @TaskID  
                @FirstName   
                @LastName         
                @Title       

Usage:          GiftShop.InsertEmployee @CustomerID = 1001,
                                      @ManagerID = 2000,
                                      @Email = 'TBD',
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
SET @ErrorText = 'Failed to SELECT from table Employee!';
IF EXISTS(SELECT 1
    FROM GiftShop.Employee
WHERE Email = @EmployeeID)
BEGIN
    SET @ErrorText = 'Email = ' + @EmployeeID + ' already is in table Employee! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed check for variable @EmployeeID!';
IF @EmployeeID <= 1000
BEGIN
    SET @ErrorText = 'EmployeeID = ' + CONVERT(VARCHAR(10), @EmployeeID) + ' This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Employee!';
INSERT INTO GiftShop.Customer
    (EmployeeID, ManagerID, TaskID, FirstName, LastName, Title)
VALUES
    (@EmployeeID, @ManagerID, @TaskID, @FirstName, @LastName, @Title)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Employee using EmployeeID = ' + CONVERT(VARCHAR(10), @EmployeeID) ;   
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

