INSERT INTO categories VALUES (1,'Electronics',NULL),(2,'Home',NULL),(3,'Clothing',NULL),(4,'Sports',NULL),(5,'Unstocked',NULL);
INSERT INTO categories VALUES (1,'Electronics',NULL),(2,'Home',NULL),(3,'Clothing',NULL),(4,'Sports',NULL),(5,'Unstocked',NULL);
INSERT INTO categories VALUES (6,'Phones',1),(7,'Accessories',1),(8,'Kitchen',2),(9,'Furniture',2),(10,'Running',4),(11,'Trail running',10);
INSERT INTO warehouses VALUES (1,'Central','Nairobi'),(2,'Coastal','Mombasa'),(3,'Western','Kisumu'),(4,'Reserve','Nakuru');
INSERT INTO employees VALUES (1,'Alex Morgan',NULL,'Executive',180000,'2020-01-01');
INSERT INTO employees VALUES (2,'Sam Lee',1,'Sales',95000,'2021-02-01'),(3,'Taylor Kim',1,'Operations',95000,'2021-03-01');
INSERT INTO employees VALUES (4,'Casey Jones',2,'Sales',65000,'2022-01-01'),(5,'Robin Patel',2,'Sales',65000,'2022-02-01'),
							(6,'Jamie Ali',3,'Operations',70000,'2023-01-01'),(7,'Drew Chen',3,'Operations',60000,'2024-01-01');
CREATE TEMPORARY TABLE seq (n INT PRIMARY KEY);
INSERT INTO seq WITH RECURSIVE nums AS (SELECT 1 n UNION ALL SELECT n+1 FROM nums WHERE n<1000) SELECT n FROM nums;
INSERT INTO customers SELECT n, CONCAT('Customer ',LPAD(n,3,'0')),CONCAT('customer',n,'@example.test'),CASE WHEN MOD(n,11)=0 
THEN NULL ELSE ELT(1+MOD(n,4),'Nairobi','Mombasa','Kisumu','Nakuru') END, DATE_ADD('2022-01-01',INTERVAL MOD(n*17,700) DAY),
NULL FROM seq WHERE n<=120;
UPDATE customers SET referred_by=1 WHERE customer_id BETWEEN 2 AND 12;
UPDATE customers SET referred_by=2 WHERE customer_id BETWEEN 13 AND 20;
INSERT INTO products SELECT n,ELT(1+MOD(n,8),3,6,7,8,9,10,11,4),CONCAT('SKU-',LPAD(n,4,'0')),
CONCAT(ELT(1+MOD(n,8),'Jacket','Phone','Cable','Kettle','Chair','Shoes','Trail Shoes','Ball'),' ',n), 
100+MOD(n*137,4900),ROUND((100+MOD(n*137,4900))*0.6,2),n<>40,
JSON_OBJECT('color',ELT(1+MOD(n,3),'black','blue','white'),'weight_kg',ROUND(n/10,2),'tags',JSON_ARRAY('retail',
IF(MOD(n,2)=0,'premium','standard'))) FROM seq WHERE n<=40;

INSERT INTO inventory SELECT w.warehouse_id,p.product_id,MOD(w.warehouse_id*17+p.product_id*7,80),10 FROM warehouses w CROSS JOIN products p;
UPDATE inventory SET quantity=0 WHERE warehouse_id=4 AND product_id=40;

INSERT INTO orders SELECT n,1+MOD(n*17+FLOOR(n/7),100),IF(MOD(n,5)=0,NULL,4+MOD(n,2)),1+MOD(n,3),
DATE_ADD(DATE_ADD('2024-01-01',INTERVAL MOD(n*13,730) DAY),INTERVAL MOD(n*71,86400) SECOND),CASE WHEN MOD(n,10)=0 
THEN 'cancelled' WHEN MOD(n,10)=1 THEN 'pending' WHEN MOD(n,10)=2 THEN 'paid' WHEN MOD(n,10)=3 THEN 'shipped' ELSE 'delivered' 
END,ELT(1+MOD(n,3),'web','store','app') FROM seq WHERE n<=900;

