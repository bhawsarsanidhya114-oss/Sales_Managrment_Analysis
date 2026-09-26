import pyodbc 
import pandas as pd 
import matplotlib.pyplot as plt

connection = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=Sales_Management_DB;"
    "Trusted_Connection=yes;"
)

print("Connected successfully!")

query = "SELECT * FROM Sales_Transaction"

df = pd.read_sql(query, connection)

print(df.head())
print(df.shape)

print("\n--- Dataset Information ---")
df.info()

print("\n--- Missing Values ---")
print(df.isnull().sum())

print("\n--- Duplicate Rows ---")
print("Duplicate rows:", df.duplicated().sum())

df['transaction_date'] = pd.to_datetime(df['transaction_date'])
print(df.info())

print("\n--- Descriptive Statistics ---")
print(df.describe())

print("\n--- Highest Sales Transaction ---")
print(df[df['sales_amount'] == df['sales_amount'].max()])

print("\n--- Highest Profit Transaction ---")
print(df[df['profit'] == df['profit'].max()])

print("\n--- Discount vs Profit Correlation ---")
print(df[['Discount', 'profit']].corr())

profit_transactions = df[df['profit'] > 0] 
loss_transactions = df[df['profit'] < 0]
print("Profit Transactions:", len(profit_transactions)) 
print("Loss Transactions:", len(loss_transactions))
print("Total Profit:", profit_transactions['profit'].sum()) 
print("Total Loss:", loss_transactions['profit'].sum())

customer_frequency = df['customer_id'].value_counts()

print("\n--- Customer Frequency ---")
print(customer_frequency)

repeat_customers = (customer_frequency > 1).sum()
one_time_customers = (customer_frequency == 1).sum()

print("\n--- Customer Type Analysis ---")
print("Repeat Customers:", repeat_customers)
print("One-time Customers:", one_time_customers)

total_customers = len(customer_frequency)

print("Repeat Customer %:",
      round((repeat_customers / total_customers) * 100, 2))

print("One-time Customer %:",
      round((one_time_customers / total_customers) * 100, 2))


customer_summary = df.groupby('customer_id').agg(
    Purchases=('Transaction_ID', 'count'),
    Total_Sales=('sales_amount', 'sum'),
    Total_Profit=('profit', 'sum')
)


customer_summary['Customer_Type'] = customer_summary['Purchases'].apply(
    lambda x: 'Repeat' if x > 1 else 'One-time'
)

customer_type_summary = customer_summary.groupby('Customer_Type')[
    ['Total_Sales', 'Total_Profit']
].mean()

print("\n--- Repeat vs One-time Customer Contribution ---")
print(customer_type_summary)

customer_type_summary.plot(kind='bar')

plt.title('Repeat vs One-time Customer Contribution')
plt.xlabel('Customer Type')
plt.ylabel('Average Amount')
plt.xticks(rotation=0)

plt.tight_layout()
plt.show()


