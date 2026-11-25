-- =====================================================================
-- Reto OTC Consulting — Etapa 5
-- Perfil de valores distintos por tabla de dimensión.
-- Cada fila devuelve: atributo, valores distintos, nulos, mínimo,
-- máximo y detalle. Si hay más de 10 valores, el detalle remite al
-- documento. La fila 0 (miembro desconocido) no se cuenta.
-- Motor: SQLite 3. Ejecutar contra data/modelo/otc_dw.db.
-- =====================================================================

-- dim_tiempo: 9497 miembros reales + 1 desconocido
SELECT 'dim_tiempo' AS dimension, 'fecha' AS atributo,
       COUNT(DISTINCT fecha) AS valores_distintos,
       SUM(fecha IS NULL) AS nulos,
       MIN(fecha) AS minimo, MAX(fecha) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_tiempo WHERE sk_tiempo <> 0
UNION ALL
SELECT 'dim_tiempo' AS dimension, 'anio' AS atributo,
       COUNT(DISTINCT anio) AS valores_distintos,
       SUM(anio IS NULL) AS nulos,
       MIN(anio) AS minimo, MAX(anio) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_tiempo WHERE sk_tiempo <> 0
UNION ALL
SELECT 'dim_tiempo' AS dimension, 'trimestre' AS atributo,
       COUNT(DISTINCT trimestre) AS valores_distintos,
       SUM(trimestre IS NULL) AS nulos,
       MIN(trimestre) AS minimo, MAX(trimestre) AS maximo,
       GROUP_CONCAT(DISTINCT trimestre) AS detalle
FROM dim_tiempo WHERE sk_tiempo <> 0
UNION ALL
SELECT 'dim_tiempo' AS dimension, 'mes' AS atributo,
       COUNT(DISTINCT mes) AS valores_distintos,
       SUM(mes IS NULL) AS nulos,
       MIN(mes) AS minimo, MAX(mes) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_tiempo WHERE sk_tiempo <> 0
