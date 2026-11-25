-- =====================================================================
-- Reto OTC Consulting — Etapa 5
-- Consultas que responden las nueve preguntas de análisis del reto.
-- Cada bloque empieza con -- @consulta <nombre>; el runner
-- src/etapa5_consultas.py lo ejecuta y guarda el resultado.
-- Motor: SQLite 3. Las vistas vw_* están en 01_esquema_dimensional.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- P1 · ¿Quiénes están asignados y quiénes no, y cuánto tiempo llevan así?
-- ---------------------------------------------------------------------

-- @consulta q1_resumen
WITH activos AS (
    SELECT *
    FROM dim_colaborador
    WHERE estatus = 'Activo'
),
asignados AS (
    SELECT DISTINCT f.sk_colaborador
    FROM hecho_asignacion f
    JOIN dim_colaborador c ON c.sk_colaborador = f.sk_colaborador
    WHERE c.estatus = 'Activo'
)
SELECT
    (SELECT COUNT(*) FROM activos)                                      AS headcount_activo,
    (SELECT COUNT(*) FROM activos WHERE es_plantilla = 1)               AS plantilla_activa,
    (SELECT COUNT(*) FROM asignados)                                    AS asignados,
    (SELECT COUNT(*) FROM activos WHERE es_plantilla = 1
        AND sk_colaborador NOT IN (SELECT sk_colaborador FROM asignados)) AS banca_plantilla,
    (SELECT COUNT(*) FROM activos WHERE es_plantilla = 0)               AS familiares,
    (SELECT COUNT(*) FROM activos
        WHERE sk_colaborador NOT IN (SELECT sk_colaborador FROM asignados)) AS sin_asignacion_total,
    ROUND(100.0 * (SELECT COUNT(*) FROM asignados) / (SELECT COUNT(*) FROM activos), 1)            AS utilizacion_headcount_pct,
    ROUND(100.0 * (SELECT COUNT(*) FROM asignados)
        / (SELECT COUNT(*) FROM activos WHERE es_plantilla = 1), 1)     AS utilizacion_plantilla_pct;

-- @consulta q1_banca_por_puesto
SELECT
    COALESCE(puesto, 'Sin puesto capturado') AS puesto,
    COUNT(*)                                  AS personas,
    ROUND(SUM(costo_mensual), 2)              AS costo_mensual,
    ROUND(AVG(dias_en_banca), 0)              AS dias_promedio_en_banca,
    MAX(dias_en_banca)                        AS dias_maximo_en_banca
FROM dim_colaborador
WHERE estatus = 'Activo'
  AND es_plantilla = 1
  AND tiene_asignacion_vigente = 0
GROUP BY 1
ORDER BY personas DESC, costo_mensual DESC;

-- @consulta q1_banca_detalle
SELECT
    id_colaborador,
    COALESCE(puesto, 'Sin puesto capturado') AS puesto,
    COALESCE(departamento, 'Sin departamento') AS departamento,
    dias_en_banca,
    costo_mensual
FROM dim_colaborador
WHERE estatus = 'Activo'
  AND es_plantilla = 1
  AND tiene_asignacion_vigente = 0
ORDER BY dias_en_banca DESC
LIMIT 15;

-- @consulta q1_concentracion_cliente
SELECT
    cliente,
    COUNT(DISTINCT id_colaborador)                   AS personas_asignadas,
    ROUND(SUM(costo_mensual_asignado), 2)            AS costo_mensual_asignado,
    ROUND(100.0 * COUNT(DISTINCT id_colaborador)
        / (SELECT COUNT(DISTINCT sk_colaborador) FROM hecho_asignacion), 1) AS pct_de_asignados
FROM vw_asignacion
GROUP BY cliente
ORDER BY personas_asignadas DESC;

-- ---------------------------------------------------------------------
-- P2 · ¿Quiénes terminan pronto y en qué proyecto y cliente?
-- ---------------------------------------------------------------------

-- @consulta q2_vencimientos
SELECT
    id_asignacion,
    id_colaborador,
    cliente,
    proyecto,
    fecha_inicio,
    fecha_fin,
    dias_para_fin,
    CASE
        WHEN dias_para_fin <= 30 THEN '≤ 30 días'
        WHEN dias_para_fin <= 60 THEN '31–60 días'
        WHEN dias_para_fin <= 90 THEN '61–90 días'
        ELSE 'Más de 90 días'
    END AS ventana
FROM vw_asignacion
WHERE fecha_fin IS NOT NULL
ORDER BY dias_para_fin;

