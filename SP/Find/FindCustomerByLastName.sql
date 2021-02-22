CREATE OR ALTER PROCEDURE GiftShop.FindCustomerByLastName
   @LastName NVARCHAR(50)
AS
/***************************************************************************************************
File: FindCustomerByLastName.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.FindCustomerByLastName
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Finds a customer info by Last Name 
Call by:        TBD, UI, Add hoc
Steps:          N/A
Parameter(s):   @LastName
Usage:          GiftShop.FindCustomerByLastName 'LastName'
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
SET @LastName = RTRIM(@LastName) + '%';

SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Start',
   @Message = @Message

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed to SELECT from table Customer!';
SELECT CU.CustomerID,
   CU.FirstName,
   CU.LastName,
   CU.Email,
   CO.Name AS CountryName,
   CU.ID,
   CU.Tel1,
   CU.Tel2,
   CU.Website,
   CU.Address,
   CU.Note
FROM GiftShop.Customer AS CU WITH (NOLOCK)
   INNER JOIN GiftShop.Country CO WITH (NOLOCK)
   ON CU.CountryID = CO.CountryID
WHERE CU.LastName LIKE @LastName;
SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed SELECT from table Customer using LastName = ' + @LastName;   
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

