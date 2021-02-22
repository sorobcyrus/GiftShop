CREATE OR ALTER PROCEDURE GiftShop.InsertHistory
    @SP      VARCHAR(50),
    @Status  VARCHAR(5),
    @Message VARCHAR(MAX)
AS
/***************************************************************************************************
File: InsertHistory.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.InsertHistory
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Inserts to GiftShop.History table  
Call by:        TBD, UI, Add hoc
Steps:          NA
Parameter(s):   None
Usage:          EXEC GiftShop.InsertHistory
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText   VARCHAR(MAX),  
        @Time        CHAR(19);

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @Time = (SELECT FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss'));

-------------------------------------------------------------------------------
SET @ErrorText = 'Failed INSERT to table History!';
INSERT INTO GiftShop.History
    ([Time], SP, [Status], [Message])
VALUES
    (@Time, @SP, @Status, @Message);
-------------------------------------------------------------------------------

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
   RAISERROR(@ErrorText,18,127) WITH NOWAIT;      
END CATCH;      

