create or replace package body retail_pkg as

    -- migration procedure
	procedure transfer_data is
		v_product_id  products.id%type;
		v_country_id  countries.id%type;
		v_customer_id customers.id%type;
		v_invoice_no  invoices.id%type;
	begin
		for r in (
			select *
			  from temp
		) loop

            -- products
			begin
				select id
				  into v_product_id
				  from products
				 where stockcode = r.stockcode
				   and description = r.description;
			exception
				when no_data_found then
					insert into products (
						id,
						stockcode,
						description
					) values (
						seq_products.nextval,
						r.stockcode,
						r.description
					) returning id into v_product_id;
			end;

            -- country
			begin
				select id
				  into v_country_id
				  from countries
				 where country = r.country;
			exception
				when no_data_found then
					insert into countries (
						id,
						country
					) values (
						seq_countries.nextval,
						r.country
					) returning id into v_country_id;
			end;

            -- customer (may be null)
			if r.customerid is not null then
				begin
					select id
					  into v_customer_id
					  from customers
					 where customerid = r.customerid;
				exception
					when no_data_found then
						insert into customers (
							id,
							customerid
						) values (
							seq_customers.nextval,
							r.customerid
						) returning id into v_customer_id;
				end;
			else
				v_customer_id := null;
			end if;

            

            -- invoice
			begin
				select id
				  into v_invoice_no
				  from invoices
				 where invoiceno = r.invoiceno;
			exception
				when no_data_found then
					insert into invoices (
						id,
						invoiceno,
						invoicedate,
						cancelled,
						customerid,
						countryid
					) values (
						seq_invoices.nextval,
						r.invoiceno,
						r.invoicedate,
							case
							when substr(
								r.invoiceno,1,1
							) = 'C' then
							1
                            -- NOTE: chyba tak powinno byc
                            -- jednak nie do konca. Nie rozumiem, czemu
                            -- quantity czasem jest < 0. Jak cos jest zepsute, to
                            -- nie powinno miec quantity < 0, tylko unitprice = 0,
                            -- a ma i jedno i drugie.
                            -- when r.quantity < 0 and r.unitprice = 0 then
                            -- 1
							else
							0
							end,
						v_customer_id,
						v_country_id
					) returning id into v_invoice_no;
			end;

            -- order
			insert into orders (
				id,
				unitprice,
				quantity,
				productid,
				invoiceid
			) values (
				seq_orders.nextval,
				to_number(r.unitprice),
				r.quantity,
				v_product_id,
				v_invoice_no
			);
		end loop;
		commit;
	end transfer_data;

    -- calculates total sales value for a country
	function get_total_sales_by_country (
		p_country varchar2
	) return number is
		v_total number := 0;
	begin
		select sum(o.unitprice * o.quantity)
		  into v_total
		  from orders o
		  join invoices i
		on o.invoiceid = i.id
		  join countries c
		on i.countryid = c.id
		 where i.cancelled = 0
		   and upper(
			c.country
		) = upper(p_country);

		return nvl(
		          v_total,
		          0
		       );
	end get_total_sales_by_country;

end retail_pkg;
/

exec retail_pkg.transfer_data;