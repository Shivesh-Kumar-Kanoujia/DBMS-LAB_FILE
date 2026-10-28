-- ============================================================
-- DBMS EXPERIMENT 7: NORMALIZATION OF SALES TABLE
-- Database: CompanyDB | MySQL
-- Execute sections in order.
-- ============================================================

CREATE DATABASE IF NOT EXISTS CompanyDB;
USE CompanyDB;

-- 1. CREATE DENORMALIZED SALES TABLE (UNF)
CREATE TABLE Sales_UNF (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerCity VARCHAR(60),
    ProductIDs VARCHAR(100) NOT NULL,
    ProductNames VARCHAR(200) NOT NULL,
    SalespersonID INT NOT NULL,
    SalespersonName VARCHAR(100) NOT NULL
);

INSERT INTO Sales_UNF VALUES
(1001, '2026-01-10', 1, 'Aarav Sharma', 'Kanpur',
 'P101,P102', 'Keyboard,Mouse', 501, 'Riya Verma'),
(1002, '2026-01-11', 2, 'Meera Singh', 'Lucknow',
 'P101', 'Keyboard', 502, 'Kabir Das'),
(1003, '2026-01-12', 1, 'Aarav Sharma', 'Kanpur',
 'P103', 'Monitor', 501, 'Riya Verma');

SELECT * FROM Sales_UNF;

-- 2. FUNCTIONAL DEPENDENCIES (documentation)
-- OrderID -> OrderDate, CustomerID, SalespersonID
-- CustomerID -> CustomerName, CustomerCity
-- ProductID -> ProductName
-- SalespersonID -> SalespersonName
-- (OrderID, ProductID) -> Quantity, UnitPrice
SELECT * FROM Sales_UNF;

-- 3. CONVERT UNF TO FIRST NORMAL FORM (1NF)
CREATE TABLE Sales_1NF (
    OrderID INT NOT NULL,
    OrderDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerCity VARCHAR(60),
    ProductID VARCHAR(10) NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    SalespersonID INT NOT NULL,
    SalespersonName VARCHAR(100) NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO Sales_1NF VALUES
(1001, '2026-01-10', 1, 'Aarav Sharma', 'Kanpur', 'P101', 'Keyboard', 501, 'Riya Verma', 1, 1200.00),
(1001, '2026-01-10', 1, 'Aarav Sharma', 'Kanpur', 'P102', 'Mouse', 501, 'Riya Verma', 2, 500.00),
(1002, '2026-01-11', 2, 'Meera Singh', 'Lucknow', 'P101', 'Keyboard', 502, 'Kabir Das', 1, 1200.00),
(1003, '2026-01-12', 1, 'Aarav Sharma', 'Kanpur', 'P103', 'Monitor', 501, 'Riya Verma', 1, 8500.00);

SELECT * FROM Sales_1NF ORDER BY OrderID, ProductID;

-- 4. CONVERT 1NF TO SECOND NORMAL FORM (2NF)
CREATE TABLE Orders_2NF (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerCity VARCHAR(60),
    SalespersonID INT NOT NULL,
    SalespersonName VARCHAR(100) NOT NULL
);

CREATE TABLE Products_2NF (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL
);

CREATE TABLE OrderItems_2NF (
    OrderID INT NOT NULL,
    ProductID VARCHAR(10) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders_2NF(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products_2NF(ProductID)
);

INSERT INTO Orders_2NF VALUES
(1001, '2026-01-10', 1, 'Aarav Sharma', 'Kanpur', 501, 'Riya Verma'),
(1002, '2026-01-11', 2, 'Meera Singh', 'Lucknow', 502, 'Kabir Das'),
(1003, '2026-01-12', 1, 'Aarav Sharma', 'Kanpur', 501, 'Riya Verma');

INSERT INTO Products_2NF VALUES
('P101', 'Keyboard'), ('P102', 'Mouse'), ('P103', 'Monitor');

INSERT INTO OrderItems_2NF VALUES
(1001, 'P101', 1, 1200.00),
(1001, 'P102', 2, 500.00),
(1002, 'P101', 1, 1200.00),
(1003, 'P103', 1, 8500.00);

SELECT * FROM Orders_2NF;
SELECT * FROM Products_2NF;
SELECT * FROM OrderItems_2NF;

-- 5. CONVERT 2NF TO THIRD NORMAL FORM (3NF)
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerCity VARCHAR(60)
);

CREATE TABLE Salespersons (
    SalespersonID INT PRIMARY KEY,
    SalespersonName VARCHAR(100) NOT NULL
);

CREATE TABLE Orders_3NF (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    SalespersonID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (SalespersonID) REFERENCES Salespersons(SalespersonID)
);

INSERT INTO Customers VALUES
(1, 'Aarav Sharma', 'Kanpur'),
(2, 'Meera Singh', 'Lucknow');

INSERT INTO Salespersons VALUES
(501, 'Riya Verma'),
(502, 'Kabir Das');

INSERT INTO Orders_3NF VALUES
(1001, '2026-01-10', 1, 501),
(1002, '2026-01-11', 2, 502),
(1003, '2026-01-12', 1, 501);

SELECT o.OrderID, o.OrderDate, c.CustomerName, c.CustomerCity,
       s.SalespersonName
FROM Orders_3NF o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Salespersons s ON o.SalespersonID = s.SalespersonID
ORDER BY o.OrderID;

-- 6. VERIFY BCNF
SHOW CREATE TABLE Customers;
SHOW CREATE TABLE Salespersons;
SHOW CREATE TABLE Orders_3NF;
SHOW CREATE TABLE Products_2NF;
SHOW CREATE TABLE OrderItems_2NF;

SELECT OrderID, ProductID, COUNT(*) AS row_count
FROM OrderItems_2NF
GROUP BY OrderID, ProductID
HAVING COUNT(*) > 1;
-- Expected: no rows. Under the stated functional dependencies,
-- the decomposed relations satisfy BCNF.

-- 7. VERIFY LOSSLESS JOIN
SELECT o.OrderID, o.OrderDate, c.CustomerID, c.CustomerName, c.CustomerCity,
       p.ProductID, p.ProductName, s.SalespersonID, s.SalespersonName,
       i.Quantity, i.UnitPrice
FROM Orders_3NF o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Salespersons s ON o.SalespersonID = s.SalespersonID
JOIN OrderItems_2NF i ON o.OrderID = i.OrderID
JOIN Products_2NF p ON i.ProductID = p.ProductID
ORDER BY o.OrderID, p.ProductID;

SELECT COUNT(*) AS reconstructed_rows
FROM Orders_3NF o
JOIN OrderItems_2NF i ON o.OrderID = i.OrderID
JOIN Products_2NF p ON i.ProductID = p.ProductID;
-- Expected reconstructed_rows = 4.

-- 8. VERIFY DEPENDENCY PRESERVATION
-- CustomerID -> CustomerName, CustomerCity
SELECT CustomerID, COUNT(*) AS rows_per_customer
FROM Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- ProductID -> ProductName
SELECT ProductID, COUNT(*) AS rows_per_product
FROM Products_2NF
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- SalespersonID -> SalespersonName
SELECT SalespersonID, COUNT(*) AS rows_per_salesperson
FROM Salespersons
GROUP BY SalespersonID
HAVING COUNT(*) > 1;

-- Expected: all three validation queries return no rows.
-- ============================================================
-- END OF EXPERIMENT 7
-- ============================================================
