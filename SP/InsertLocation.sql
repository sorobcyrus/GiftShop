CREATE OR ALTER PROCEDURE GiftShop.InsertLocation
    @Name       NVARCHAR(50)
AS
/***************************************************************************************************
File: InsertLocation.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.InsertLocation
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Insert a Location
Call by:        TBD, UI, Add hoc

Steps:          1- Error out if @Name already is in table GiftShop.Location
                2- Get Max LocationID by calling SP GiftShop.GetMaxLocationID
                3- Error out if @LocationID <= 0
                4- Insert to table GiftShop.Location

Parameter(s):   @Name
Usage:          GiftShop.InsertLocation @Name = 'TBD1'
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText   VARCHAR(MAX),      
        @Message     VARCHAR(255),    
        @StartTime   DATETIME,
        @SP          VARCHAR(50),
        @LocationID  TINYINT;

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
SET @ErrorText = 'Failed to SELECT from table Country!';

SET @ErrorText = 'Failed to SELECT from table Location!';
IF EXISTS(SELECT 1
	FROM GiftShop.Location
	WHERE [Name] = @Name)
BEGIN
    SET @ErrorText = 'Name = ' + @Name + ' already is in table Location! This is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed Calling SP GetMaxLocationID!';
-- Call SP
EXEC GiftShop.GetMaxLocationID @MaxLocationID = @LocationID OUTPUT;

SET @Message = 'LocationID = ' + CONVERT(VARCHAR(10), @LocationID) + ' is the return value from SP GiftShop.GetMaxLocationID.';   
RAISERROR (@Message, 0,1) WITH NOWAIT;
EXEC GiftShop.InsertHistory @SP = @SP,
   @Status = 'Run',
   @Message = @Message

SET @ErrorText = 'Failed check for variable @LocationID!';
-- Check for value
IF @LocationID <= 0
BEGIN
    SET @ErrorText = 'LocationID = ' + CONVERT(VARCHAR(10), @LocationID) + ' This value is not acceptable. Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed INSERT to table Location!';
INSERT INTO GiftShop.Location
    (LocationID, [Name])
VALUES
    (@LocationID, @Name)

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed INSERT to table Location using LocationID = ' + CONVERT(VARCHAR(10), @LocationID) ;   
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

