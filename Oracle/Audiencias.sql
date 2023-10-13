SELECT
tabla_sales.ORGANIZATION as Organismo,
tabla_contacto.FIRSTNAME as NOMBRE,
tabla_contacto.LASTNAME as APELLIDO,
tabla_contacto.ID_NUMBER as Cédula,
tabla_sales.ORDER_CONTACT_NUMBER as COD_CONTACTO,
tabla_contacto.BIRTHDATE as FECHA_DE_NACIMIENTO,
CASE 
    WHEN tabla_contacto.BIRTHDATE IS NULL THEN NULL
    ELSE FLOOR(MONTHS_BETWEEN(SYSDATE, tabla_contacto.BIRTHDATE) / 12)
END AS Edad,
CASE 
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, tabla_contacto.BIRTHDATE) / 12) IS NULL THEN 'SIN DATO'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, tabla_contacto.BIRTHDATE) / 12) < 18 THEN 'Menor de 18'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, tabla_contacto.BIRTHDATE) / 12) <= 24 THEN '18 a 24'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, tabla_contacto.BIRTHDATE) / 12) <= 34 THEN '25 a 34'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, tabla_contacto.BIRTHDATE) / 12) <= 44 THEN '35 a 44'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, tabla_contacto.BIRTHDATE) / 12) <= 54 THEN '45 a 54'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, tabla_contacto.BIRTHDATE) / 12) <= 64 THEN '55 a 64'
    ELSE 'Mayor a 64'
END AS Rango_de_edad,
tabla_contacto.EMAIL as CORREO,
tabla_contacto.NAT_NUMBER_CELLPHONE as MÓVIL,
CASE 
    WHEN tabla_contacto.GENDER = 'MALE' THEN 'HOMBRE'
    WHEN tabla_contacto.GENDER = 'FEMALE' THEN 'MUJER'
    WHEN tabla_contacto.GENDER = 'UNKNOWN' AND tabla_contacto.ADDRESS_SALUTATION IN ('Mr', 'Señor', 'Señor,', 'Don') THEN 'HOMBRE'
    WHEN tabla_contacto.GENDER = 'UNKNOWN' AND tabla_contacto.ADDRESS_SALUTATION IN ('Ms','Mrs', 'Miss', 'Señora', 'Señorita') THEN 'MUJER'
    WHEN tabla_contacto.GENDER = '' AND tabla_contacto.ADDRESS_SALUTATION IN ('Mr', 'Señor', 'Señor,', 'Don') THEN 'HOMBRE'
    WHEN tabla_contacto.GENDER = '' AND tabla_contacto.ADDRESS_SALUTATION IN ('Ms','Mrs', 'Miss', 'Señora', 'Señorita') THEN 'MUJER'
    WHEN COALESCE(tabla_contacto.GENDER, '') = '' AND tabla_contacto.ADDRESS_SALUTATION IN ('Mr', 'Señor', 'Señor,', 'Don') THEN 'HOMBRE'
    WHEN COALESCE(tabla_contacto.GENDER, '') = '' AND tabla_contacto.ADDRESS_SALUTATION IN ('Ms','Mrs', 'Miss', 'Señora', 'Señorita') THEN 'MUJER'
     WHEN tabla_contacto.GENDER IS NULL AND tabla_contacto.ADDRESS_SALUTATION IN ('Mr', 'Señor', 'Señor,', 'Don') THEN 'HOMBRE'
    WHEN tabla_contacto.GENDER IS NULL AND tabla_contacto.ADDRESS_SALUTATION IN ('Ms','Mrs', 'Miss', 'Señora', 'Señorita') THEN 'MUJER'
    ELSE 'SIN DATO'
