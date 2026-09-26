--====================================
--  Create database trigger template 
--====================================

CREATE TRIGGER trg_SalesTransaction_Audit
ON Sales_Transaction
AFTER UPDATE, DELETE
AS
BEGIN

    INSERT INTO SalesTransaction_Audit
    (
        Transaction_ID,
        Customer_ID,
        Product_ID,
        Salesperson_ID,
        Region_ID,
        Transaction_Date,
        Quantity,
        Unit_Price,
        Cost_Price,
        Discount,
        Sales_Amount,
        Profit,
        Payment_Method,
        Payment_Status,
        Action_Type
    )
    SELECT
        d.Transaction_ID,
        d.Customer_ID,
        d.Product_ID,
        d.Salesperson_ID,
        d.Region_ID,
        d.Transaction_Date,
        d.Quantity,
        d.Unit_Price,
        d.Cost_Price,
        d.Discount,
        d.Sales_Amount,
        d.Profit,
        d.Payment_Method,
        d.Payment_Status,
        CASE
            WHEN EXISTS (SELECT 1 FROM inserted)
                THEN 'UPDATE'
            ELSE 'DELETE'
        END
    FROM deleted d;

END;