UNION ALL
SELECT 'dim_tiempo' AS dimension, 'nombre_mes' AS atributo,
       COUNT(DISTINCT nombre_mes) AS valores_distintos,
       SUM(nombre_mes IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_tiempo WHERE sk_tiempo <> 0
UNION ALL
SELECT 'dim_tiempo' AS dimension, 'semana_iso' AS atributo,
       COUNT(DISTINCT semana_iso) AS valores_distintos,
       SUM(semana_iso IS NULL) AS nulos,
       MIN(semana_iso) AS minimo, MAX(semana_iso) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_tiempo WHERE sk_tiempo <> 0
UNION ALL
SELECT 'dim_tiempo' AS dimension, 'dia_semana' AS atributo,
       COUNT(DISTINCT dia_semana) AS valores_distintos,
       SUM(dia_semana IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT dia_semana) AS detalle
FROM dim_tiempo WHERE sk_tiempo <> 0
UNION ALL
SELECT 'dim_tiempo' AS dimension, 'es_fin_semana' AS atributo,
       COUNT(DISTINCT es_fin_semana) AS valores_distintos,
       SUM(es_fin_semana IS NULL) AS nulos,
       MIN(es_fin_semana) AS minimo, MAX(es_fin_semana) AS maximo,
       GROUP_CONCAT(DISTINCT es_fin_semana) AS detalle
FROM dim_tiempo WHERE sk_tiempo <> 0
UNION ALL
SELECT 'dim_tiempo' AS dimension, 'anio_mes' AS atributo,
       COUNT(DISTINCT anio_mes) AS valores_distintos,
       SUM(anio_mes IS NULL) AS nulos,
       MIN(anio_mes) AS minimo, MAX(anio_mes) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_tiempo WHERE sk_tiempo <> 0;

-- dim_colaborador: 107 miembros reales + 1 desconocido
SELECT 'dim_colaborador' AS dimension, 'id_colaborador' AS atributo,
       COUNT(DISTINCT id_colaborador) AS valores_distintos,
       SUM(id_colaborador IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'nombre_completo' AS atributo,
       COUNT(DISTINCT nombre_completo) AS valores_distintos,
       SUM(nombre_completo IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'genero' AS atributo,
       COUNT(DISTINCT genero) AS valores_distintos,
       SUM(genero IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT genero) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'ciudad' AS atributo,
       COUNT(DISTINCT ciudad) AS valores_distintos,
       SUM(ciudad IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'estatus' AS atributo,
       COUNT(DISTINCT estatus) AS valores_distintos,
       SUM(estatus IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT estatus) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'puesto' AS atributo,
       COUNT(DISTINCT puesto) AS valores_distintos,
       SUM(puesto IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'departamento' AS atributo,
       COUNT(DISTINCT departamento) AS valores_distintos,
       SUM(departamento IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT departamento) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'fecha_incorporacion' AS atributo,
       COUNT(DISTINCT fecha_incorporacion) AS valores_distintos,
       SUM(fecha_incorporacion IS NULL) AS nulos,
       MIN(fecha_incorporacion) AS minimo, MAX(fecha_incorporacion) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'fecha_baja' AS atributo,
       COUNT(DISTINCT fecha_baja) AS valores_distintos,
       SUM(fecha_baja IS NULL) AS nulos,
       MIN(fecha_baja) AS minimo, MAX(fecha_baja) AS maximo,
       GROUP_CONCAT(DISTINCT fecha_baja) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'fecha_nacimiento' AS atributo,
       COUNT(DISTINCT fecha_nacimiento) AS valores_distintos,
       SUM(fecha_nacimiento IS NULL) AS nulos,
       MIN(fecha_nacimiento) AS minimo, MAX(fecha_nacimiento) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'tipo_nomina' AS atributo,
       COUNT(DISTINCT tipo_nomina) AS valores_distintos,
       SUM(tipo_nomina IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT tipo_nomina) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'sueldo_neto_total' AS atributo,
       COUNT(DISTINCT sueldo_neto_total) AS valores_distintos,
       SUM(sueldo_neto_total IS NULL) AS nulos,
       MIN(sueldo_neto_total) AS minimo, MAX(sueldo_neto_total) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'sueldo_total_integrado' AS atributo,
       COUNT(DISTINCT sueldo_total_integrado) AS valores_distintos,
       SUM(sueldo_total_integrado IS NULL) AS nulos,
       MIN(sueldo_total_integrado) AS minimo, MAX(sueldo_total_integrado) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'costo_mensual' AS atributo,
       COUNT(DISTINCT costo_mensual) AS valores_distintos,
       SUM(costo_mensual IS NULL) AS nulos,
       MIN(costo_mensual) AS minimo, MAX(costo_mensual) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'costo_hora' AS atributo,
       COUNT(DISTINCT costo_hora) AS valores_distintos,
       SUM(costo_hora IS NULL) AS nulos,
       MIN(costo_hora) AS minimo, MAX(costo_hora) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'es_plantilla' AS atributo,
       COUNT(DISTINCT es_plantilla) AS valores_distintos,
       SUM(es_plantilla IS NULL) AS nulos,
       MIN(es_plantilla) AS minimo, MAX(es_plantilla) AS maximo,
       GROUP_CONCAT(DISTINCT es_plantilla) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'antiguedad_meses' AS atributo,
       COUNT(DISTINCT antiguedad_meses) AS valores_distintos,
       SUM(antiguedad_meses IS NULL) AS nulos,
       MIN(antiguedad_meses) AS minimo, MAX(antiguedad_meses) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'edad' AS atributo,
       COUNT(DISTINCT edad) AS valores_distintos,
       SUM(edad IS NULL) AS nulos,
       MIN(edad) AS minimo, MAX(edad) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'baja_primer_anio' AS atributo,
       COUNT(DISTINCT baja_primer_anio) AS valores_distintos,
       SUM(baja_primer_anio IS NULL) AS nulos,
       MIN(baja_primer_anio) AS minimo, MAX(baja_primer_anio) AS maximo,
       GROUP_CONCAT(DISTINCT baja_primer_anio) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'tiene_asignacion_vigente' AS atributo,
       COUNT(DISTINCT tiene_asignacion_vigente) AS valores_distintos,
       SUM(tiene_asignacion_vigente IS NULL) AS nulos,
       MIN(tiene_asignacion_vigente) AS minimo, MAX(tiene_asignacion_vigente) AS maximo,
       GROUP_CONCAT(DISTINCT tiene_asignacion_vigente) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'dedicacion_total_pct' AS atributo,
       COUNT(DISTINCT dedicacion_total_pct) AS valores_distintos,
       SUM(dedicacion_total_pct IS NULL) AS nulos,
       MIN(dedicacion_total_pct) AS minimo, MAX(dedicacion_total_pct) AS maximo,
       GROUP_CONCAT(DISTINCT dedicacion_total_pct) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'sobreasignado' AS atributo,
       COUNT(DISTINCT sobreasignado) AS valores_distintos,
       SUM(sobreasignado IS NULL) AS nulos,
       MIN(sobreasignado) AS minimo, MAX(sobreasignado) AS maximo,
       GROUP_CONCAT(DISTINCT sobreasignado) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'dias_en_banca' AS atributo,
       COUNT(DISTINCT dias_en_banca) AS valores_distintos,
       SUM(dias_en_banca IS NULL) AS nulos,
       MIN(dias_en_banca) AS minimo, MAX(dias_en_banca) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'pct_expediente' AS atributo,
       COUNT(DISTINCT pct_expediente) AS valores_distintos,
       SUM(pct_expediente IS NULL) AS nulos,
       MIN(pct_expediente) AS minimo, MAX(pct_expediente) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'expediente_completo' AS atributo,
       COUNT(DISTINCT expediente_completo) AS valores_distintos,
       SUM(expediente_completo IS NULL) AS nulos,
       MIN(expediente_completo) AS minimo, MAX(expediente_completo) AS maximo,
       GROUP_CONCAT(DISTINCT expediente_completo) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'tiene_contrato' AS atributo,
       COUNT(DISTINCT tiene_contrato) AS valores_distintos,
       SUM(tiene_contrato IS NULL) AS nulos,
       MIN(tiene_contrato) AS minimo, MAX(tiene_contrato) AS maximo,
       GROUP_CONCAT(DISTINCT tiene_contrato) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'inversion_equipo_col' AS atributo,
       COUNT(DISTINCT inversion_equipo_col) AS valores_distintos,
       SUM(inversion_equipo_col IS NULL) AS nulos,
       MIN(inversion_equipo_col) AS minimo, MAX(inversion_equipo_col) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'falta_puesto' AS atributo,
       COUNT(DISTINCT falta_puesto) AS valores_distintos,
       SUM(falta_puesto IS NULL) AS nulos,
       MIN(falta_puesto) AS minimo, MAX(falta_puesto) AS maximo,
       GROUP_CONCAT(DISTINCT falta_puesto) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'falta_departamento' AS atributo,
       COUNT(DISTINCT falta_departamento) AS valores_distintos,
       SUM(falta_departamento IS NULL) AS nulos,
       MIN(falta_departamento) AS minimo, MAX(falta_departamento) AS maximo,
       GROUP_CONCAT(DISTINCT falta_departamento) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'falta_tipo_nomina' AS atributo,
       COUNT(DISTINCT falta_tipo_nomina) AS valores_distintos,
       SUM(falta_tipo_nomina IS NULL) AS nulos,
       MIN(falta_tipo_nomina) AS minimo, MAX(falta_tipo_nomina) AS maximo,
       GROUP_CONCAT(DISTINCT falta_tipo_nomina) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'falta_ciudad' AS atributo,
       COUNT(DISTINCT falta_ciudad) AS valores_distintos,
       SUM(falta_ciudad IS NULL) AS nulos,
       MIN(falta_ciudad) AS minimo, MAX(falta_ciudad) AS maximo,
       GROUP_CONCAT(DISTINCT falta_ciudad) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'falta_fecha_baja' AS atributo,
       COUNT(DISTINCT falta_fecha_baja) AS valores_distintos,
       SUM(falta_fecha_baja IS NULL) AS nulos,
       MIN(falta_fecha_baja) AS minimo, MAX(falta_fecha_baja) AS maximo,
       GROUP_CONCAT(DISTINCT falta_fecha_baja) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'falta_sueldo' AS atributo,
       COUNT(DISTINCT falta_sueldo) AS valores_distintos,
       SUM(falta_sueldo IS NULL) AS nulos,
       MIN(falta_sueldo) AS minimo, MAX(falta_sueldo) AS maximo,
       GROUP_CONCAT(DISTINCT falta_sueldo) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'inconsistencia_estatus_fecha' AS atributo,
       COUNT(DISTINCT inconsistencia_estatus_fecha) AS valores_distintos,
       SUM(inconsistencia_estatus_fecha IS NULL) AS nulos,
       MIN(inconsistencia_estatus_fecha) AS minimo, MAX(inconsistencia_estatus_fecha) AS maximo,
       GROUP_CONCAT(DISTINCT inconsistencia_estatus_fecha) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'version_scd' AS atributo,
       COUNT(DISTINCT version_scd) AS valores_distintos,
       SUM(version_scd IS NULL) AS nulos,
       MIN(version_scd) AS minimo, MAX(version_scd) AS maximo,
       GROUP_CONCAT(DISTINCT version_scd) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'vigente_desde' AS atributo,
       COUNT(DISTINCT vigente_desde) AS valores_distintos,
       SUM(vigente_desde IS NULL) AS nulos,
       MIN(vigente_desde) AS minimo, MAX(vigente_desde) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'vigente_hasta' AS atributo,
       COUNT(DISTINCT vigente_hasta) AS valores_distintos,
       SUM(vigente_hasta IS NULL) AS nulos,
       MIN(vigente_hasta) AS minimo, MAX(vigente_hasta) AS maximo,
       GROUP_CONCAT(DISTINCT vigente_hasta) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0
UNION ALL
SELECT 'dim_colaborador' AS dimension, 'es_actual' AS atributo,
       COUNT(DISTINCT es_actual) AS valores_distintos,
       SUM(es_actual IS NULL) AS nulos,
       MIN(es_actual) AS minimo, MAX(es_actual) AS maximo,
       GROUP_CONCAT(DISTINCT es_actual) AS detalle
FROM dim_colaborador WHERE sk_colaborador <> 0;

-- dim_puesto: 23 miembros reales + 1 desconocido
SELECT 'dim_puesto' AS dimension, 'id_puesto' AS atributo,
       COUNT(DISTINCT id_puesto) AS valores_distintos,
       SUM(id_puesto IS NULL) AS nulos,
       MIN(id_puesto) AS minimo, MAX(id_puesto) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_puesto WHERE sk_puesto <> 0
UNION ALL
SELECT 'dim_puesto' AS dimension, 'puesto' AS atributo,
       COUNT(DISTINCT puesto) AS valores_distintos,
       SUM(puesto IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_puesto WHERE sk_puesto <> 0;

-- dim_departamento: 6 miembros reales + 1 desconocido
SELECT 'dim_departamento' AS dimension, 'codigo' AS atributo,
       COUNT(DISTINCT codigo) AS valores_distintos,
       SUM(codigo IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_departamento WHERE sk_departamento <> 0
UNION ALL
SELECT 'dim_departamento' AS dimension, 'nombre' AS atributo,
       COUNT(DISTINCT nombre) AS valores_distintos,
       SUM(nombre IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT nombre) AS detalle
FROM dim_departamento WHERE sk_departamento <> 0
UNION ALL
SELECT 'dim_departamento' AS dimension, 'objetivo' AS atributo,
       COUNT(DISTINCT objetivo) AS valores_distintos,
       SUM(objetivo IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_departamento WHERE sk_departamento <> 0
UNION ALL
SELECT 'dim_departamento' AS dimension, 'responsable' AS atributo,
       COUNT(DISTINCT responsable) AS valores_distintos,
       SUM(responsable IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT responsable) AS detalle
FROM dim_departamento WHERE sk_departamento <> 0
UNION ALL
SELECT 'dim_departamento' AS dimension, 'centro_costos' AS atributo,
       COUNT(DISTINCT centro_costos) AS valores_distintos,
       SUM(centro_costos IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT centro_costos) AS detalle
FROM dim_departamento WHERE sk_departamento <> 0
UNION ALL
SELECT 'dim_departamento' AS dimension, 'estatus' AS atributo,
       COUNT(DISTINCT estatus) AS valores_distintos,
       SUM(estatus IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT estatus) AS detalle
FROM dim_departamento WHERE sk_departamento <> 0;

-- dim_cliente: 8 miembros reales + 1 desconocido
SELECT 'dim_cliente' AS dimension, 'id_cliente' AS atributo,
       COUNT(DISTINCT id_cliente) AS valores_distintos,
       SUM(id_cliente IS NULL) AS nulos,
       MIN(id_cliente) AS minimo, MAX(id_cliente) AS maximo,
       GROUP_CONCAT(DISTINCT id_cliente) AS detalle
FROM dim_cliente WHERE sk_cliente <> 0
UNION ALL
SELECT 'dim_cliente' AS dimension, 'codigo_cliente' AS atributo,
       COUNT(DISTINCT codigo_cliente) AS valores_distintos,
       SUM(codigo_cliente IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT codigo_cliente) AS detalle
FROM dim_cliente WHERE sk_cliente <> 0
UNION ALL
SELECT 'dim_cliente' AS dimension, 'cliente' AS atributo,
       COUNT(DISTINCT cliente) AS valores_distintos,
       SUM(cliente IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_cliente WHERE sk_cliente <> 0
UNION ALL
SELECT 'dim_cliente' AS dimension, 'industria' AS atributo,
       COUNT(DISTINCT industria) AS valores_distintos,
       SUM(industria IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT industria) AS detalle
FROM dim_cliente WHERE sk_cliente <> 0
UNION ALL
SELECT 'dim_cliente' AS dimension, 'ciudad' AS atributo,
       COUNT(DISTINCT ciudad) AS valores_distintos,
       SUM(ciudad IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_cliente WHERE sk_cliente <> 0
UNION ALL
SELECT 'dim_cliente' AS dimension, 'estado' AS atributo,
       COUNT(DISTINCT estado) AS valores_distintos,
       SUM(estado IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT estado) AS detalle
FROM dim_cliente WHERE sk_cliente <> 0
UNION ALL
SELECT 'dim_cliente' AS dimension, 'pais' AS atributo,
       COUNT(DISTINCT pais) AS valores_distintos,
       SUM(pais IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT pais) AS detalle
FROM dim_cliente WHERE sk_cliente <> 0
UNION ALL
SELECT 'dim_cliente' AS dimension, 'contacto_nom' AS atributo,
       COUNT(DISTINCT contacto_nom) AS valores_distintos,
       SUM(contacto_nom IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_cliente WHERE sk_cliente <> 0
UNION ALL
SELECT 'dim_cliente' AS dimension, 'estatus' AS atributo,
       COUNT(DISTINCT estatus) AS valores_distintos,
       SUM(estatus IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT estatus) AS detalle
FROM dim_cliente WHERE sk_cliente <> 0
UNION ALL
SELECT 'dim_cliente' AS dimension, 'n_proyectos' AS atributo,
       COUNT(DISTINCT n_proyectos) AS valores_distintos,
       SUM(n_proyectos IS NULL) AS nulos,
       MIN(n_proyectos) AS minimo, MAX(n_proyectos) AS maximo,
       GROUP_CONCAT(DISTINCT n_proyectos) AS detalle
FROM dim_cliente WHERE sk_cliente <> 0;

-- dim_proyecto: 12 miembros reales + 1 desconocido
SELECT 'dim_proyecto' AS dimension, 'id_proyecto' AS atributo,
       COUNT(DISTINCT id_proyecto) AS valores_distintos,
       SUM(id_proyecto IS NULL) AS nulos,
       MIN(id_proyecto) AS minimo, MAX(id_proyecto) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'llave_proyecto' AS atributo,
       COUNT(DISTINCT llave_proyecto) AS valores_distintos,
       SUM(llave_proyecto IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'proyecto' AS atributo,
       COUNT(DISTINCT proyecto) AS valores_distintos,
       SUM(proyecto IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'cliente' AS atributo,
       COUNT(DISTINCT cliente) AS valores_distintos,
       SUM(cliente IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'fecha_inicio' AS atributo,
       COUNT(DISTINCT fecha_inicio) AS valores_distintos,
       SUM(fecha_inicio IS NULL) AS nulos,
       MIN(fecha_inicio) AS minimo, MAX(fecha_inicio) AS maximo,
       GROUP_CONCAT(DISTINCT fecha_inicio) AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'fecha_fin' AS atributo,
       COUNT(DISTINCT fecha_fin) AS valores_distintos,
       SUM(fecha_fin IS NULL) AS nulos,
       MIN(fecha_fin) AS minimo, MAX(fecha_fin) AS maximo,
       GROUP_CONCAT(DISTINCT fecha_fin) AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'estatus' AS atributo,
       COUNT(DISTINCT estatus) AS valores_distintos,
       SUM(estatus IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT estatus) AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'resp_cli' AS atributo,
       COUNT(DISTINCT resp_cli) AS valores_distintos,
       SUM(resp_cli IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'pm_otc' AS atributo,
       COUNT(DISTINCT pm_otc) AS valores_distintos,
       SUM(pm_otc IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'version_scd' AS atributo,
       COUNT(DISTINCT version_scd) AS valores_distintos,
       SUM(version_scd IS NULL) AS nulos,
       MIN(version_scd) AS minimo, MAX(version_scd) AS maximo,
       GROUP_CONCAT(DISTINCT version_scd) AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0
UNION ALL
SELECT 'dim_proyecto' AS dimension, 'es_actual' AS atributo,
       COUNT(DISTINCT es_actual) AS valores_distintos,
       SUM(es_actual IS NULL) AS nulos,
       MIN(es_actual) AS minimo, MAX(es_actual) AS maximo,
       GROUP_CONCAT(DISTINCT es_actual) AS detalle
FROM dim_proyecto WHERE sk_proyecto <> 0;

-- dim_rol: 1 miembros reales + 1 desconocido
SELECT 'dim_rol' AS dimension, 'rol_asignado' AS atributo,
       COUNT(DISTINCT rol_asignado) AS valores_distintos,
       SUM(rol_asignado IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT rol_asignado) AS detalle
FROM dim_rol WHERE sk_rol <> 0;

-- dim_habilidad: 71 miembros reales + 1 desconocido
SELECT 'dim_habilidad' AS dimension, 'cod_habilidad' AS atributo,
       COUNT(DISTINCT cod_habilidad) AS valores_distintos,
       SUM(cod_habilidad IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_habilidad WHERE sk_habilidad <> 0
UNION ALL
SELECT 'dim_habilidad' AS dimension, 'descripcion' AS atributo,
       COUNT(DISTINCT descripcion) AS valores_distintos,
       SUM(descripcion IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_habilidad WHERE sk_habilidad <> 0
UNION ALL
SELECT 'dim_habilidad' AS dimension, 'descripcion_unica' AS atributo,
       COUNT(DISTINCT descripcion_unica) AS valores_distintos,
       SUM(descripcion_unica IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_habilidad WHERE sk_habilidad <> 0
UNION ALL
SELECT 'dim_habilidad' AS dimension, 'tecnologia' AS atributo,
       COUNT(DISTINCT tecnologia) AS valores_distintos,
       SUM(tecnologia IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT tecnologia) AS detalle
FROM dim_habilidad WHERE sk_habilidad <> 0
UNION ALL
SELECT 'dim_habilidad' AS dimension, 'tipo' AS atributo,
       COUNT(DISTINCT tipo) AS valores_distintos,
       SUM(tipo IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT tipo) AS detalle
FROM dim_habilidad WHERE sk_habilidad <> 0
UNION ALL
SELECT 'dim_habilidad' AS dimension, 'estatus' AS atributo,
       COUNT(DISTINCT estatus) AS valores_distintos,
       SUM(estatus IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT estatus) AS detalle
FROM dim_habilidad WHERE sk_habilidad <> 0
UNION ALL
SELECT 'dim_habilidad' AS dimension, 'descripcion_repetida' AS atributo,
       COUNT(DISTINCT descripcion_repetida) AS valores_distintos,
       SUM(descripcion_repetida IS NULL) AS nulos,
       MIN(descripcion_repetida) AS minimo, MAX(descripcion_repetida) AS maximo,
       GROUP_CONCAT(DISTINCT descripcion_repetida) AS detalle
FROM dim_habilidad WHERE sk_habilidad <> 0;

-- dim_activo: 123 miembros reales + 1 desconocido
SELECT 'dim_activo' AS dimension, 'codigo' AS atributo,
       COUNT(DISTINCT codigo) AS valores_distintos,
       SUM(codigo IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_activo WHERE sk_activo <> 0
UNION ALL
SELECT 'dim_activo' AS dimension, 'desc' AS atributo,
       COUNT(DISTINCT desc) AS valores_distintos,
       SUM(desc IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT desc) AS detalle
FROM dim_activo WHERE sk_activo <> 0
UNION ALL
SELECT 'dim_activo' AS dimension, 'tipo' AS atributo,
       COUNT(DISTINCT tipo) AS valores_distintos,
       SUM(tipo IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT tipo) AS detalle
FROM dim_activo WHERE sk_activo <> 0
UNION ALL
SELECT 'dim_activo' AS dimension, 'marca' AS atributo,
       COUNT(DISTINCT marca) AS valores_distintos,
       SUM(marca IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT marca) AS detalle
FROM dim_activo WHERE sk_activo <> 0
UNION ALL
SELECT 'dim_activo' AS dimension, 'modelo' AS atributo,
       COUNT(DISTINCT modelo) AS valores_distintos,
       SUM(modelo IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_activo WHERE sk_activo <> 0
UNION ALL
SELECT 'dim_activo' AS dimension, 'serie' AS atributo,
       COUNT(DISTINCT serie) AS valores_distintos,
       SUM(serie IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_activo WHERE sk_activo <> 0
UNION ALL
SELECT 'dim_activo' AS dimension, 'proveedor' AS atributo,
       COUNT(DISTINCT proveedor) AS valores_distintos,
       SUM(proveedor IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT proveedor) AS detalle
FROM dim_activo WHERE sk_activo <> 0
UNION ALL
SELECT 'dim_activo' AS dimension, 'fcompra' AS atributo,
       COUNT(DISTINCT fcompra) AS valores_distintos,
       SUM(fcompra IS NULL) AS nulos,
       MIN(fcompra) AS minimo, MAX(fcompra) AS maximo,
       'Más de 10 valores: se describen en el documento' AS detalle
FROM dim_activo WHERE sk_activo <> 0
UNION ALL
SELECT 'dim_activo' AS dimension, 'estatus' AS atributo,
       COUNT(DISTINCT estatus) AS valores_distintos,
       SUM(estatus IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       GROUP_CONCAT(DISTINCT estatus) AS detalle
FROM dim_activo WHERE sk_activo <> 0
UNION ALL
SELECT 'dim_activo' AS dimension, 'notas' AS atributo,
       COUNT(DISTINCT notas) AS valores_distintos,
       SUM(notas IS NULL) AS nulos,
       NULL AS minimo, NULL AS maximo,
       'Texto libre: se describe en el documento' AS detalle
FROM dim_activo WHERE sk_activo <> 0;
