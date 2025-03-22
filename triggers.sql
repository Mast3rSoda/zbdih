create or replace trigger trg_products before
    insert on products
    for each row
begin
	-- if :new.country is null then
	-- 	raise_application_error(
	-- 	                       -20069,
	-- 	                       'country cannot be null'
	-- 	);
	-- 	return;
	-- end if;


    select seq_products.nextval
      into :new.id
      from dual;
end;
/

create or replace trigger trg_countries before
    insert on countries
    for each row
declare
    c_count number;
begin
    if :new.country is null then
        raise_application_error(
                               -20069,
                               'country cannot be null'
        );
        return;
    end if;

    select count(*)
      into c_count
      from countries
     where country = :new.country;

    if c_count > 0 then
        raise_application_error(
                               -20420,
                               'country exists'
        );
        return;
    end if;

    select seq_countries.nextval
      into :new.id
      from dual;
end;
/

insert into countries ( country ) values ( 'bruh' );

create or replace trigger trg_customers before
    insert on customers
    for each row
begin
    select seq_customers.nextval
      into :new.id
      from dual;
end;
/

create or replace trigger trg_orders before
    insert on orders
    for each row
begin
    select seq_orders.nextval
      into :new.id
      from dual;
end;
/

create or replace trigger trg_invoices_pk before
    insert on invoices
    for each row
    when ( new.invoiceno is null )
begin
    select seq_invoices.nextval
      into :new.invoiceno
      from dual;
end;
/

create or replace trigger trg_invoice_orders_pk before
    insert on invoice_orders
    for each row
    when ( new.id is null )
begin
    select seq_invoice_orders.nextval
      into :new.id
      from dual;
end;
/