CREATE OR ALTER PROCEDURE GiftShop.FindOrderByOrderID
    @OrderID INT
AS
/***************************************************************************************************
File: FindOrderByOrderID.sql
----------------------------------------------------------------------------------------------------
Procedure:      GiftShop.FindOrderByOrderID
Create Date:    2021-01-01 
Author:         Sorob Cyrus
Description:    Finds Orders by OrderID 
Call by:        TBD, UI, Add hoc
Steps:          N/A
Parameter(s):   @OrderID
Usage:          GiftShop.FindOrderByOrderID 100001001
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
SET @ErrorText = 'Failed to SELECT from tables!';

-- Make sure we have the OrderID.
IF NOT EXISTS(SELECT 1
	FROM GiftShop.[Order]
	WHERE OrderID = @OrderID)
BEGIN
    SET @ErrorText = 'OrderID = ' + CONVERT(VARCHAR(10), @OrderID) + ' not found in table Order! Rasing Error!';
    RAISERROR(@ErrorText, 16,1);
END;

SET @ErrorText = 'Failed to SELECT from table Order!';
SELECT OD.OrderID,
    OS.Name AS OrderStatus,
    CU.CustomerID,
    CU.FirstName AS CustomerFirstName,
    CU.LastName AS CustomerLastName,
    EM.Title AS EmployeeTitle,      
    EM.FirstName AS EmployeeFirstName,
    EM.LastName AS EmployeeLasttName,
    CO.Name AS CustomerCountry,
    P.Name AS ProductName,
    OD.UnitPrice,
    OD.Quantity,
    OD.Note AS OrderDetailNote,
    O.OrderDate,
    O.FinalDate,
    O.TotalAmount,
    O.Note AS OrderNote
FROM GiftShop.OrderDetail AS OD WITH (NOLOCK)
    INNER JOIN GiftShop.[Order] AS O WITH (NOLOCK)
    ON OD.OrderID =  O.OrderID
    INNER JOIN GiftShop.Product AS P WITH (NOLOCK)
    ON OD.ProductID = P.ProductID
    INNER JOIN GiftShop.Location AS L WITH (NOLOCK)
    ON OD.LocationID = L.LocationID
    INNER JOIN GiftShop.Customer AS CU WITH (NOLOCK)
    ON O.CustomerID = CU.CustomerID
    INNER JOIN GiftShop.Country AS CO WITH (NOLOCK)
    ON CU.CountryID = CO.CountryID
    INNER JOIN GiftShop.OrderStatus AS OS WITH (NOLOCK)
    ON O.OrderStatusID = OS.OrderStatusID
    INNER JOIN GiftShop.Employee AS EM WITH (NOLOCK)
    ON O.EmployeeID = EM.EmployeeID
WHERE O.OrderID = @OrderID;

SET @Message = CONVERT(VARCHAR(10), @@ROWCOUNT) + ' rows effected. Completed SELECT from table Order using OrderID = ' + CONVERT(VARCHAR(10), @OrderID) ;   
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

