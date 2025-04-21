select count(*) from temp;

SELECT id
            FROM countries 
            WHERE country = 'xd'
            FETCH FIRST 1 ROWS ONLY;

select unique CUSTOMERID, COUNTRY, COUNT(*) from temp where CUSTOMERID is null group by CUSTOMERID, COUNTRY;

SELECT CustomerID, COUNT(DISTINCT Country) AS country_count
FROM temp
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
HAVING COUNT(DISTINCT Country) > 1;

SELECT length(CUSTOMERID), count(distinct CUSTOMERID)
FROM temp
WHERE CustomerID IS NOT NULL
  AND REGEXP_LIKE(CustomerID, '^\d+$')
group by length(CUSTOMERID);

select * from temp where INVOICENO like '%537834';

SELECT DISTINCT t.InvoiceNo
FROM temp t
WHERE t.InvoiceNo LIKE 'C%'
  AND SUBSTR(t.InvoiceNo, 2) NOT IN (
    SELECT InvoiceNo FROM temp WHERE InvoiceNo NOT LIKE 'C%'
);

SELECT DISTINCT i.InvoiceNo AS original_invoice,
       'C' || i.InvoiceNo AS cancelled_invoice
FROM temp i
WHERE i.InvoiceNo NOT LIKE 'C%'  -- tylko oryginalne
  AND EXISTS (
    SELECT 1
    FROM temp t
    WHERE t.InvoiceNo = 'C' || i.InvoiceNo
  );

  SELECT COUNT(*) AS liczba_par
FROM (
  SELECT DISTINCT i.InvoiceNo
  FROM temp i
  WHERE i.InvoiceNo NOT LIKE 'C%'  -- oryginalne
    AND EXISTS (
      SELECT 1
      FROM temp t
      WHERE t.InvoiceNo = 'C' || i.InvoiceNo
    )
);

SELECT 
    p.id AS product_id,
    p.stockcode AS product_stockcode,
    p.description AS product_description,
    c.id AS country_id,
    c.country AS country_name,
    cu.id AS customer_id,
    cu.customerid AS customer_customerid,
    i.id AS invoice_id,
    i.invoiceno AS invoice_number,
    i.invoicedate AS invoice_date,
    i.cancelled AS invoice_cancelled,
    o.id AS order_id,
    o.unitprice AS order_unitprice,
    o.quantity AS order_quantity
FROM 
    products p
JOIN 
    orders o ON p.id = o.productid
JOIN 
    invoices i ON o.invoiceid = i.id
JOIN 
    customers cu ON i.customerid = cu.id
JOIN 
    countries c ON i.countryid = c.id
WHERE 
    rownum = 1;

select * from temp where temp.CUSTOMERID = 17802
    and temp.STOCKCODE = '16156S';

select count(*)
  from orders o
  join invoices i
on o.invoiceid = i.id
 where o.quantity < 0
   and substr(
	i.invoiceno,1,1
) != 'C';

select COUNT(*)
  from orders o
  join invoices i
on o.invoiceid = i.id
 where o.quantity < 0
   and substr(
	i.invoiceno,1,1
) != 'C'
and o.UNITPRICE = 0;

select *
  from orders o
  join invoices i
on o.invoiceid = i.id
join PRODUCTS p
on o.PRODUCTID = p.id
 where o.quantity < 0
   and i.INVOICENO like 'C%';