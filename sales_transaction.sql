CREATE PROCEDURE add_sales_transaction
	-- Add the parameters for the stored procedure here
	@transaction_id varchar(20),
	@customer_id varchar(20),
	@product_id varchar(20),
	@salesperson_id varchar(20),
	@region_id varchar(20),
	@transaction_date date ,
	@quantity int ,
	@Discount decimal (5,2),
	@payment_method varchar(50),
	@payment_status varchar(50),
	-- new customer add --
	 @Customer_Name     VARCHAR(50) = NULL,
    @City              VARCHAR(50) = NULL,
    @Gender            VARCHAR(50) = NULL,
    @Age               INT = NULL,
    @State             VARCHAR(50) = NULL,
    @Country           VARCHAR(50) = NULL,
    @CustomerSegment   VARCHAR(50) = NULL,
    @Joining_Date      DATE = NULL

AS
BEGIN
	
	SET NOCOUNT ON;
	-- Duplicate Transaction ID Check --
	IF EXISTS (
    SELECT 1
    FROM Sales_transaction
    WHERE  Transaction_ID = @transaction_id
)
BEGIN
    RAISERROR('Transaction ID Already Exists', 16, 1);
    RETURN;
END;
 -- Product ID Check --
 IF NOT EXISTS
 ( SELECT 1 
 FROM Product
 WHERE product_id = @product_id)
 BEGIN
     RAISERROR ('PRODUCT NOT FOUND ',16,1);
	 RETURN;
	 END;
	 -- Sales_person check--
	 IF NOT EXISTS
	 (SELECT 1
	 FROM Sales_person
	 WHERE salesperson_id=@salesperson_id)
	 BEGIN
	   RAISERROR('SALESPERSON NOT FOUND ' , 16,1);
	   RETURN;
	 END;
	 -- REGION CHECK--
	 IF NOT EXISTS
	 (SELECT 1 
	 FROM Region
	 WHERE region_id = @region_id)
	 BEGIN 
	 RAISERROR ('REGION NOT FOUND ',16,1);
	 RETURN;
	 END;
	 -- ADD CUSTOMER CHECK 
	 IF NOT EXISTS(
	 SELECT 1 
	 FROM Customer
	 WHERE customer_id=@customer_id)
	 BEGIN
	 IF @Customer_Name IS NULL 
	 BEGIN
	     RAISERROR('CUSTOMER NAME IS REQUIRED FOR NEW CUSTOMER',16,1);
		 RETURN;
		 END;

    -- Insert statements for procedure here
	INSERT INTO Customer
	(
	  customer_id,
	  customer_name,
	  city,
	  region_id,
	  gender,
	  age,
	  state,
	  country,
	  CustomerSegment,
	  joining_date
	  )
	  values
	  (
	  @customer_id,
	  @Customer_Name,
	  @City,
	  @region_id,
	  @Gender,
	  @Age,
	  @State,
	  @Country,
	  @CustomerSegment,
	  @Joining_Date);
	  END;
	  IF @transaction_date >
	  CAST(GETDATE() AS DATE)
	  BEGIN
	     RAISERROR('TRANSACTION DATE CANNOT BE IN THE FUTURE',16,1);
		 RETURN;
		 END;
      IF @quantity <=0
	  BEGIN
	  RAISERROR('QUANTITY MUST BE GREATER THAN 0', 16,1);
	  RETURN;
	  END;
	  IF @Discount <0 OR @Discount > 100
	  BEGIN
	     RAISERROR('DISCOUNT MUST BE BETWEEN 0 AND 100' ,16,1);
		 RETURN;
		 END;
    --- 9. PRODUCT UNIT PRICE AND COST 
	DECLARE @unit_price
	decimal(12,2);
	declare @cost_price
	decimal (12,2);
	select 
	@unit_price = unit_price,
	@cost_price = unit_cost
	from Product
	where product_id = @product_id;
	-- Sales Amount Calculation
	DECLARE @Sales_Amount DECIMAL(12,2);

    SET @Sales_Amount =
        @Quantity * @Unit_Price *
        (1 - @Discount / 100);
    -- Profit Calculation
	 DECLARE @Profit DECIMAL(12,2);

    SET @Profit =
        @Sales_Amount -
        (@Quantity * @Cost_Price);
    -- Insert Transaction
	 INSERT INTO Sales_Transaction
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
        Payment_Status
    )
    VALUES
    (
        @Transaction_ID,
        @Customer_ID,
        @Product_ID,
        @Salesperson_ID,
        @Region_ID,
        @Transaction_Date,
        @Quantity,
        @Unit_Price,
        @Cost_Price,
        @Discount,
        @Sales_Amount,
        @Profit,
        @Payment_Method,
        @Payment_Status
    );
 PRINT 'Transaction Added Successfully';
 SELECT
        @Transaction_ID AS Transaction_ID,
        @Unit_Price AS Unit_Price,
        @Cost_Price AS Cost_Price,
        @Sales_Amount AS Sales_Amount,
        @Profit AS Profit;

END
GO
