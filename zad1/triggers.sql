create or replace trigger trg_products before
	insert on products
	for each row
	when ( new.id is null )
begin
	select seq_products.nextval
	  into :new.id
	  from dual;
end;
/

create or replace trigger trg_countries before
	insert on countries
	for each row
	when ( new.id is null )
begin
	select seq_countries.nextval
	  into :new.id
	  from dual;
end;
/

create or replace trigger trg_customers before
	insert on customers
	for each row
	when ( new.id is null )
begin
	select seq_customers.nextval
	  into :new.id
	  from dual;
end;
/

create or replace trigger trg_invoices before
	insert on invoices
	for each row
	when ( new.id is null )
begin
	select seq_invoices.nextval
	  into :new.id
	  from dual;
end;
/

create or replace trigger trg_orders before
	insert on orders
	for each row
	when ( new.id is null )
begin
	select seq_orders.nextval
	  into :new.id
	  from dual;
end;
/