-- @consulta q2_resumen
SELECT
    COUNT(*)                                                        AS asignaciones_totales,
    SUM(sk_tiempo_fin = 0)                                          AS sin_fecha_fin,
    SUM(sk_tiempo_fin <> 0)                                         AS con_fecha_fin,
    SUM(dias_para_fin BETWEEN 0 AND 30)                             AS vencen_30_dias,
    SUM(dias_para_fin BETWEEN 31 AND 60)                            AS vencen_60_dias,
    SUM(dias_para_fin BETWEEN 61 AND 90)                            AS vencen_90_dias,
    SUM(dias_para_fin > 90)                                         AS despues_de_90_dias
FROM hecho_asignacion;

-- ---------------------------------------------------------------------
-- P3 · ¿Qué porcentaje de la nómina está asignado y cuánto cuesta la
--      gente sin proyecto?
-- ---------------------------------------------------------------------

-- @consulta q3_costos
SELECT
    (SELECT ROUND(SUM(costo_mensual), 2) FROM dim_colaborador WHERE estatus = 'Activo') AS nomina_activa,
    (SELECT ROUND(SUM(costo_mensual), 2) FROM dim_colaborador
        WHERE estatus = 'Activo' AND tiene_asignacion_vigente = 1)                       AS costo_asignado_unico,
    (SELECT ROUND(SUM(costo_mensual_asignado), 2) FROM hecho_asignacion)                 AS costo_asignado_filas,
    (SELECT ROUND(SUM(costo_mensual), 2) FROM dim_colaborador
        WHERE estatus = 'Activo' AND es_plantilla = 1 AND tiene_asignacion_vigente = 0)  AS costo_banca_plantilla,
    (SELECT ROUND(SUM(costo_mensual), 2) FROM dim_colaborador
        WHERE estatus = 'Activo' AND es_plantilla = 0)                                   AS costo_familiares,
    (SELECT ROUND(SUM(costo_mensual), 2) FROM dim_colaborador
        WHERE estatus = 'Activo' AND tiene_asignacion_vigente = 0)                       AS costo_sin_asignacion,
    (SELECT COUNT(*) FROM dim_colaborador
        WHERE estatus = 'Activo' AND es_plantilla = 1 AND tiene_asignacion_vigente = 0)  AS banca_plantilla,
    (SELECT COUNT(*) FROM dim_colaborador
        WHERE estatus = 'Activo' AND tiene_asignacion_vigente = 0)                       AS sin_asignacion_total,
    (SELECT COUNT(*) FROM dim_colaborador
        WHERE estatus = 'Activo' AND tiene_asignacion_vigente = 0 AND costo_mensual IS NULL) AS sin_asignacion_sin_costo,
    ROUND(100.0 * (SELECT SUM(costo_mensual) FROM dim_colaborador
        WHERE estatus = 'Activo' AND tiene_asignacion_vigente = 1)
        / (SELECT SUM(costo_mensual) FROM dim_colaborador WHERE estatus = 'Activo'), 1)  AS pct_nomina_asignada,
    ROUND(100.0 * (SELECT SUM(costo_mensual) FROM dim_colaborador
        WHERE estatus = 'Activo' AND es_plantilla = 1 AND tiene_asignacion_vigente = 0)
        / (SELECT SUM(costo_mensual) FROM dim_colaborador WHERE estatus = 'Activo'), 1)  AS pct_nomina_banca,
    (SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo' AND sobreasignado = 1) AS sobreasignados;

-- @consulta q3_por_cliente
SELECT
    cliente,
    COUNT(*)                                      AS asignaciones,
    COUNT(DISTINCT id_colaborador)                AS personas,
    ROUND(SUM(costo_mensual_asignado), 2)         AS costo_mensual_asignado,
    ROUND(100.0 * SUM(costo_mensual_asignado)
        / (SELECT SUM(costo_mensual_asignado) FROM hecho_asignacion), 1) AS pct_del_costo_asignado
FROM vw_asignacion
GROUP BY cliente
ORDER BY costo_mensual_asignado DESC;

-- ---------------------------------------------------------------------
-- P4 · ¿Cuál es el costo por experto en un proyecto por hora?
-- ---------------------------------------------------------------------

-- @consulta q4_costo_hora_puesto
SELECT
    COALESCE(puesto_catalogo, 'No especificado') AS puesto,
    COUNT(*)                                     AS asignaciones,
    COUNT(DISTINCT id_colaborador)               AS personas,
    ROUND(AVG(costo_hora_asignado), 2)           AS costo_hora_promedio,
    ROUND(MIN(costo_hora_asignado), 2)           AS costo_hora_minimo,
    ROUND(MAX(costo_hora_asignado), 2)           AS costo_hora_maximo,
    ROUND(SUM(costo_mensual_asignado), 2)        AS costo_mensual_asignado
FROM vw_asignacion
GROUP BY 1
ORDER BY asignaciones DESC, costo_hora_promedio DESC;

-- @consulta q4_cobertura
SELECT
    COUNT(*)                            AS asignaciones,
    SUM(sk_puesto = 0)                  AS sin_puesto,
    SUM(sk_rol = 0)                     AS sin_rol,
    SUM(costo_hora_asignado IS NULL)    AS sin_costo_hora,
    ROUND(AVG(costo_hora_asignado), 2)  AS costo_hora_promedio_global,
    ROUND(MIN(costo_hora_asignado), 2)  AS minimo,
    ROUND(MAX(costo_hora_asignado), 2)  AS maximo
FROM hecho_asignacion;

-- ---------------------------------------------------------------------
-- P5 · ¿Cuál es el margen por cliente y por proyecto?
-- ---------------------------------------------------------------------

-- @consulta q5_bloqueo
SELECT
    COUNT(*)                            AS asignaciones,
    SUM(ingreso_facturable IS NOT NULL) AS con_ingreso_facturable,
    SUM(margen IS NOT NULL)             AS con_margen,
    ROUND(SUM(costo_mensual_asignado), 2) AS costo_mensual_asignado
FROM hecho_asignacion;

-- @consulta q5_costo_por_proyecto
SELECT
    cliente,
    proyecto,
    COUNT(*)                              AS asignaciones,
    COUNT(DISTINCT id_colaborador)        AS personas,
    ROUND(SUM(costo_mensual_asignado), 2) AS costo_mensual_asignado,
    MIN(fecha_inicio)                     AS primer_inicio,
    MAX(fecha_fin)                        AS ultimo_fin
FROM vw_asignacion
GROUP BY cliente, proyecto
ORDER BY costo_mensual_asignado DESC;

-- ---------------------------------------------------------------------
-- P6 · ¿Qué habilidades se tienen, en qué nivel y cuáles faltan?
-- ---------------------------------------------------------------------

-- @consulta q6_tecnologia
SELECT
    h.tecnologia,
    COUNT(DISTINCT h.cod_habilidad)                       AS habilidades,
    COUNT(f.sk_habilidad_hecho)                           AS evaluaciones,
    COALESCE(SUM(f.nivel_num >= 3), 0)                    AS expertos,
    ROUND(100.0 * COALESCE(SUM(f.nivel_num >= 3), 0)
        / NULLIF(COUNT(f.sk_habilidad_hecho), 0), 1)      AS pct_expertos
FROM dim_habilidad h
LEFT JOIN hecho_habilidad f
       ON f.sk_habilidad = h.sk_habilidad
      AND f.sk_colaborador <> 0
WHERE h.sk_habilidad <> 0
GROUP BY h.tecnologia
ORDER BY evaluaciones DESC;

-- @consulta q6_niveles
SELECT
    nivel_txt,
    COUNT(*)                                                          AS evaluaciones,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM hecho_habilidad
        WHERE sk_colaborador <> 0), 1)                                AS pct
