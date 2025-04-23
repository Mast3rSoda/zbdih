create or replace procedure load_dims as
begin -- products
	insert
    /*+ ignore_row_on_dupkey_index(dim_countries(country)) */ into dim_products (
		stockcode,
		description
	)
		select distinct stockcode,
		                description
		  from products;
-- countries
	insert
	/*+ ignore_row_on_dupkey_index(dim_countries(country)) */ into dim_countries ( country )
		select distinct country
		  from countries;
-- customers
	insert
	/*+ ignore_row_on_dupkey_index(dim_customers(customer_id)) */ into dim_customers ( customer_id )
		select distinct customerid
		  from customers;
-- dates
	insert into dim_date (
		year,
		month,
		day
	)
		select distinct extract(year from invoicedate),
		                extract(month from invoicedate),
		                extract(day from invoicedate)
		  from invoices;
-- invoices
	insert
	/*+ ignore_row_on_dupkey_index(dim_invoices(invoice_no)) */ into dim_invoices ( invoice_no )
		select distinct invoiceno
		  from invoices;
	commit;
end;
/

exec LOAD_DIMS;


create or replace procedure load_facts as
begin
	insert into fact_orders (
		product_id,
		country_id,
		customer_id,
		date_id,
		invoice_id,
		unitprice,
		quantity
	)
		select dp.id, -- dim_products
		       dc.id, -- dim_countries
		       dcu.id, -- dim_customers
		       dd.id, -- dim_date
		       di.id, -- dim_invoices
		       o.unitprice,
		       o.quantity
      -- I'm literally crying from all these joins :^)
		  from orders o
      -- invoices
		  join invoices i
		on i.id = o.invoiceid
    -- dim_invoices
		  join dim_invoices di
		on di.invoice_no = i.invoiceno
    -- products
		  join products p
		on p.id = o.productid
    -- dim_products
		  join dim_products dp
		on dp.stockcode = p.stockcode
		   and ( dp.description = p.description
		    or ( dp.description is null
		   and p.description is null ) )
           -- country
		  join countries c
		on c.id = i.countryid
    -- dim_countries
		  join dim_countries dc
		on dc.country = c.country
    -- customers
		  left join customers cu
		on cu.id = i.customerid
    -- dim_customers
		  left join dim_customers dcu
		on dcu.customer_id = cu.customerid
    -- date
		  join dim_date dd
		on dd.year = extract(year from i.invoicedate)
		   and dd.month = extract(month from i.invoicedate)
		   and dd.day = extract(day from i.invoicedate);
	commit;
end;
/

exec LOAD_FACTS;

create or replace procedure load_facts_batched as
	cursor order_cursor is
	select dp.id as dim_product_id, -- dim_products
	       dc.id as dim_country_id, -- dim_countries
	       dcu.id as dim_customer_id, -- dim_customers
	       dd.id as dim_date_id, -- dim_date
	       di.id as dim_invoice_id, -- dim_invoices
	       o.unitprice as unitprice,
	       o.quantity as quantity -- I'm literally crying from all these joins :^)
	  from orders o
    -- invoices
	  join invoices i
	on i.id = o.invoiceid
  -- dim_invoices
	  join dim_invoices di
	on di.invoice_no = i.invoiceno
  -- products
	  join products p
	on p.id = o.productid
  -- dim_products
	  join dim_products dp
	on dp.stockcode = p.stockcode
	   and ( dp.description = p.description
	    or ( dp.description is null
	   and p.description is null ) )
       -- country
	  join countries c
	on c.id = i.countryid
  -- dim_countries
	  join dim_countries dc
	on dc.country = c.country
  -- customers
	  left join customers cu
	on cu.id = i.customerid
  -- dim_customers
	  left join dim_customers dcu
	on dcu.customer_id = cu.customerid
  -- date
	  join dim_date dd
	on dd.year = extract(year from i.invoicedate)
	   and dd.month = extract(month from i.invoicedate)
	   and dd.day = extract(day from i.invoicedate);

	type fact_orders_type is
		table of fact_orders%rowtype;
	v_fact_orders fact_orders_type;
	v_temp        fact_orders_type;
begin
	v_fact_orders := fact_orders_type();
	for r in order_cursor loop
		v_fact_orders.extend;
		v_fact_orders(v_fact_orders.count).product_id  := r.dim_product_id;
		v_fact_orders(v_fact_orders.count).country_id  := r.dim_country_id;
		v_fact_orders(v_fact_orders.count).customer_id := r.dim_customer_id;
		v_fact_orders(v_fact_orders.count).date_id     := r.dim_date_id;
		v_fact_orders(v_fact_orders.count).invoice_id  := r.dim_invoice_id;
		v_fact_orders(v_fact_orders.count).unitprice   := r.unitprice;
		v_fact_orders(v_fact_orders.count).quantity    := r.quantity;
		if v_fact_orders.count >= 1000 then
			forall i in 1..v_fact_orders.count
				insert into fact_orders (
					product_id,
					country_id,
					customer_id,
					date_id,
					invoice_id,
					unitprice,
					quantity
				) values (
					v_fact_orders(i).product_id,
					v_fact_orders(i).country_id,
					v_fact_orders(i).customer_id,
					v_fact_orders(i).date_id,
					v_fact_orders(i).invoice_id,
					v_fact_orders(i).unitprice,
					v_fact_orders(i).quantity
				);
			v_fact_orders := fact_orders_type();
		end if;
	end loop;

	if v_fact_orders.count > 0 then
		forall i in 1..v_fact_orders.count
			insert into fact_orders (
				product_id,
				country_id,
				customer_id,
				date_id,
				invoice_id,
				unitprice,
				quantity
			) values (
				v_fact_orders(i).product_id,
				v_fact_orders(i).country_id,
				v_fact_orders(i).customer_id,
				v_fact_orders(i).date_id,
				v_fact_orders(i).invoice_id,
				v_fact_orders(i).unitprice,
				v_fact_orders(i).quantity
			);
		v_fact_orders := fact_orders_type();
	end if;
	commit;
end;
/

exec LOAD_FACTS_BATCHED;