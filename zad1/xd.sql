select count(*)
  from temp;

select id
  from countries
 where country = 'xd'
 fetch first 1 rows only;

select unique customerid,
       country,
       count(*)
  from temp
 where customerid is null
 group by customerid,
          country;

select customerid,
       count(distinct country) as country_count
  from temp
 where customerid is not null
 group by customerid
having count(distinct country) > 1;

select length(customerid),
       count(distinct customerid)
  from temp
 where customerid is not null
   and regexp_like ( customerid,
                     '^\d+$' )
 group by length(customerid);

select *
  from temp
 where invoiceno like '%537834';

select distinct t.invoiceno
  from temp t
 where t.invoiceno like 'C%'
   and substr(
	t.invoiceno,2
) not in (
	select invoiceno
	  from temp
	 where invoiceno not like 'C%'
);

select distinct i.invoiceno as original_invoice,
                'C' || i.invoiceno as cancelled_invoice
  from temp i
 where i.invoiceno not like 'C%'  -- tylko oryginalne
   and exists (
	select 1
	  from temp t
	 where t.invoiceno = 'C' || i.invoiceno
);

select count(*) as liczba_par
  from (
	select distinct i.invoiceno
	  from temp i
	 where i.invoiceno not like 'C%'  -- oryginalne
	   and exists (
		select 1
		  from temp t
		 where t.invoiceno = 'C' || i.invoiceno
	)
);

select p.id as product_id,
       p.stockcode as product_stockcode,
       p.description as product_description,
       c.id as country_id,
       c.country as country_name,
       cu.id as customer_id,
       cu.customerid as customer_customerid,
       i.id as invoice_id,
       i.invoiceno as invoice_number,
       i.invoicedate as invoice_date,
       i.cancelled as invoice_cancelled,
       o.id as order_id,
       o.unitprice as order_unitprice,
       o.quantity as order_quantity
  from products p
  join orders o
on p.id = o.productid
  join invoices i
on o.invoiceid = i.id
  join customers cu
on i.customerid = cu.id
  join countries c
on i.countryid = c.id
 where rownum = 1;

select *
  from temp
 where temp.customerid = 17802
   and temp.stockcode = '16156S';

select count(*)
  from orders o
  join invoices i
on o.invoiceid = i.id
 where o.quantity < 0
   and substr(
	i.invoiceno,1,1
) != 'C';

select count(*)
  from orders o
  join invoices i
on o.invoiceid = i.id
 where o.quantity < 0
   and substr(
	i.invoiceno,1,1
) != 'C'
   and o.unitprice = 0;

select *
  from orders o
  join invoices i
on o.invoiceid = i.id
  join products p
on o.productid = p.id
 where o.quantity < 0
   and i.invoiceno like 'C%';

   -- DEBUG

select dp.id as dim_product_id,
	-- dim_products
       dc.id as dim_country_id,
	-- dim_countries
       dcu.id as dim_customer_id,
	-- dim_customers
       dd.id as dim_date_id,
	-- dim_date
       di.id as dim_invoice_id,
	-- dim_invoices
       o.unitprice as unitprice,
       o.quantity as quantity -- I'm literally crying from all these joins :^)
  from orders o -- invoices
  join invoices i
on i.id = o.invoiceid -- dim_invoices
  join dim_invoices di
on di.invoice_no = i.invoiceno -- products
  join products p
on p.id = o.productid -- dim_products
  join dim_products dp
on dp.stockcode = p.stockcode
   and dp.description = p.description -- country
  join countries c
on c.id = i.countryid -- dim_countries
  join dim_countries dc
on dc.country = c.country -- customers
  left join customers cu
on cu.id = i.customerid -- dim_customers
  left join dim_customers dcu
on dcu.customer_id = cu.customerid -- date
  join dim_date dd
on dd.year = extract(year from i.invoicedate)
   and dd.month = extract(month from i.invoicedate)
   and dd.day = extract(day from i.invoicedate);


select count(*)
  from fact_orders;

select count(*)
  from orders;

select sum(quantity)
  from fact_orders;

select i.customerid
  from invoices i
  left join customers c
on c.id = i.customerid
  left join dim_customers dc
on dc.customer_id = c.customerid
 where i.customerid is not null
   and dc.id is null;

select count(*)
  from orders o
  join invoices i
on i.id = o.invoiceid
  join dim_invoices di
on di.invoice_no = i.invoiceno
  join products p
on p.id = o.productid
  join dim_products dp
on dp.stockcode = p.stockcode
   and dp.description = p.description
  join countries c
on c.id = i.countryid
  join dim_countries dc
on dc.country = c.country
  left join customers cu
on cu.id = i.customerid
  left join dim_customers dcu
on dcu.customer_id = cu.customerid
  join dim_date dd
on dd.year = extract(year from i.invoicedate)
   and dd.month = extract(month from i.invoicedate)
   and dd.day = extract(day from i.invoicedate);

select count(*)
  from (
	select o.id as order_id,
	       p.id as product_id,
	       dp.id as dim_product_id,
	       i.id as invoice_id,
	       di.id as dim_invoice_id,
	       c.id as country_id,
	       dc.id as dim_country_id,
	       cu.id as customer_id,
	       dcu.id as dim_customer_id,
	       dd.id as dim_date_id
	  from orders o
-- produkty
	  left join products p
	on o.productid = p.id
	  left join dim_products dp
	on dp.stockcode = p.stockcode
	   and dp.description = p.description
-- faktury
	  left join invoices i
	on o.invoiceid = i.id
	  left join dim_invoices di
	on di.invoice_no = i.invoiceno
-- kraje
	  left join countries c
	on i.countryid = c.id
	  left join dim_countries dc
	on dc.country = c.country
-- klienci
	  left join customers cu
	on i.customerid = cu.id
	  left join dim_customers dcu
	on dcu.customer_id = cu.customerid
-- daty
	  left join dim_date dd
	on dd.year = extract(year from i.invoicedate)
	   and dd.month = extract(month from i.invoicedate)
	   and dd.day = extract(day from i.invoicedate)
	 where dp.id is null
	    or di.id is null
	    or dc.id is null
	    or ( i.customerid is not null
	   and dcu.id is null )
	    or dd.id is null
);

select *
  from orders o
-- produkty
  left join products p
on o.productid = p.id
  left join dim_products dp
on dp.stockcode = p.stockcode
   and dp.description = p.description
-- faktury
  left join invoices i
on o.invoiceid = i.id
  left join dim_invoices di
on di.invoice_no = i.invoiceno
-- kraje
  left join countries c
on i.countryid = c.id
  left join dim_countries dc
on dc.country = c.country
-- klienci
  left join customers cu
on i.customerid = cu.id
  left join dim_customers dcu
on dcu.customer_id = cu.customerid
-- daty
  left join dim_date dd
on dd.year = extract(year from i.invoicedate)
   and dd.month = extract(month from i.invoicedate)
   and dd.day = extract(day from i.invoicedate)
 where dp.id is null
    or di.id is null
    or dc.id is null
    or ( i.customerid is not null
   and dcu.id is null )
    or dd.id is null;

select *
  from orders o
  join products p
on o.productid = p.id
  left join dim_products dp
on dp.stockcode = p.stockcode
   and dp.description = p.description
 where o.id = 709;

select *
  from products
 where id = 2410;

select *
  from products
 where stockcode = '21777';

select *
  from dim_products
 where stockcode = '22139';