INSERT INTO order_items SELECT o.order_id,p.product_id,1+MOD(o.order_id,4),p.list_price,IF(MOD(o.order_id,5)=0,10,0),p.unit_cost 
FROM orders o JOIN products p ON p.product_id=1+MOD(o.order_id*7,35);
INSERT INTO order_items SELECT o.order_id,p.product_id,1+MOD(o.order_id,2),p.list_price,IF(MOD(o.order_id,7)=0,15,0),p.unit_cost FROM orders o 
JOIN products p ON p.product_id=1+MOD(o.order_id*7+11,35) WHERE MOD(o.order_id,3)=0;

INSERT INTO payments(order_id,paid_at,amount,method,status) SELECT o.order_id,DATE_ADD(o.ordered_at,INTERVAL 1 HOUR),
ROUND(SUM(ROUND(i.quantity*i.unit_price*(1-i.discount_pct/100),2))*IF(MOD(o.order_id,4)=0,0.5,1),2),
ELT(1+MOD(o.order_id,4),'card','cash','mobile','bank'),'successful' FROM orders o JOIN order_items i USING(order_id) 
WHERE o.status IN ('paid','shipped','delivered') GROUP BY o.order_id,o.ordered_at;

INSERT INTO payments(order_id,paid_at,amount,method,status) SELECT o.order_id,DATE_ADD(o.ordered_at,INTERVAL 2 HOUR),
ROUND(SUM(ROUND(i.quantity*i.unit_price*(1-i.discount_pct/100),2)),2)-ROUND(SUM(ROUND(i.quantity*i.unit_price*(1-i.discount_pct/100),2))*0.5,2),'card','successful' FROM orders o JOIN order_items i USING(order_id) 
WHERE o.status IN ('paid','shipped','delivered') AND MOD(o.order_id,4)=0 AND MOD(o.order_id,8)<>0 GROUP BY o.order_id,o.ordered_at;

INSERT INTO payments(order_id,paid_at,amount,method,status) SELECT order_id,DATE_ADD(ordered_at,INTERVAL 10 MINUTE),500,'card','failed' 
FROM orders WHERE MOD(order_id,9)=0;
INSERT INTO shipments(order_id,shipped_at,delivered_at,carrier) SELECT order_id,DATE_ADD(ordered_at,INTERVAL 1 DAY),
IF(status='delivered',DATE_ADD(ordered_at,INTERVAL (2+MOD(order_id,8)) DAY),NULL),ELT(1+MOD(order_id,3),'Swift','ParcelGo','Express') 
FROM orders WHERE status IN ('shipped','delivered');

INSERT INTO returns_log(order_id,product_id,returned_at,quantity,reason,status) SELECT i.order_id,i.product_id,DATE_ADD(s.delivered_at,INTERVAL 3 DAY),
1,ELT(1+MOD(i.order_id,3),'Damaged','Wrong item','Changed mind'),IF(MOD(i.order_id,2)=0,'approved','requested') FROM order_items i JOIN shipments s 
USING(order_id) WHERE s.delivered_at IS NOT NULL AND MOD(i.order_id,7)=0;

INSERT INTO customer_import VALUES 
(1,'  Hary Kane',' harry@example.test',' nairobi ','2025-01-03'),(2,'Hary Kane','harry@example.test','Nairobi','2025-01-03'),
(3,'Leo Messi','john@example.test','Mombasa','2025-02-10'),(4,'','bad-email','Kisumu','invalid'),
(5,'Existing Customer','customer1@example.test','Nairobi','2025-03-01'),
(6,'Missing Email',NULL,'Nakuru','2025-03-01'),(7,'Bad Date','date@example.test','Nakuru','not-a-date');
DROP TEMPORARY TABLE seq;

