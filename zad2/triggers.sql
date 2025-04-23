create or replace trigger trg_dim_products before
	insert on dim_products
	for each row
	when ( new.id is null )
begin
	select seq_dim_products.nextval
	  into :new.id
	  from dual;
end;
/

create or replace trigger trg_dim_countries before
	insert on dim_countries
	for each row
	when ( new.id is null )
begin
	select seq_dim_countries.nextval
	  into :new.id
	  from dual;
end;
/

create or replace trigger trg_dim_customers before
	insert on dim_customers
	for each row
	when ( new.id is null )
begin
	select seq_dim_customers.nextval
	  into :new.id
	  from dual;
end;
/

create or replace trigger trg_dim_date before
	insert on dim_date
	for each row
	when ( new.id is null )
begin
	select seq_dim_date.nextval
	  into :new.id
	  from dual;
end;
/

create or replace trigger trg_dim_invoices before
	insert on dim_invoices
	for each row
	when ( new.id is null )
begin
	select seq_dim_invoices.nextval
	  into :new.id
	  from dual;
end;
/

create or replace trigger trg_fact_orders before
	insert on fact_orders
	for each row
	when ( new.id is null )
begin
	select seq_fact_orders.nextval
	  into :new.id
	  from dual;
end;
/