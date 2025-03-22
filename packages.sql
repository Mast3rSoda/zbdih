CREATE OR REPLACE PACKAGE order_pkg AS
    PROCEDURE transfer_data;
    
    FUNCTION total_order_value(p_country VARCHAR2) RETURN NUMBER;
END order_pkg;
/