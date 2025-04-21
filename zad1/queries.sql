SELECT 
    c.country AS country_name,
    retail_pkg.get_total_sales_by_country(c.country) AS total_sales
FROM 
    countries c
ORDER BY 
    total_sales DESC
FETCH FIRST 3 ROWS ONLY;