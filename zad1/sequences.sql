drop sequence seq_products;
create sequence seq_products start with 1 increment by 1;
drop sequence seq_countries;
create sequence seq_countries start with 1 increment by 1;
drop sequence seq_customers;
create sequence seq_customers start with 1 increment by 1;
drop sequence seq_invoices;
create sequence seq_invoices start with 1 increment by 1;
drop sequence seq_orders;
create sequence seq_orders start with 1 increment by 1;

select * from temp where INVOICEDATE is null;