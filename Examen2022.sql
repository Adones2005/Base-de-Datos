use classicmodels;

select c.CUSTOMERNUMBER , c.CUSTOMERNAME, SUM(p.amount) as total_pagos 
FROM CUSTOMERS C inner join PAYMENTS P on C.CUSTOMERNUMBER = P.CUSTOMERNUMBER 
GROUP BY  c.CUSTOMERNUMBER 
ORDER BY  total_pagos desc
LIMIT 5;


SELECT o.*,o2.CITY 
from ORDERS O 
inner join  CUSTOMERS C  on o.CUSTOMERNUMBER = c.CUSTOMERNUMBER 
INNER JOIN EMPLOYEES E  on c.SALESREPEMPLOYEENUMBER = e.EMPLOYEENUMBER 
INNER JOIN OFFICES O2  on e.OFFICECODE  = o2.OFFICECODE 
WHERE o2.CITY = 'Paris';

SELECT YEAR(orderDate) AS year, MONTH(orderDate) AS month, COUNT(*) AS total_orders
FROM orders
WHERE YEAR(orderDate) >= YEAR(CURRENT_DATE()) - 20 
GROUP BY year, month
ORDER BY year DESC, month DESC;

SELECT *
FROM CUSTOMERS C 
WHERE c.CUSTOMERNUMBER in (
	select CUSTOMERNUMBER 
	FROM ORDERS O 
	group by CUSTOMERNUMBER 
	HAVING count(*) BETWEEN 5 and 10
);

DELIMITER $$

CREATE PROCEDURE verificar_cliente (IN CUSTOMERid INT)
BEGIN
    DECLARE top5_count INT;

    SELECT COUNT(*) INTO top5_count
    FROM (
        SELECT c.customerNumber
        FROM customers c
        INNER JOIN payments p ON c.customerNumber = p.customerNumber
        GROUP BY c.customerNumber
        ORDER BY SUM(p.amount) DESC
        LIMIT 5
    ) AS top5
    WHERE top5.customerNumber = CUSTOMERid;

    IF top5_count > 0 THEN
        SELECT 'El cliente se encuentra entre los 5 mejores' AS mensaje;
    ELSE
        SELECT 'El cliente no ha realizado ningún pago' AS mensaje;
    END IF;

END $$


DELIMITER $$

CREATE TRIGGER trigger_guardar_email_after_update
AFTER update
ON customers FOR EACH ROW
BEGIN
        INSERT INTO log_cambios_email (customerNumber, customerName, fecha_hora, old_email, new_email)
        VALUES (OLD.customerNumber, OLD.customerName, NOW(), OLD.email, NEW.email);
END $$

DELIMITER ;
