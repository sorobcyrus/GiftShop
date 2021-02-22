CREATE OR ALTER PROCEDURE GiftShop.UpdateCustomer
    @CustomerID INT,
    @CountryID  TINYINT,
    @EmployeeID INT,
    @Email      NVARCHAR(50),
    @FirstName  NVARCHAR(50),
    @LastName   NVARCHAR(50),
    @ID         NVARCHAR(20),
    @Tel1       NVARCHAR(20) = NULL,
    @Tel2       NVARCHAR(20) = NULL,
    @Website    NVARCHAR(50) = NULL,
    @Address    NVARCHAR(250) = NULL,
    @Note       NVARCHAR(250) = NULL
AS
/***************************************************************************************************
File: UpdateCustomer.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.UpdateCustomer
Create Date:    2021-01-01
Author:         Sorob Cyrus
Description:    Update a Customer
Call by:        UI, Add hoc

Steps:          1- Check the @CustomerID for RI issue in GiftShop.Customer table
                2- Update GiftShop.Customer table

Parameter(s):   @CustomerID 
                @CountryID  
                @Email      NULL
                @FirstName  NULL
                @LastName   NULL
                @ID         NULL
                @Tel1       NULL
                @Tel2       NULL
                @Website    NULL
                @Address    NULL
                @Note       NULL

Usage:          EXEC GiftShop.UpdateCustomer @CustomerID = 100001052,
                                           @CountryID = 92,
                                           @Email = 'xyz10000010@abc.com',
                                           @FirstName = 'FirstName stuff...',
                                           @LastName = 'LastName stuff', 
                                           @ID = 'skdjkdj11121221', 
                                           @Tel1 = '012345678799',
                                           @Tel2 = '01234567879999999',
                                           @Website = 'www.test.com',
                                           @Address = 'Some Addrress ...',
                                           @Note = 'STUFF STUU FOR NOTE ......'
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
SET @ErrorText = 'Failed to SELECT from table Customer!';
IF NOT EXISTS(SELECT 1
	FROM GiftShop.Customer
	WHERE CustomerID = @CustomerID)
BEGIN
    SET @ErrorText = 'Did not find the Customer! CustomerID = ' + CONVERT(VARCHAR(10), @CustomerID) + ' not found in table Customer! Please check the CustomerID and try again. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Customer!';
UPDATE GiftShop.Customer
SET CountryID = ISNULL(@CountryID, CountryID),
    Email = ISNULL(@Email, Email),
    FirstName = ISNULL(@FirstName, FirstName),
    LastName = ISNULL(@LastName, LastName),
    ID = ISNULL(@ID, ID),
    Tel1 = ISNULL(@Tel1, Tel1),
    Tel2 = ISNULL(@Tel2, Tel2),
    Website = ISNULL(@Website, Website),
    Address = ISNULL(@Address, Address),
    Note = ISNULL(@Note, Note)
WHERE CustomerID = @CustomerID
SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed UPDATE to table Customer using CustomerID = ' + CONVERT(VARCHAR(10), @CustomerID) ;   
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

