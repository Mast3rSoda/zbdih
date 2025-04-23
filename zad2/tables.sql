-- pretty much the same we had in zad1 (minor differences)

-- TABLE: product dim
drop table dim_products cascade constraints;

create table dim_products (
	id          number(8) not null primary key,
	stockcode   varchar2(15 char) not null,
	description varchar2(40 char)
);

-- TABLE: country dim
drop table dim_countries cascade constraints;

create table dim_countries (
	id      number(4) not null primary key,
	country varchar2(50) not null unique
);

-- TABLE: customer dim
-- glupia tabela ktora nie ma sensu
drop table dim_customers cascade constraints;

create table dim_customers (
	id         number(8) not null primary key,
	customer_id number(8) not null unique
);

-- TABLE: date dim
-- to jest bez sensu
drop table dim_date cascade constraints;

create table dim_date (
	id    number(10) not null primary key,
	year  number(4) not null,
	month number(2) not null check ( month between 1 and 12 ),
	day   number(2) not null check ( day between 1 and 31 )
);

-- TABLE: invoice dim
-- uh, pewnie beda podzielone zdania, ale imo, to jest calkiem dobry
-- pomysl to dodac. Jedyne zadanie tego wymiaru, to grupowanie
-- zamowien.
drop table dim_invoices cascade constraints;

create table dim_invoices (
	id    number(10) not null primary key,
	invoice_no VARCHAR2(10 char) not null unique
);

-- TABLE: order fact
drop table fact_orders cascade constraints;

create table fact_orders (
    id            number(12) not null primary key,
    product_id    number(8) not null,
    country_id    number(4) not null,
    customer_id   number(8),
    date_id       number(10) not null,
    invoice_id    number(10) not null,
    unitprice     number(10,2) not null,
    quantity      number(6) not null,
    total_value   number(12,2) generated always as (unitprice * quantity) virtual,

    constraint fk_fact_product  foreign key (product_id)  references dim_products(id),
    constraint fk_fact_country  foreign key (country_id)  references dim_countries(id),
    constraint fk_fact_customer foreign key (customer_id) references dim_customers(id),
    constraint fk_fact_date     foreign key (date_id)     references dim_date(id),
    constraint fk_fact_invoice  foreign key (invoice_id)  references dim_invoices(id)
);