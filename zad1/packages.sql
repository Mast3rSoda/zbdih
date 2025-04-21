create or replace package retail_pkg as
	procedure transfer_data;
	function get_total_sales_by_country (
		p_country varchar2
	) return number;
end retail_pkg;
/