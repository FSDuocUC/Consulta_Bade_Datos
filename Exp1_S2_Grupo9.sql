-- =======================================================
-- CASO 1: ANÁLISIS DE FACTURAS
-- =======================================================
SELECT 
    numfactura AS "N° Factura",
    TO_CHAR(fecha, 'DD "de" Month    YYYY', 'NLS_DATE_LANGUAGE = SPANISH') AS "Fecha Emisión",
    LPAD(rutcliente, 10, '0') AS "RUT Cliente",
    TO_CHAR(neto, '$99G999G999') AS "Monto Neto",
    TO_CHAR(iva, '$99G999G999') AS "Monto Iva",
    TO_CHAR(total, '$99G999G999') AS "Total Factura",
    CASE 
        WHEN total BETWEEN 0 AND 50000 THEN 'Bajo'
        WHEN total BETWEEN 50001 AND 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS "Categoría Monto",
    CASE codpago
        WHEN 1 THEN 'EFECTIVO'
        WHEN 2 THEN 'TARJETA DEBITO'
        WHEN 3 THEN 'TARJETA CREDITO'
        ELSE 'CHEQUE'
    END AS "Forma de pago"
FROM factura
WHERE EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY fecha DESC, neto DESC;


-- =======================================================
-- CASO 2: CLASIFICACIÓN DE CLIENTES
-- =======================================================
SELECT 
    RPAD(LPAD(rutcliente, 12), 15, '*') AS "RUT",
    INITCAP(nombre) AS "Cliente",
    NVL(TO_CHAR(telefono), 'Sin teléfono') AS "TELÉFONO",
    NVL(TO_CHAR(codcomuna), 'Sin comuna') AS "COMUNA",
    estado AS "ESTADO",
    CASE 
        WHEN (saldo / credito) < 0.50 THEN 'Bueno ( ' || TO_CHAR(credito - saldo, '$99G999G999') || ')'
        WHEN (saldo / credito) BETWEEN 0.50 AND 0.80 THEN 'Regular ( ' || TO_CHAR(saldo, '$99G999G999') || ')'
        ELSE 'Crítico'
    END AS "Estado Crédito",
    UPPER(NVL(SUBSTR(mail, INSTR(mail, '@') + 1), 'Correo no registrado')) AS "Dominio Correo"
FROM cliente
WHERE estado = 'A' AND credito > 0
ORDER BY nombre ASC;


-- =======================================================
-- CASO 3: STOCK DE PRODUCTOS
-- =======================================================
SELECT 
    codproducto AS "ID",
    INITCAP(descripcion) AS "Descripción de Producto",
    NVL(TO_CHAR(valorcomprausd, '99G999D99') || ' USD', 'Sin registro') AS "Compra en USD",
    NVL('$' || TO_CHAR(ROUND(valorcomprausd * &TIPOCAMBIO_DOLAR), '99G999G999') || ' PESOS', 'Sin registro') AS "USD convertido",
    totalstock AS "Stock",
    CASE 
        WHEN totalstock IS NULL THEN 'Sin datos'
        WHEN totalstock < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
        WHEN totalstock BETWEEN &UMBRAL_BAJO AND &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END AS "Alerta Stock",
    CASE 
        WHEN totalstock > 80 THEN '$' || TO_CHAR(ROUND(vunitario * 0.90), '99G999G999')
        ELSE 'N/A'
    END AS "Precio Oferta"
FROM producto
WHERE LOWER(descripcion) LIKE '%zapato%' 
  AND LOWER(procedencia) = 'i'
ORDER BY codproducto DESC;
