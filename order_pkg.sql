create or replace package body order_pkg as

    -- Procedura przenosząca dane z TEMP do właściwych tabel
	procedure transfer_data is
		v_country_id  number(4);
		v_customer_id number(8);
		v_order_id    number(10);
		v_invoice_no  varchar2(10);
		v_stock_code  varchar2(15);
	begin
        -- Pobieramy dane z TEMP
		for temp_row in (
			select *
			  from temp
		) loop

            -- Sprawdzamy, czy kraj istnieje, jeśli nie -> dodajemy
			select id
			  into v_country_id
			  from countries
			 where country = temp_row.country;
          

            -- Sprawdzamy, czy klient istnieje, jeśli nie -> dodajemy
			select id
			  into v_customer_id
			  from customers
			 where id = temp_row.customerid
			 fetch first 1 rows only;


            -- Sprawdzamy, czy produkt istnieje, jeśli nie -> dodajemy
			select stockcode
			  into v_stock_code
			  from products
			 where stockcode = temp_row.stockcode
			 fetch first 1 rows only;


            -- Sprawdzamy, czy faktura istnieje, jeśli nie -> dodajemy
			select invoiceno
			  into v_invoice_no
			  from invoices
			 where invoiceno = temp_row.invoiceno
			 fetch first 1 rows only;

            -- Sprawdzamy, czy zamówienie istnieje, jeśli nie -> dodajemy
			select id
			  into v_order_id
			  from orders
			 fetch first 1 rows only;


            -- Przypisujemy zamówienie do faktury, jeśli jeszcze go tam nie ma
			insert into invoice_orders (
				id,
				invoiceno,
				orderid
			) values (
				seq_invoice_orders.nextval,
				v_invoice_no,
				v_order_id
			);
		end loop;
        EXCEPTION when no_data_found then
            DBMS_OUTPUT.PUT_LINE('There are ' || in_stock || ' items in stock.');
	end transfer_data;

    -- Funkcja zwracająca sumę wartości zamówień dla danego kraju
	function total_order_value (
		p_country varchar2
	) return number is
		v_total number := 0;
	begin
		select sum(o.unitprice * o.quantity)
		  into v_total
		  from orders o
		  join invoice_orders io
		on o.id = io.orderid
		  join invoices i
		on io.invoiceno = i.invoiceno
		  join customers c
		on i.customerid = c.id
		  join countries co
		on c.countryid = co.id
		 where co.country = p_country;

		return nvl(
		          v_total,
		          0
		       );
	end total_order_value;

end order_pkg;
/