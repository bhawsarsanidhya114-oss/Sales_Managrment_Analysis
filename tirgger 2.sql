--====================================
--  Create database trigger template 
--====================================
CREATE TRIGGER trg_Product_Price_Audit
ON Product
AFTER UPDATE
AS
BEGIN

    INSERT INTO Product_Price_Audit
    (
        Product_ID,
        Old_Unit_Price,
        New_Unit_Price,
        Old_Unit_Cost,
        New_Unit_Cost
    )
    SELECT
        d.Product_ID,
        d.Unit_Price,
        i.Unit_Price,
        d.Unit_Cost,
        i.Unit_Cost
    FROM deleted d
    INNER JOIN inserted i
        ON d.Product_ID = i.Product_ID
    WHERE
        ISNULL(d.Unit_Price, 0) <> ISNULL(i.Unit_Price, 0)
        OR
        ISNULL(d.Unit_Cost, 0) <> ISNULL(i.Unit_Cost, 0);

END;
