-- TABLE: products
drop table products cascade constraints;

create table products (
	id          number(8) not null primary key,
	stockcode   varchar2(15 char) not null,
	description varchar2(40 char)
);

create index idx_products_stockcode on
	products (
		stockcode
	);

-- TABLE: countries
drop table countries cascade constraints;

create table countries (
	id      number(4) not null primary key,
	country varchar2(50) not null unique
);

-- TABLE: customers
-- glupia tabela ktora nie ma sensu
drop table customers cascade constraints;

create table customers (
	id         number(8) not null primary key,
	customerid number(8) not null unique
);

-- TABLE: invoices
-- id jest niepotrzebne gdyby nie tresc zadania
drop table invoices cascade constraints;

create table invoices (
	id          number(10) not null primary key,
	invoiceno   varchar2(10 char) not null unique,
	invoicedate date not null,
	cancelled   number(1) default 0 not null check ( cancelled in ( 0,1 ) ),
	customerid  number(8),
	constraint fk_customerid foreign key ( customerid )
		references customers ( id ),
	countryid   number(4) not null,
	constraint fk_countryid foreign key ( countryid )
		references countries ( id )
);

create index idx_invoices_invoicedate on
	invoices (
		invoicedate
	);
create index idx_invoices_cancelled on
	invoices (
		cancelled
	);
create index idx_invoices_customerid on
	invoices (
		customerid
	);
create index idx_invoices_countryid on
	invoices (
		countryid
	);

-- TABLE: orders
drop table orders cascade constraints;

create table orders (
	id        number(10) not null primary key,
	unitprice number(10,2) not null,
	quantity  number(6) not null,
	productid number(8) not null,
	constraint fk_productid foreign key ( productid )
		references products ( id ),
	invoiceid number(10) not null,
	constraint fk_invoiceid foreign key ( invoiceid )
		references invoices ( id )
);

create index idx_orders_productid on
	orders (
		productid
	);
create index idx_orders_invoiceid on
	orders (
		invoiceid
	);


-- drop table customers cascade constraints;

-- create table customers (
-- 	id         number(10) primary key,
-- 	customerid number(8),
-- 	countryid  number(4),
-- 	constraint fk_countryid foreign key ( countryid )
-- 		references countries ( id )
-- );

-- create index idx_customers_customerid on
-- 	customers (
-- 		customerid
-- 	);

-- create index idx_customers_countryid on
-- 	customers (
-- 		countryid
-- 	);


-- drop table invoice_orders cascade constraints;

-- create table invoice_orders (
-- 	id        number(10) not null primary key,
-- 	invoiceno varchar2(10 char) not null,
-- 	constraint fk_invoiceno foreign key ( invoiceno )
-- 		references invoices ( invoiceno ),
-- 	orderid   number(10) not null,
-- 	constraint fk_orderid foreign key ( orderid )
-- 		references orders ( id )
-- );

-- CREATE TYPE t_orderIDs AS TABLE OF NUMBER(10)
-- /
-- CREATE TABLE invoices (
--     invoiceNo VARCHAR2(10 CHAR) NOT NULL PRIMARY KEY,
--     invoiceDate DATE,
--     orderIDs t_orderIDs
-- ) NESTED TABLE orderIDs STORE AS orderIDs_tab
-- /
-- ALTER TABLE orderIDs_tab
-- ADD CONSTRAINT fk_orderIDs FOREIGN KEY (COLUMN_VALUE)
-- REFERENCES orders(id)

-- CREATE TYPE t_invoiceNos AS TABLE OF VARCHAR2(10)
-- /
-- CREATE TABLE customers (
--     customerID NUMBER(8) PRIMARY KEY,
--     invoiceNos t_invoiceNos,
--     country NUMBER(4),
--     CONSTRAINT fk_country FOREIGN KEY (country) REFERENCES countries(id)

-- ) NESTED TABLE invoiceNos STORE AS invoiceNos_tab;
-- /
-- ALTER TABLE invoiceNos_tab
-- ADD CONSTRAINT fk_invoiceNos FOREIGN KEY (COLUMN_VALUE)
-- REFERENCES invoices(InvoiceNo);