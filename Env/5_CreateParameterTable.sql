CREATE OR ALTER PROCEDURE GiftShop.CreateParameterTable
AS
/***************************************************************************************************
File: CreateParameterTable.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.CreateParameterTable
Create Date:    2021-01-01
Author:         Sorob Cyrus
Description:    Creates GiftShop.Parameter table  
Call by:        TBD, UI, Add hoc
Steps:          NA
Parameter(s):   None
Usage:          EXEC GiftShop.CreateParameterTable
****************************************************************************************************
SUMMARY OF CHANGES
Date			Author				Comments 
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
SET NOCOUNT ON;

DECLARE @ErrorText VARCHAR(MAX),      
        @Message   VARCHAR(255),   
        @StartTime DATETIME,
        @SP        VARCHAR(50)

BEGIN TRY;   
SET @ErrorText = 'Unexpected ERROR in setting the variables!';

SET @SP = OBJECT_NAME(@@PROCID)
SET @StartTime = GETDATE();    
SET @Message = 'Started SP ' + @SP + ' at ' + FORMAT(@StartTime , 'MM/dd/yyyy HH:mm:ss');   
RAISERROR (@Message, 0,1) WITH NOWAIT;
-------------------------------------------------------------------------------
SET @ErrorText = 'Failed Creating GiftShop.Parameter table.';

DROP TABLE IF EXISTS GiftShop.Parameter; 

CREATE TABLE GiftShop.Parameter
(
    [Name]		VARCHAR(20)		NOT NULL PRIMARY KEY,
    NumValue	INT				NULL,
    CharValue	VARCHAR(20)		NULL,
    Note		VARCHAR(250)	NULL
);

SET @Message = 'Completed Creating table GiftShop.Parameter ' ;   
RAISERROR(@Message, 0,1) WITH NOWAIT;
-------------------------------------------------------------------------------

SET @Message = 'Completed SP ' + @SP + 'Duration in minutes:  '   
   + CONVERT(VARCHAR(12), CONVERT(DECIMAL(6,2),datediff(mi, @StartTime, getdate())));    
RAISERROR(@Message, 0,1) WITH NOWAIT;
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

   THROW 66000, @ErrorText, 1;    
END CATCH;      

