create database Sales_Management_DB;
GO
create table Region (region_id varchar(20) primary key not null ,
                     region_name varchar(50) unique ,
                     state varchar (50) , 
                     country varchar(50));

create table Customer (customer_id varchar (20) primary key not null ,
                       customer_name varchar(50)not null , 
                        contact_no varchar(10) , 
                        Email varchar(100) , 
                        city varchar(50) , 
                        region_id varchar (20) , 
                        foreign key (region_id ) references Region (region_id));

create table Sales_person (salesperson_id varchar(20) primary key not null , 
                           salesperson_name varchar (50) not null ,
                           contact_no varchar (10),
                            Email varchar(100) , 
                            Hire_date date not null ,
                            department varchar(50) , 
                            region_id varchar(20),
                            sales_target decimal(12,2), 
                            commission_rate decimal(5,2),
                            Employment_status varchar(20) not null ,
                            foreign key (region_id ) references Region (region_id));
  

create table Product ( product_id varchar (20) primary key not null , 
                       product_name varchar(50), category varchar(50) ,
                      sub_category varchar(50) , 
                      brand varchar(50) ,
                      unit_price decimal (12,2) check(unit_price >0),
                      unit_cost decimal (12,2)
                      check (unit_cost >0));

create table sales_transaction ( Transaction_ID varchar(20) primary key not null , 
                                 customer_id varchar(20) not null , 
                                 product_id varchar(20) not null ,
                                 salesperson_id varchar(20) not null ,
                                 region_id varchar(20) not null , 
                                 transaction_date date not null , 
                                 Quantity int not null 
                                 check (Quantity > 0) ,
                                 Unit_price decimal (12,2) not null
                                 check (unit_price >0),
                                 Cost_price decimal(12,2)not null 
                                 check (Cost_price > 0) ,
                                 Discount decimal(5,2) not null 
                                 check (Discount >= 0 AND 
                                 Discount <= 100),
                                 sales_amount decimal(12,2) not null,
                                 profit decimal(12,2) not null,
                                 payment_method varchar(50),
                                 payment_status varchar(50),
                                 foreign key (customer_id) references Customer (customer_id),
                               foreign key (product_id) references Product (product_id),
                               foreign key (salesperson_id) references Sales_person (salesperson_id),
                               foreign key (region_id) references Region (region_id));
 
  CREATE TABLE SalesTransaction_Audit
(
    Audit_ID INT IDENTITY(1,1) PRIMARY KEY,
    Transaction_ID VARCHAR(20),
    Customer_ID VARCHAR(20),
    Product_ID VARCHAR(20),
    Salesperson_ID VARCHAR(20),
    Region_ID VARCHAR(20),
    Transaction_Date DATE,
    Quantity INT,
    Unit_Price DECIMAL(12,2),
    Cost_Price DECIMAL(12,2),
    Discount DECIMAL(12,2),
    Sales_Amount DECIMAL(12,2),
    Profit DECIMAL(12,2),
    Payment_Method VARCHAR(50),
    Payment_Status VARCHAR(50),
    Action_Type VARCHAR(20),
    Action_Date DATETIME DEFAULT GETDATE()
);

CREATE TABLE Product_Price_Audit
(
    Audit_ID INT IDENTITY(1,1) PRIMARY KEY,
    Product_ID VARCHAR(20),
    Old_Unit_Price DECIMAL(12,2),
    New_Unit_Price DECIMAL(12,2),
    Old_Unit_Cost DECIMAL(12,2),
    New_Unit_Cost DECIMAL(12,2),
    Changed_Date DATETIME DEFAULT GETDATE()
);