FROM hecho_habilidad
WHERE sk_colaborador <> 0
GROUP BY nivel_txt
ORDER BY nivel_num;

-- @consulta q6_riesgo
SELECT
    h.cod_habilidad,
    h.descripcion_unica,
    h.tecnologia,
    COUNT(f.sk_habilidad_hecho)             AS evaluados,
    COALESCE(SUM(f.nivel_num >= 3), 0)      AS expertos
FROM dim_habilidad h
LEFT JOIN hecho_habilidad f
       ON f.sk_habilidad = h.sk_habilidad
      AND f.sk_colaborador <> 0
WHERE h.sk_habilidad <> 0
GROUP BY h.cod_habilidad, h.descripcion_unica, h.tecnologia
HAVING COALESCE(SUM(f.nivel_num >= 3), 0) <= 1
ORDER BY expertos, evaluados DESC;

-- @consulta q6_cobertura
SELECT
    (SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo')            AS activos,
    (SELECT COUNT(DISTINCT sk_colaborador) FROM hecho_habilidad
        WHERE sk_colaborador <> 0)                                             AS con_matriz,
    (SELECT COUNT(*) FROM dim_colaborador c WHERE c.estatus = 'Activo'
        AND NOT EXISTS (SELECT 1 FROM hecho_habilidad f
                        WHERE f.sk_colaborador = c.sk_colaborador))            AS activos_sin_matriz,
    (SELECT COUNT(*) FROM hecho_habilidad)                                     AS evaluaciones_totales,
    (SELECT COUNT(*) FROM hecho_habilidad WHERE sk_colaborador = 0)           AS evaluaciones_sin_persona,
    (SELECT COUNT(*) FROM dim_habilidad WHERE sk_habilidad <> 0)               AS habilidades_catalogo;

-- ---------------------------------------------------------------------
-- P7 · ¿Qué colaboradores están en riesgo de salir?
-- ---------------------------------------------------------------------

-- @consulta q7_resumen
SELECT
    COUNT(*)                                                    AS personas,
    SUM(estatus = 'Activo')                                     AS activos,
    SUM(estatus = 'Baja')                                       AS bajas,
    ROUND(100.0 * SUM(estatus = 'Baja') / COUNT(*), 1)          AS pct_bajas,
    SUM(estatus = 'Baja' AND fecha_baja IS NULL)                AS bajas_sin_fecha,
    SUM(estatus = 'Baja' AND baja_primer_anio = 1)              AS bajas_primer_anio,
    ROUND(AVG(CASE WHEN estatus = 'Baja' THEN antiguedad_meses END), 1) AS antiguedad_promedio_bajas_meses
FROM dim_colaborador
WHERE sk_colaborador <> 0;

-- @consulta q7_cohortes
SELECT
    substr(fecha_incorporacion, 1, 4)                       AS anio_ingreso,
    COUNT(*)                                                AS ingresos,
    SUM(estatus = 'Baja')                                   AS bajas,
    ROUND(100.0 * SUM(estatus = 'Baja') / COUNT(*), 1)      AS pct_baja,
    SUM(estatus = 'Baja' AND baja_primer_anio = 1)          AS bajas_primer_anio,
    ROUND(AVG(CASE WHEN estatus = 'Baja' THEN antiguedad_meses END), 1) AS permanencia_promedio_meses
FROM dim_colaborador
WHERE fecha_incorporacion IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC;

-- @consulta q7_por_nomina
SELECT
    COALESCE(tipo_nomina, 'Sin esquema') AS tipo_nomina,
    COUNT(*)                             AS personas,
    SUM(estatus = 'Baja')                AS bajas,
    ROUND(100.0 * SUM(estatus = 'Baja') / COUNT(*), 1) AS pct_baja
FROM dim_colaborador
WHERE sk_colaborador <> 0
GROUP BY 1
ORDER BY bajas DESC, personas DESC;

-- ---------------------------------------------------------------------
-- P8 · ¿Qué equipo sigue con personas que ya salieron y cuánto vale
--      el inventario real?
-- ---------------------------------------------------------------------

-- @consulta q8_resumen
SELECT
    COUNT(*)                              AS activos,
    SUM(costo IS NULL)                    AS sin_costo,
    SUM(sk_colaborador = 0)               AS sin_resguardo,
    SUM(pendiente_recuperar = 1)          AS pendientes_recuperar,
    ROUND(SUM(costo), 2)                  AS valor_inventario_conocido,
    ROUND(SUM(costo_pendiente), 2)        AS valor_pendiente_recuperar,
    SUM(costo IS NOT NULL AND pendiente_recuperar = 1) AS pendientes_con_costo
FROM hecho_activo;

-- @consulta q8_marcas
SELECT
    a.marca,
    COUNT(*)                              AS equipos,
    SUM(f.costo IS NULL)                  AS sin_costo,
    ROUND(SUM(f.costo), 2)                AS valor_conocido
FROM hecho_activo f
JOIN dim_activo a ON a.sk_activo = f.sk_activo
GROUP BY a.marca
ORDER BY equipos DESC;

-- @consulta q8_pendientes
SELECT
    a.codigo,
    a.tipo,
    a.marca,
    f.costo,
    c.id_colaborador,
    c.estatus AS estatus_colaborador,
    c.fecha_baja
FROM hecho_activo f
JOIN dim_activo a      ON a.sk_activo = f.sk_activo
JOIN dim_colaborador c ON c.sk_colaborador = f.sk_colaborador
WHERE f.pendiente_recuperar = 1
ORDER BY f.costo DESC;

-- ---------------------------------------------------------------------
-- P9 · ¿Qué tan completo y confiable está el expediente?
-- ---------------------------------------------------------------------

-- @consulta q9_expediente
SELECT
    COUNT(*)                                AS activos,
    ROUND(AVG(pct_expediente), 1)           AS pct_expediente_promedio,
    SUM(expediente_completo = 1)            AS expedientes_completos,
    SUM(falta_puesto = 1)                   AS sin_puesto,
    SUM(falta_departamento = 1)             AS sin_departamento,
    SUM(falta_sueldo = 1)                   AS sin_sueldo,
    SUM(tiene_contrato = 1)                 AS con_contrato,
    SUM(pct_expediente = 0)                 AS expediente_en_cero
FROM dim_colaborador
WHERE estatus = 'Activo';

-- @consulta q9_rangos
SELECT
    CASE
        WHEN pct_expediente = 0 THEN '0 %'
        WHEN pct_expediente < 50 THEN '1–49 %'
        WHEN pct_expediente < 100 THEN '50–99 %'
        ELSE '100 %'
    END AS rango_expediente,
    COUNT(*) AS personas
FROM dim_colaborador
WHERE estatus = 'Activo'
GROUP BY 1
ORDER BY 1;