END AS Género,
tabla_contacto.MAIN_ADDR_LINE1 as Dirección, 
tabla_contacto.MAIN_ADDR_TOWN as Ciudad_del_cliente,
tabla_contacto.MAIN_ADDR_GEO_ZONE as Departamento_del_cliente,
tabla_contacto.MAIN_ADDR_COUNTRY as País_del_cliente,
tabla_sales.SALES_CHANNEL_TYPE as Canal_de_venta,
tabla_sales.PRODUCT as Evento,
TO_CHAR(TO_DATE(REPLACE(tabla_sales.PRODUCT_DATE,'.','/'),'DD/MM/RR'), 'DD-MM-YY') AS Fecha_evento,
TO_CHAR(TO_DATE(REPLACE(tabla_sales.PRODUCT_DATE,'.','/'),'DD/MM/RR'), 'YYYY') AS Año,
TO_CHAR(TO_DATE(REPLACE(tabla_sales.ORDER_DATE,'.','/'),'DD/MM/RR'), 'DD-MM-YY') AS Fecha_compra,
TO_CHAR(TO_DATE(tabla_sales.ORDER_DATE_TIME, 'dd.MM.yyyy HH24:mi:ss'), 'HH24:mi:ss') AS Hora_de_compra,

 

CASE
    WHEN tabla_metodos.GRUPO = '' THEN 'Cortesía'
    WHEN COALESCE(tabla_metodos.GRUPO, '') = ''  THEN 'Cortesía'
    WHEN tabla_metodos.GRUPO IS NULL THEN 'Cortesía'
ELSE tabla_metodos.GRUPO 
END as Método_de_pago,

 

tabla_sales.PROMOTION as Promocion,
tabla_sales.LOGICAL_SEAT_CATEGORY as Categoría_Lógica,
tabla_sales.T_SITE_ID as Código_del_venue,
tabla_sales.SITE as Venue,
SUM(tabla_sales.NET_SOLD_T_QTY)- SUM(tabla_sales.NET_SOLD_C_QTY) as Tickets_comprados,
SUM(tabla_sales.NET_SOLD_C_QTY) AS Cortesías,
SUM(tabla_sales.NET_SOLD_TKT_AMT_ITX) AS Recaudo

 

FROM
(D_SALES_LIST_SALES_V1_0 tabla_sales
JOIN D_CONTACT_LIST_V1_0 tabla_contacto ON tabla_sales.T_ORDER_CONTACT_ID = tabla_contacto.T_CONTACT_ID
    LEFT JOIN (SELECT * FROM (SELECT FILE_NUMBER, PAYMENT_METHOD, ROW_NUMBER() OVER (PARTITION BY FILE_NUMBER ORDER BY PAYMENT_METHOD) AS row_num
    FROM D_SALES_PROD_PAYMENT_V1_0) WHERE row_num = 1) tabla_pago ON tabla_sales.FILE_NUMBER = tabla_pago.FILE_NUMBER)

 

    LEFT JOIN MAESTRO_METODOS tabla_metodos ON tabla_pago.PAYMENT_METHOD = tabla_metodos.PAYMENT_METHOD

 

WHERE tabla_sales.T_PRODUCT_ID IN (
'10229354897360'

 

 

)

 

GROUP BY
tabla_sales.ORGANIZATION, tabla_contacto.FIRSTNAME, tabla_contacto.LASTNAME,tabla_contacto.ID_NUMBER,tabla_sales.ORDER_CONTACT_NUMBER, tabla_contacto.BIRTHDATE,tabla_contacto.EMAIL,
tabla_contacto.NAT_NUMBER_CELLPHONE, tabla_contacto.GENDER, tabla_contacto.MAIN_ADDR_LINE1, tabla_contacto.MAIN_ADDR_TOWN, 
tabla_contacto.MAIN_ADDR_GEO_ZONE,tabla_contacto.MAIN_ADDR_COUNTRY, tabla_sales.SALES_CHANNEL_TYPE, tabla_sales.PRODUCT,  
tabla_sales.PRODUCT_DATE,tabla_sales.ORDER_DATE, tabla_sales.ORDER_DATE_TIME,
tabla_metodos.GRUPO, tabla_sales.PROMOTION, tabla_sales.LOGICAL_SEAT_CATEGORY, tabla_sales.T_SITE_ID,tabla_sales.SITE, tabla_contacto.ADDRESS_SALUTATION