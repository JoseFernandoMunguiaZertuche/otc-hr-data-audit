/* Tablero de consulta para Dirección · Etapa 5
   Sin dependencias: lee window.DATOS y dibuja con HTML, CSS y SVG. */

const D = window.DATOS;
const S = D.resumen;
const $ = (sel, raiz = document) => raiz.querySelector(sel);

const esc = (v) => String(v ?? "")
  .replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;").replaceAll("'", "&#039;");

const nf = new Intl.NumberFormat("es-MX");
const num = (v) => (v === null || v === undefined || Number.isNaN(Number(v))) ? "—" : nf.format(Number(v));
const money = (v, decimales = 0) => (v === null || v === undefined || Number.isNaN(Number(v)))
  ? "—"
  : new Intl.NumberFormat("es-MX", {
      style: "currency", currency: "MXN",
      minimumFractionDigits: decimales, maximumFractionDigits: decimales,
    }).format(Number(v));
const corto = (v) => {
  if (v === null || v === undefined) return "—";
  const n = Number(v);
  if (Math.abs(n) >= 1_000_000) return `$${(n / 1_000_000).toFixed(2)} M`;
  if (Math.abs(n) >= 1_000) return `$${(n / 1_000).toFixed(1)} k`;
  return money(n);
};
const pct = (v, d = 1) => (v === null || v === undefined || Number.isNaN(Number(v))) ? "—" : `${Number(v).toFixed(d)}%`;
const fecha = (v) => {
  if (!v) return "—";
  const f = new Date(`${String(v).slice(0, 10)}T00:00:00`);
  if (Number.isNaN(f.getTime())) return esc(v);
  return f.toLocaleDateString("es-MX", { day: "2-digit", month: "short", year: "numeric" });
};
const R = (nombre) => (D.resultados[nombre]?.filas) || [];
const U = (nombre) => R(nombre)[0] || {};

function tabla(cabeceras, filas, opciones = {}) {
  const clases = opciones.clases || [];
  const cuerpo = filas.length
    ? filas.map((f) => `<tr>${f.map((c, i) => `<td class="${clases[i] || ""}">${c}</td>`).join("")}</tr>`).join("")
    : `<tr><td colspan="${cabeceras.length}" class="vacio">Sin registros.</td></tr>`;
  return `<div class="tabla-envoltura"><table class="tabla">
    <thead><tr>${cabeceras.map((c) => `<th>${c}</th>`).join("")}</tr></thead>
    <tbody>${cuerpo}</tbody></table></div>`;
}

function barras(filas, etiqueta, valor, opciones = {}) {
  const formato = opciones.formato || ((v) => num(v));
  const clase = opciones.clase || "";
  const max = Math.max(...filas.map((f) => Number(f[valor]) || 0), 1);
  return `<div class="grafica">${filas.map((f) => {
    const v = Number(f[valor]) || 0;
    return `<div class="fila-barra">
      <span class="etiqueta" title="${esc(f[etiqueta])}">${esc(f[etiqueta])}</span>
      <span class="pista"><span class="relleno ${clase}" style="width:${Math.max(1, (v / max) * 100).toFixed(1)}%"></span></span>
      <span class="valor">${formato(v, f)}</span>
    </div>`;
  }).join("")}</div>`;
}

function columnas(filas, etiqueta, valor, opciones = {}) {
  const max = Math.max(...filas.map((f) => Number(f[valor]) || 0), 1);
  return `<div class="barras-verticales">${filas.map((f) => {
    const v = Number(f[valor]) || 0;
    return `<div class="barra-vertical" title="${esc(f[etiqueta])}: ${num(v)}">
      <span class="valor">${opciones.formato ? opciones.formato(v) : num(v)}</span>
      <span class="columna" style="height:${Math.max(3, (v / max) * 150).toFixed(0)}px;${opciones.color ? `background:${opciones.color};` : ""}"></span>
      <span class="etiqueta">${esc(f[etiqueta])}</span>
    </div>`;
  }).join("")}</div>`;
}

function ficha(etiqueta, valor, detalle = "", tono = "") {
  return `<div class="ficha"><span class="etiqueta">${etiqueta}</span><span class="valor ${tono}">${valor}</span><span class="detalle">${detalle}</span></div>`;
}

function encabezado(titulo, texto) {
  return `<div class="encabezado-seccion"><div><h2>${titulo}</h2><p>${texto}</p></div></div>`;
}

function sql(nombre, titulo = "Ver consulta SQL") {
  const consulta = D.resultados[nombre]?.sql;
  if (!consulta) return "";
  return `<details class="sql"><summary>${titulo}</summary><pre>${esc(consulta)}</pre></details>`;
}

const aviso = (html, tipo = "") => `<div class="aviso ${tipo}">${html}</div>`;

/* ------------------------------------------------------------------ */
/* Resumen                                                             */
/* ------------------------------------------------------------------ */

function vistaResumen() {
  const banca = S.banca_plantilla;
  const asignados = S.colaboradores_asignados;
  const activos = S.activos;
  const familiares = S.familiares_activos;
  const pctAsignado = S.pct_nomina_asignada;
  const pctBanca = S.pct_nomina_banca;
  const pctFam = S.pct_nomina_familiares;

  return `<section class="seccion">
    <div class="rejilla rejilla-hero">
      <div class="tarjeta">
        <div class="heroe">
          <div class="dona" style="--p:${S.utilizacion_headcount_pct}">
            <div><strong>${pct(S.utilizacion_headcount_pct, 1)}</strong><span>utilización</span></div>
          </div>
          <div class="heroe-texto">
            <p class="rotulo">La pregunta central</p>
            <h3>${asignados} de ${activos} activos están en un proyecto.</h3>
            <p>La utilización sobre la plantilla (sin los dos familiares de seguro) es de <b>${pct(S.utilizacion_plantilla_pct, 1)}</b>. Quedan <b>${banca} personas de plantilla en banca</b> y <b>${familiares}</b> familiares sin asignación.</p>
            <div class="barra-apilada" aria-label="Reparto de la plantilla activa">
              <span style="width:${(asignados / activos) * 100}%;background:var(--teal)"></span>
              <span style="width:${(banca / activos) * 100}%;background:var(--ambar)"></span>
              <span style="width:${(familiares / activos) * 100}%;background:#94a3b8"></span>
            </div>
            <div class="leyenda">
              <span><i style="background:var(--teal)"></i>${asignados} con asignación</span>
              <span><i style="background:var(--ambar)"></i>${banca} en banca</span>
              <span><i style="background:#94a3b8"></i>${familiares} familiares</span>
            </div>
          </div>
        </div>
      </div>

      <div class="tarjeta tarjeta-oscura">
        <p class="rotulo">Costo mensual de la nómina activa</p>
        <p class="cifra">${money(S.nomina_activa)}</p>
        <p class="nota">${money(S.costo_asignado_unico)} asignado (${pct(pctAsignado)}) y ${money(S.costo_sin_asignacion)} sin asignación (${pct(pctBanca + pctFam)}).</p>
        <div class="barra-apilada" style="margin-top:18px">
          <span style="width:${pctAsignado}%;background:#5eead4"></span>
          <span style="width:${pctBanca}%;background:#fbbf24"></span>
          <span style="width:${pctFam}%;background:#cbd5e1"></span>
        </div>
        <div class="leyenda">
          <span style="color:rgba(255,255,255,.78)"><i style="background:#5eead4"></i>Asignado ${pct(pctAsignado)}</span>
          <span style="color:rgba(255,255,255,.78)"><i style="background:#fbbf24"></i>Banca ${pct(pctBanca)}</span>
          <span style="color:rgba(255,255,255,.78)"><i style="background:#cbd5e1"></i>Familiares ${pct(pctFam)}</span>
        </div>
        <p class="nota" style="margin-top:14px">El hecho suma ${money(S.costo_asignado_filas)} porque una persona tiene dos asignaciones al 100%; el costo único evita duplicarla.</p>
      </div>
    </div>

    <div class="rejilla rejilla-4">
      ${ficha("Colaboradores", num(S.colaboradores), `${num(S.activos)} activos · ${num(S.bajas)} bajas`)}
      ${ficha("Costo de la banca", corto(S.costo_banca), `${num(S.banca_plantilla)} personas de plantilla`, "tono-ambar")}
      ${ficha("Asignaciones", num(S.asignaciones), `${num(S.clientes)} clientes · ${num(S.proyectos)} proyectos`)}
      ${ficha("Equipo por recuperar", money(S.costo_por_recuperar), `${num(S.equipos_por_recuperar)} equipos de personas dadas de baja`, "tono-rojo")}
    </div>

    <div class="dos-columnas">
      <div class="tarjeta">
        <p class="rotulo">Alertas que impiden decidir</p>
        <div class="lista-alertas" style="margin-top:12px">
          <div class="alerta"><span class="icono">!</span><div><b>${num(S.asignaciones_sin_rol)} de ${num(S.asignaciones)} asignaciones no tienen rol.</b> Sin rol no se puede comparar el puesto con la necesidad del proyecto.</div></div>
          <div class="alerta"><span class="icono">!</span><div><b>${num(S.asignaciones_sin_inicio)} asignaciones no tienen fecha de inicio real.</b> La fuente traía 1990-01-01; sin inicio no hay duración ni antigüedad en proyecto.</div></div>
          <div class="alerta"><span class="icono">!</span><div><b>${num(S.activos_sin_costo)} de ${num(S.activos_inventario)} activos no tienen costo.</b> El inventario conocido de ${money(S.costo_inventario)} es un piso, no el total.</div></div>
          <div class="alerta"><span class="icono">!</span><div><b>${num(R("q7_resumen")[0]?.bajas_sin_fecha)} bajas no tienen fecha.</b> La rotación por periodo solo se puede calcular en ${num(S.bajas - (R("q7_resumen")[0]?.bajas_sin_fecha || 0))} de ${num(S.bajas)} salidas.</div></div>
          <div class="alerta"><span class="icono">!</span><div><b>Ningún expediente está completo.</b> El promedio activo es ${pct(R("q9_expediente")[0]?.pct_expediente_promedio)} y ${num(R("q9_expediente")[0]?.sin_departamento)} activos no tienen departamento.</div></div>
        </div>
      </div>

      <div class="tarjeta">
        <p class="rotulo">Cómo leer este tablero</p>
        <div class="lista-alertas" style="margin-top:12px">
          <div class="alerta" style="background:#f1f8f2;border-color:#cde5d3;color:#1d4d2a"><span class="icono" style="background:#d7ecd9;color:#166534">✓</span><div><b>Todo sale de las tablas acondicionadas.</b> No hay cifras inventadas ni imputadas: los huecos se muestran como huecos.</div></div>
          <div class="alerta" style="background:#f1f8f2;border-color:#cde5d3;color:#1d4d2a"><span class="icono" style="background:#d7ecd9;color:#166534">✓</span><div><b>Cada número tiene su base.</b> La utilización se muestra sobre headcount y sobre plantilla; el costo asignado se muestra único y por fila del hecho.</div></div>
          <div class="alerta" style="background:#f1f8f2;border-color:#cde5d3;color:#1d4d2a"><span class="icono" style="background:#d7ecd9;color:#166534">✓</span><div><b>El margen está bloqueado, no en cero.</b> Faltan tarifas y horas; el tablero lo dice en lugar de estimarlo.</div></div>
        </div>
      </div>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Las nueve dimensiones del modelo</p>
      <div class="chips" style="margin-top:12px">
        ${D.modelo.dimensiones.map((d) => `<span class="chip"><b>${esc(d.nombre.replace("dim_", ""))}</b> ${num(d.filas)}</span>`).join("")}
      </div>
      <p class="nota">Tiempo y Colaborador son conformadas: las comparten los tres hechos. El detalle de valores distintos está en la pestaña <b>Dimensiones</b>.</p>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Utilización                                                         */
/* ------------------------------------------------------------------ */

function vistaUtilizacion() {
  const q1 = U("q1_resumen");
  const banca = R("q1_banca_por_puesto");
  const clientes = R("q1_concentracion_cliente");
  const detalle = R("q1_banca_detalle");

  return `<section class="seccion">
    ${encabezado("Utilización y banca", "Quién está en proyecto, quién no y cuánto tiempo lleva así. La banca se mide sobre la plantilla; los familiares de seguro se reportan aparte.")}
    <div class="rejilla rejilla-4">
      ${ficha("Asignados", `${num(q1.asignados)} / ${num(q1.activos)}`, pct(q1.utilizacion_headcount_pct) + " del headcount", "tono-teal")}
      ${ficha("Banca de plantilla", num(q1.banca_plantilla), pct(q1.utilizacion_plantilla_pct) + " de utilización sobre plantilla", "tono-ambar")}
      ${ficha("Sin asignación total", num(q1.sin_asignacion_total), `${num(q1.familiares)} familiares incluidos`, "tono-rojo")}
      ${ficha("Sobreasignados", num(S.sobreasignados), "una persona con dos asignaciones al 100%", "tono-rojo")}
    </div>

    ${aviso(`<b>Dos denominadores, una misma realidad.</b> ${num(q1.asignados)} de ${num(q1.activos)} activos (${pct(q1.utilizacion_headcount_pct)}) y ${num(q1.asignados)} de ${num(q1.plantilla_activa)} de plantilla (${pct(q1.utilizacion_plantilla_pct)}). La diferencia son dos familiares de seguro que no cuentan como plantilla.` )}

    <div class="dos-columnas">
      <div class="tarjeta">
        <p class="rotulo">Banca por puesto</p>
        <p class="nota">Costo mensual de las 43 personas de plantilla sin asignación. Quince no tienen puesto capturado y concentran ${money(banca[0]?.costo_mensual)}.</p>
        ${barras(banca.slice(0, 10), "puesto", "personas", { formato: (v) => `${num(v)} pers.` })}
      </div>
      <div class="tarjeta">
        <p class="rotulo">Concentración por cliente</p>
        <p class="nota">De los 30 asignados, 23 están en Metalsa. Es la dependencia comercial más alta del corte.</p>
        ${barras(clientes, "cliente", "personas_asignadas", { formato: (v) => `${num(v)} pers.` })}
        <div class="aviso" style="margin-top:14px">Metalsa concentra <b>${pct(clientes[0]?.pct_de_asignados)}</b> de los asignados y <b>${pct(R("q3_por_cliente")[0]?.pct_del_costo_asignado)}</b> del costo asignado.</div>
      </div>
    </div>

    <div class="tarjeta">
      <div class="buscador">
        <label for="buscar-banca" class="rotulo" style="margin:0">Buscar en la banca</label>
        <input id="buscar-banca" type="search" placeholder="Puesto, ID o departamento…" autocomplete="off">
        <span class="nota" style="margin:0">Se muestran los 15 con más días; el detalle completo está en el CSV y en la consulta.</span>
      </div>
      <div id="tabla-banca">
        ${tabla(["ID", "Puesto", "Departamento", "Días en banca", "Costo mensual"], detalle.map((f) => [
          `<span class="fuerte">${esc(f.id_colaborador)}</span>`,
          esc(f.puesto),
          esc(f.departamento),
          `<span class="num">${num(f.dias_en_banca)}</span>`,
          `<span class="num">${money(f.costo_mensual)}</span>`,
        ]), { clases: ["", "", "", "num", "num"] })}
      </div>
      <p class="nota">Días en banca = tiempo desde la última asignación o, si no hay historial, desde la incorporación. Es una cota superior, no una fecha cierta.</p>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Consultas de la pregunta 1</p>
      <div style="display:grid;gap:9px;margin-top:12px">
        ${sql("q1_resumen", "Resumen de utilización")}
        ${sql("q1_banca_por_puesto", "Banca por puesto")}
        ${sql("q1_concentracion_cliente", "Concentración por cliente")}
      </div>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Costos                                                              */
/* ------------------------------------------------------------------ */

function vistaCostos() {
  const q3 = U("q3_costos");
  const porCliente = R("q3_por_cliente");
  const porPuesto = R("q4_costo_hora_puesto");
  const proyectos = R("q5_costo_por_proyecto");
  const q4 = U("q4_cobertura");

  return `<section class="seccion">
    ${encabezado("Costos y margen", "Cuánto cuesta la nómina, cuánto está asignado y cuánto cuesta la gente sin proyecto. El margen no se estima: se marca como bloqueado.")}
    <div class="rejilla rejilla-4">
      ${ficha("Nómina activa", corto(q3.nomina_activa), money(q3.nomina_activa, 2))}
      ${ficha("Costo asignado", corto(q3.costo_asignado_unico), pct(q3.pct_nomina_asignada) + " de la nómina", "tono-teal")}
      ${ficha("Banca de plantilla", corto(q3.costo_banca_plantilla), `${num(q3.banca_plantilla)} personas · ${pct(q3.pct_nomina_banca)}`, "tono-ambar")}
      ${ficha("Familiares", money(q3.costo_familiares), `${num(q3.sin_asignacion_total - q3.banca_plantilla)} personas fuera de plantilla`, "tono-humo")}
    </div>

    <div class="tarjeta">
      <p class="rotulo">Reparto del costo mensual</p>
      <div class="barra-apilada" style="height:20px;margin-top:14px">
        <span style="width:${q3.pct_nomina_asignada}%;background:var(--teal)"></span>
        <span style="width:${q3.pct_nomina_banca}%;background:var(--ambar)"></span>
        <span style="width:${q3.pct_nomina_familiares}%;background:#94a3b8"></span>
      </div>
      <div class="leyenda">
        <span><i style="background:var(--teal)"></i>Asignado ${money(q3.costo_asignado_unico)} (${pct(q3.pct_nomina_asignada)})</span>
        <span><i style="background:var(--ambar)"></i>Banca ${money(q3.costo_banca_plantilla)} (${pct(q3.pct_nomina_banca)})</span>
        <span><i style="background:#94a3b8"></i>Familiares ${money(q3.costo_familiares)} (${pct(q3.pct_nomina_familiares)})</span>
      </div>
      <p class="nota">La suma cierra contra ${money(q3.nomina_activa)}. El hecho de asignación suma ${money(q3.costo_asignado_filas)} porque la persona sobreasignada aparece dos veces; el costo único es ${money(q3.costo_asignado_unico)}.</p>
    </div>

    <div class="dos-columnas">
      <div class="tarjeta">
        <p class="rotulo">Costo asignado por cliente</p>
        ${tabla(["Cliente", "Personas", "Costo mensual", "% del asignado"], porCliente.map((f) => [
          `<span class="fuerte">${esc(f.cliente)}</span>`, `<span class="num">${num(f.personas)}</span>`,
          `<span class="num">${money(f.costo_mensual_asignado)}</span>`, `<span class="num">${pct(f.pct_del_costo_asignado)}</span>`,
        ]), { clases: ["", "num", "num", "num"] })}
      </div>
      <div class="tarjeta">
        <p class="rotulo">Costo por proyecto</p>
        ${tabla(["Proyecto", "Personas", "Costo mensual"], proyectos.map((f) => [
          `<span class="fuerte">${esc(f.proyecto)}</span><span class="sub">${esc(f.cliente)}</span>`,
          `<span class="num">${num(f.personas)}</span>`, `<span class="num">${money(f.costo_mensual_asignado)}</span>`,
        ]), { clases: ["", "num", "num"] })}
      </div>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Costo por hora por puesto</p>
      <p class="nota">El costo hora sale del sueldo integrado entre 160 horas, multiplicado por la dedicación. Catorce asignaciones no tienen puesto: cuestan ${money(q4?.sin_puesto ? porPuesto.find((f) => f.puesto === "No especificado")?.costo_mensual_asignado : 0)} y distorsionan el promedio.</p>
      ${tabla(["Puesto", "Asignaciones", "Personas", "Costo hora promedio", "Mínimo", "Máximo", "Costo mensual"], porPuesto.map((f) => [
        `<span class="fuerte">${esc(f.puesto)}</span>`, `<span class="num">${num(f.asignaciones)}</span>`,
        `<span class="num">${num(f.personas)}</span>`, `<span class="num">${money(f.costo_hora_promedio, 2)}</span>`,
        `<span class="num">${money(f.costo_hora_minimo, 2)}</span>`, `<span class="num">${money(f.costo_hora_maximo, 2)}</span>`,
        `<span class="num">${money(f.costo_mensual_asignado)}</span>`,
      ]), { clases: ["", "num", "num", "num", "num", "num", "num"] })}
    </div>

    ${aviso(`<b>Margen bloqueado.</b> ${num(q4?.asignaciones || 31)} asignaciones tienen costo, pero <b>0</b> tienen ingreso facturable y <b>0</b> tienen margen. Faltan tarifas por proyecto y horas facturables; el tablero no inventa un ingreso.`, "aviso-rojo")}

    <div class="tarjeta">
      <p class="rotulo">Consultas de costo y margen</p>
      <div style="display:grid;gap:9px;margin-top:12px">
        ${sql("q3_costos", "Reparto de la nómina")}
        ${sql("q4_costo_hora_puesto", "Costo por hora por puesto")}
        ${sql("q5_bloqueo", "Verificación del margen bloqueado")}
      </div>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Tiempo                                                              */
/* ------------------------------------------------------------------ */

function vistaTiempo() {
  const q2 = U("q2_resumen");
  const filas = R("q2_vencimientos");
  return `<section class="seccion">
    ${encabezado("Asignaciones por terminar", "Quiénes terminan pronto, en qué proyecto y en qué cliente. Solo 7 de 31 asignaciones tienen fecha de fin; las otras 24 quedan abiertas.")}
    <div class="rejilla rejilla-4">
      ${ficha("Con fecha de fin", num(q2.con_fecha_fin), `de ${num(q2.asignaciones_totales)} asignaciones`, "tono-teal")}
      ${ficha("Sin fecha de fin", num(q2.sin_fecha_fin), "no se puede saber cuándo terminan", "tono-rojo")}
      ${ficha("Vencen en 60 días", num(q2.vencen_60_dias), "3 personas en Marazzi", "tono-ambar")}
      ${ficha("Vencen en 90 días", num(q2.vencen_90_dias), "ninguna en la ventana 61–90", "tono-humo")}
    </div>

    ${aviso(`<b>La ventana de 30 días está vacía, no sana.</b> Hay 3 asignaciones a 42 días (Marazzi, 2027-01-01) y 4 con más de 90 días. Las otras 24 no tienen fecha de fin, así que la alerta de vencimiento solo cubre 7 de 31.` )}

    <div class="tarjeta">
      <p class="rotulo">Calendario de vencimientos</p>
      ${tabla(["ID", "Colaborador", "Cliente", "Proyecto", "Inicio", "Fin", "Días", "Ventana"], filas.map((f) => [
        `<span class="fuerte">${esc(f.id_asignacion)}</span>`, esc(f.id_colaborador), esc(f.cliente), esc(f.proyecto),
        fecha(f.fecha_inicio), fecha(f.fecha_fin), `<span class="num">${num(f.dias_para_fin)}</span>`,
        `<span class="chip">${esc(f.ventana)}</span>`,
      ]), { clases: ["", "", "", "", "", "", "num", ""] })}
    </div>

    <div class="tarjeta">
      <p class="rotulo">Consulta de la pregunta 2</p>
      <div style="display:grid;gap:9px;margin-top:12px">
        ${sql("q2_vencimientos", "Vencimientos con proyecto y cliente")}
        ${sql("q2_resumen", "Resumen por ventana")}
      </div>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Habilidades                                                         */
/* ------------------------------------------------------------------ */

function vistaHabilidades() {
  const tech = R("q6_tecnologia");
  const niveles = R("q6_niveles");
  const riesgo = R("q6_riesgo");
  const q6 = U("q6_cobertura");
  return `<section class="seccion">
    ${encabezado("Habilidades y personas clave", "Qué habilidades tiene la plantilla, en qué nivel y dónde hay un solo experto o ninguno. La matriz cubre 54 de 75 activos.")}
    <div class="rejilla rejilla-4">
      ${ficha("Habilidades", num(q6.habilidades_catalogo), "catálogo activo")}
      ${ficha("Evaluaciones", num(q6.evaluaciones_totales), `${num(q6.evaluaciones_sin_persona)} sin colaborador`, "tono-ambar")}
      ${ficha("Activos con matriz", `${num(q6.con_matriz)} / ${num(q6.activos)}`, `${num(q6.activos_sin_matriz)} sin ninguna evaluación`, "tono-rojo")}
      ${ficha("Habilidades en riesgo", num(riesgo.length), "≤ 1 experto o sin evaluación", "tono-ambar")}
    </div>

    <div class="dos-columnas">
      <div class="tarjeta">
        <p class="rotulo">Evaluaciones por tecnología</p>
        ${barras(tech, "tecnologia", "evaluaciones", { formato: (v, f) => `${num(v)} · ${num(f.habilidades)} hab.` })}
        <p class="nota">Oracle EBS concentra 645 evaluaciones y 30 habilidades; Cloud, 349 y 17. Las dos habilidades de "Otros" no tienen evaluación.</p>
      </div>
      <div class="tarjeta">
        <p class="rotulo">Distribución por nivel</p>
        ${barras(niveles, "nivel_txt", "evaluaciones", { formato: (v, f) => `${num(v)} (${pct(f.pct)})` })}
        <p class="nota">El 44.9% de las evaluaciones son Básico y solo 16.0% Experto. La matriz mide presencia, no certificación vigente.</p>
      </div>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Habilidades con un solo experto o ninguno</p>
      ${tabla(["Código", "Habilidad", "Tecnología", "Evaluados", "Expertos"], riesgo.map((f) => [
        `<span class="fuerte">${esc(f.cod_habilidad)}</span>`, esc(f.descripcion_unica), esc(f.tecnologia),
        `<span class="num">${num(f.evaluados)}</span>`,
        `<span class="num ${f.expertos === 0 ? "tono-rojo" : "tono-ambar"}">${num(f.expertos)}</span>`,
      ]), { clases: ["", "", "", "num", "num"] })}
      <p class="nota">Tres habilidades evaluadas no tienen ningún experto (Opm, Fuse, Taleo); cuatro tienen uno; dos de "Otros" no tienen evaluación. La regla de riesgo es ≤ 1 experto.</p>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Consulta de la pregunta 6</p>
      <div style="display:grid;gap:9px;margin-top:12px">
        ${sql("q6_tecnologia", "Cobertura por tecnología")}
        ${sql("q6_riesgo", "Habilidades en riesgo")}
      </div>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Rotación                                                            */
/* ------------------------------------------------------------------ */

function vistaRotacion() {
  const q7 = U("q7_resumen");
  const cohortes = R("q7_cohortes").filter((f) => Number(f.anio_ingreso) >= 2021).reverse();
  const nominas = R("q7_por_nomina");
  const recientes = R("q7_cohortes").filter((f) => Number(f.anio_ingreso) >= 2024);
  const ingresos = recientes.reduce((a, f) => a + Number(f.ingresos), 0);
  const bajas = recientes.reduce((a, f) => a + Number(f.bajas), 0);
  return `<section class="seccion">
    ${encabezado("Rotación y permanencia", "Cuántas personas salen, en qué cohorte y con qué esquema de nómina. La fecha de baja solo existe en 14 de 32 salidas.")}
    <div class="rejilla rejilla-4">
      ${ficha("Bajas", num(q7.bajas), `${pct(q7.pct_bajas)} de 107 registros`, "tono-rojo")}
      ${ficha("Bajas sin fecha", num(q7.bajas_sin_fecha), "no se pueden ubicar en un mes", "tono-ambar")}
      ${ficha("Bajas en el primer año", num(q7.bajas_primer_anio), "de las que tienen antigüedad calculable", "tono-ambar")}
      ${ficha("Permanencia promedio", `${num(q7.antiguedad_promedio_bajas_meses)} meses`, "solo bajas con antigüedad", "tono-humo")}
    </div>

    ${aviso(`<b>${num(bajas)} de ${num(ingresos)} personas que entraron desde 2024 ya salieron (${pct(ingresos ? (bajas / ingresos) * 100 : 0)}).</b> La cohorte 2025 es la más crítica: 12 bajas de 20 ingresos. La cohorte 2026 suma 6 bajas en el primer año.` )}

    <div class="dos-columnas">
      <div class="tarjeta">
        <p class="rotulo">Bajas por cohorte de ingreso</p>
        ${columnas(cohortes, "anio_ingreso", "bajas", { formato: (v) => num(v) })}
        <p class="nota">Cada barra son las bajas de quienes ingresaron ese año, sin importar cuándo salieron. No es una tasa anual de rotación.</p>
      </div>
      <div class="tarjeta">
        <p class="rotulo">Bajas por esquema de nómina</p>
        ${barras(nominas.slice(0, 8), "tipo_nomina", "bajas", { formato: (v) => `${num(v)} bajas` })}
        <p class="nota">MAGNESON-SINDICATO concentra 10 de las 32 bajas; SMR, 7. Seis personas sin esquema capturado están todas de baja.</p>
      </div>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Cohortes recientes</p>
      ${tabla(["Año de ingreso", "Ingresos", "Bajas", "% de baja", "Bajas en primer año", "Permanencia promedio"], cohortes.slice().reverse().map((f) => [
        `<span class="fuerte">${esc(f.anio_ingreso)}</span>`, `<span class="num">${num(f.ingresos)}</span>`,
        `<span class="num">${num(f.bajas)}</span>`, `<span class="num">${pct(f.pct_baja)}</span>`,
        `<span class="num">${num(f.bajas_primer_anio)}</span>`,
        `<span class="num">${f.permanencia_promedio_meses == null ? "—" : `${num(f.permanencia_promedio_meses)} meses`}</span>`,
      ]), { clases: ["", "num", "num", "num", "num", "num"] })}
    </div>

    <div class="tarjeta">
      <p class="rotulo">Consulta de la pregunta 7</p>
      <div style="display:grid;gap:9px;margin-top:12px">
        ${sql("q7_resumen", "Resumen de rotación")}
        ${sql("q7_cohortes", "Cohortes por año de ingreso")}
      </div>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Activos                                                             */
/* ------------------------------------------------------------------ */

function vistaActivos() {
  const q8 = U("q8_resumen");
  const marcas = R("q8_marcas");
  const pendientes = R("q8_pendientes");
  const notas = (D.dimensiones.dim_activo?.columnas?.notas?.valores) || [];
  const noFuncionan = notas.filter((n) => /no funciona|ya no sirve/i.test(n.valor)).reduce((a, n) => a + Number(n.conteo), 0);
  return `<section class="seccion">
    ${encabezado("Inventario y resguardo de activos", "Cuánto vale el equipo, cuánto no tiene costo y qué sigue en manos de personas que ya salieron.")}
    <div class="rejilla rejilla-4">
      ${ficha("Activos", num(q8.activos), "inventario total")}
      ${ficha("Sin costo", num(q8.sin_costo), `${pct((q8.sin_costo / q8.activos) * 100)} del inventario`, "tono-rojo")}
      ${ficha("Sin resguardo", num(q8.sin_resguardo), "no se sabe quién los tiene", "tono-ambar")}
      ${ficha("Por recuperar", num(q8.pendientes_recuperar), money(q8.valor_pendiente_recuperar), "tono-rojo")}
    </div>

    <div class="dos-columnas">
      <div class="tarjeta">
        <p class="rotulo">Equipos por marca</p>
        ${barras(marcas, "marca", "equipos", { formato: (v, f) => `${num(v)} · ${money(f.valor_conocido)}` })}
        <p class="nota">Dell concentra 62 equipos, pero 39 no tienen costo. El valor conocido de ${money(q8.valor_inventario_conocido)} es un piso.</p>
      </div>
      <div class="tarjeta">
        <p class="rotulo">Lo que no se puede valorar</p>
        <div class="lista-alertas" style="margin-top:12px">
          <div class="alerta"><span class="icono">!</span><div><b>${num(q8.sin_costo)} de ${num(q8.activos)} equipos sin costo.</b> No hay base para depreciación ni para el valor real del inventario.</div></div>
          <div class="alerta"><span class="icono">!</span><div><b>${num(q8.sin_resguardo)} equipos sin resguardo.</b> El activo existe, pero no se sabe quién lo tiene.</div></div>
          <div class="alerta"><span class="icono">!</span><div><b>${num(noFuncionan)} equipos marcados como "no funciona" o "ya no sirve" siguen con estatus Activo.</b> Se pueden seguir asignando.</div></div>
        </div>
      </div>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Equipos de personas dadas de baja</p>
      ${tabla(["Activo", "Tipo", "Marca", "Costo", "Colaborador", "Estatus", "Fecha de baja"], pendientes.map((f) => [
        `<span class="fuerte">${esc(f.codigo)}</span>`, esc(f.tipo), esc(f.marca),
        `<span class="num">${money(f.costo)}</span>`, esc(f.id_colaborador),
        `<span class="chip">${esc(f.estatus_colaborador)}</span>`, fecha(f.fecha_baja),
      ]), { clases: ["", "", "", "num", "", "", ""] })}
      <p class="nota">Solo cuatro de los nueve equipos tienen costo; el valor en riesgo de ${money(q8.valor_pendiente_recuperar)} es un mínimo.</p>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Consulta de la pregunta 8</p>
      <div style="display:grid;gap:9px;margin-top:12px">
        ${sql("q8_resumen", "Resumen del inventario")}
        ${sql("q8_pendientes", "Equipos por recuperar")}
      </div>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Expediente                                                          */
/* ------------------------------------------------------------------ */

function vistaExpediente() {
  const q9 = U("q9_expediente");
  const rangos = R("q9_rangos");
  return `<section class="seccion">
    ${encabezado("Expediente y confiabilidad", "El expediente es la base para confiar en los demás indicadores. Ningún activo tiene el expediente completo.")}
    <div class="rejilla rejilla-4">
      ${ficha("Expediente promedio", pct(q9.pct_expediente_promedio), "activos", "tono-ambar")}
      ${ficha("Expedientes completos", num(q9.expedientes_completos), `de ${num(q9.activos)} activos`, "tono-rojo")}
      ${ficha("Sin departamento", num(q9.sin_departamento), "no se puede imputar costo por área", "tono-rojo")}
      ${ficha("Sin puesto", num(q9.sin_puesto), "no se puede analizar por puesto", "tono-ambar")}
    </div>

    <div class="dos-columnas">
      <div class="tarjeta">
        <p class="rotulo">Distribución del expediente</p>
        ${barras(rangos, "rango_expediente", "personas", { formato: (v) => `${num(v)} activos` })}
        <p class="nota">50 activos están entre 50% y 99%; 25 están por debajo de 50%. Ninguno llega a 100%.</p>
      </div>
      <div class="tarjeta">
        <p class="rotulo">Huecos que bloquean el análisis</p>
        <div class="lista-alertas" style="margin-top:12px">
          <div class="alerta"><span class="icono">!</span><div><b>${num(q9.sin_departamento)} sin departamento.</b> El 88.8% del catálogo original; solo se usan 2 de los 6 departamentos.</div></div>
          <div class="alerta"><span class="icono">!</span><div><b>${num(q9.sin_puesto)} sin puesto.</b> El puesto PENDIENTE se nulificó en la Etapa 3; sigue siendo un hueco real.</div></div>
          <div class="alerta"><span class="icono">!</span><div><b>${num(q9.con_contrato)} con contrato registrado.</b> ${num(q9.activos - q9.con_contrato)} activos no tienen contrato en el expediente.</div></div>
          <div class="alerta"><span class="icono">!</span><div><b>${num(q9.sin_sueldo)} sin sueldo.</b> No se puede costear su asignación ni comparar su costo hora.</div></div>
        </div>
      </div>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Consulta de la pregunta 9</p>
      <div style="display:grid;gap:9px;margin-top:12px">
        ${sql("q9_expediente", "Resumen del expediente activo")}
        ${sql("q9_rangos", "Distribución por rango")}
      </div>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Dimensiones                                                         */
/* ------------------------------------------------------------------ */

const NARRATIVA = {
  dim_tiempo: "Calendario completo del modelo. Cubre 2003-01-01 a 2028-12-31 para poder fechar incorporaciones, asignaciones, resguardos y proyectos. La llave es AAAAMMDD y la fila 0 representa 'sin fecha'.",
  dim_colaborador: "La persona y su situación al corte. Es la dimensión más rica y también la más incompleta: 48 de 107 no tienen puesto y 95 no tienen departamento. Conserva sueldo, costo, antigüedad, expediente y banderas de calidad.",
  dim_puesto: "Catálogo de 23 puestos. Se describe en lugar de listarse porque supera 10 valores: incluye perfiles funcionales y técnicos de Oracle, administración, gerencia, ventas y un familiar.",
  dim_departamento: "Las seis áreas de la empresa. Ninguna tiene responsable ni centro de costos capturado, así que hoy no sirve para imputar costo por área.",
  dim_cliente: "Ocho clientes activos. Metalsa y Grupo Daltile tienen tres proyectos cada uno; los otros seis tienen uno. Cuatro clientes no tienen ciudad, estado ni país.",
  dim_proyecto: "Doce proyectos. Siete están En Curso y cinco Por Iniciar. Solo seis tienen fecha de inicio y tres fecha de fin; seis no tienen PM de OTC ni responsable del cliente.",
  dim_rol: "Solo un rol real en 31 asignaciones: CONSULTOR FUNCIONAL ORACLE EBS SENIOR. Las otras 29 caen en el miembro desconocido. Es la dimensión más pobre del modelo y una alerta de captura.",
  dim_habilidad: "Setenta y una habilidades: 30 de Oracle EBS, 20 de plataformas, 17 de Oracle Cloud, 2 de otros, 1 de idiomas y 1 de certificaciones. 67 son duras y 4 blandas. 26 filas comparten descripción con otra tecnología.",
  dim_activo: "Ciento veintitrés equipos: 122 laptops y 1 monitor. Dell, HP y Lenovo concentran 112. Setenta no tienen proveedor, setenta no tienen fecha de compra y todos están con estatus Activo, incluso los que las notas dicen que no funcionan.",
};

const DIM_ORDEN = ["dim_tiempo", "dim_colaborador", "dim_puesto", "dim_departamento", "dim_cliente", "dim_proyecto", "dim_rol", "dim_habilidad", "dim_activo"];
let dimActiva = "dim_colaborador";

function detalleAtributo(nombre, info) {
  if (nombre === "anio_mes") return "312 periodos mensuales (2003-01 a 2028-12)";
  if (info.tipo === "fecha") {
    if (!info.min) return "Sin fechas capturadas";
    return `${fecha(info.min)} → ${fecha(info.max)}`;
  }
  if (info.valores && info.valores.length) {
    const texto = info.valores.map((v) => `${v.valor} (${v.conteo})`).join(" · ");
    return texto.length > 280 ? `${texto.slice(0, 277)}…` : texto;
  }
  if (info.top && info.top.length) {
    const texto = info.top.slice(0, 3).map((v) => `${v.valor} (${v.conteo})`).join(" · ");
    return `Top: ${texto} · ${num(info.distintos)} valores en total`;
  }
  if (info.tipo === "numero" && info.min !== null) {
    return `${num(info.min)} a ${num(info.max)}`;
  }
  if (info.tipo === "texto" && info.distintos > 0) {
    return `${num(info.distintos)} valores; no se publican para proteger datos personales`;
  }
  return "—";
}

function vistaDimensiones() {
  const dim = D.dimensiones[dimActiva];
  const columnas = Object.entries(dim.columnas);
  const fechas = columnas.filter(([, i]) => i.tipo === "fecha" && i.min);
  const rango = fechas.length
    ? `<span class="rango-fecha">${fecha(fechas[0][1].min)} → ${fecha(fechas[0][1].max)}</span>`
    : "";
  return `<section class="seccion">
    ${encabezado("Las nueve dimensiones", "Valores distintos, nulos y rangos de cada atributo. Si un atributo tiene más de 10 valores, se describe en lugar de listarse; el detalle completo está en el documento.")}
    <div class="tarjeta">
      <div class="dimension-selector">
        ${DIM_ORDEN.map((id) => {
          const d = D.dimensiones[id];
          return `<button data-dim="${id}" class="${id === dimActiva ? "activa" : ""}">${esc(id.replace("dim_", ""))}<span>${num(d.filas_reales)} miembros</span></button>`;
        }).join("")}
      </div>
    </div>

    <div class="tarjeta">
      <div class="dimension-cabecera">
        <div>
          <p class="rotulo">Dimensión</p>
          <h3>${esc(dimActiva)}</h3>
          <p>${esc(NARRATIVA[dimActiva] || "")}</p>
        </div>
        <div style="display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end">
          ${rango}
          <span class="pildora">${num(dim.filas_reales)} reales + ${num(dim.miembro_desconocido)} desconocido</span>
        </div>
      </div>
      ${tabla(["Atributo", "Valores distintos", "Nulos", "Detalle"], columnas.map(([nombre, info]) => [
        `<span class="fuerte">${esc(nombre)}</span>`,
        `<span class="num">${num(info.distintos)}</span>`,
        `<span class="num ${info.nulos ? "tono-ambar" : ""}">${num(info.nulos)}</span>`,
        `<span class="sub" style="margin:0;color:#475569">${esc(detalleAtributo(nombre, info))}</span>`,
      ]), { clases: ["", "num", "num", ""] })}
      <p class="nota">${dim.filas_reales > 10 ? `Esta dimensión tiene más de 10 miembros (${num(dim.filas_reales)}); el reporte describe el conjunto y no lista cada registro.` : `Esta dimensión tiene ${num(dim.filas_reales)} miembros; el detalle de valores se puede listar sin problema.`}</p>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Comparativa de dimensiones</p>
      ${tabla(["Dimensión", "Miembros reales", "Miembro desconocido", "Llave natural"], DIM_ORDEN.map((id) => {
        const d = D.dimensiones[id];
        return [`<span class="fuerte">${esc(id)}</span>`, `<span class="num">${num(d.filas_reales)}</span>`, `<span class="num">${num(d.miembro_desconocido)}</span>`, `<span class="codigo">${esc(d.llave)}</span>`];
      }), { clases: ["", "num", "num", ""] })}
      <p class="nota">La fila 0 de cada dimensión es el miembro desconocido; no se cuenta como valor real. Las consultas de perfil están en <a href="../sql/02_perfil_dimensiones.sql">sql/02_perfil_dimensiones.sql</a>.</p>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Modelo                                                              */
/* ------------------------------------------------------------------ */

function vistaModelo() {
  const integridad = D.resultados._integridad || {};
  return `<section class="seccion">
    ${encabezado("Modelo, consultas y despliegue", "La solución es replicable: el mismo ETL corre sobre las tablas acondicionadas y el tablero se publica como sitio estático en Firebase Hosting o en cualquier servidor.")}

    <div class="tarjeta">
      <p class="rotulo">Flujo de datos</p>
      <div class="flujo">
        <div><b>1 · Firebase</b>Sandbox HR Management: 7 módulos exportados a Excel. Usuarios, credenciales y datos bancarios quedan fuera.</div>
        <div><b>2 · Acondicionamiento</b>M1–M14: 265 correcciones, 18 tablas, centinelas a nulo y 5 validaciones en cero.</div>
        <div><b>3 · Modelo dimensional</b>9 dimensiones y 3 hechos con llaves sustitutas, miembro desconocido y SCD donde aplica.</div>
        <div><b>4 · Consultas</b>SQL para cada dimensión y para las 9 preguntas de análisis; el margen se marca bloqueado.</div>
        <div><b>5 · Dirección</b>Tablero estático con resumen, indicadores, detalle y perfil de dimensiones.</div>
      </div>
    </div>

    <div class="rejilla rejilla-2">
      <div class="tarjeta">
        <p class="rotulo">Hechos</p>
        ${tabla(["Hecho", "Grano", "Filas"], D.modelo.hechos.map((h) => [
          `<span class="fuerte">${esc(h.nombre)}</span><span class="sub">${esc(h.dimensiones.join(" · "))}</span>`,
          esc(h.grano), `<span class="num">${num(h.filas)}</span>`,
        ]), { clases: ["", "", "num"] })}
      </div>
      <div class="tarjeta">
        <p class="rotulo">Dimensiones</p>
        ${tabla(["Dimensión", "Filas", "Llave", "SCD"], D.modelo.dimensiones.map((d) => [
          `<span class="fuerte">${esc(d.nombre)}</span>`, `<span class="num">${num(d.filas)}</span>`,
          `<span class="codigo">${esc(d.llave)}</span>`, esc(d.scd),
        ]), { clases: ["", "num", "", ""] })}
      </div>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Controles de integridad de la corrida</p>
      <div class="rejilla rejilla-4" style="margin-top:12px">
        ${ficha("Asignaciones huérfanas", num(integridad.asignaciones_huerfanas), "debe ser 0")}
        ${ficha("Habilidades huérfanas", num(integridad.habilidades_huerfanas), "debe ser 0")}
        ${ficha("Activos huérfanos", num(integridad.activos_huerfanos), "debe ser 0")}
        ${ficha("Costo asignado", money(integridad.costo_asignado_filas), "suma del hecho")}
      </div>
      <p class="nota">Los tres controles de llaves foráneas dan cero. El costo único (${money(integridad.costo_asignado_unico)}) y la nómina (${money(integridad.nomina_activa)}) cierran con la Etapa 3.</p>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Cómo reproducirlo</p>
      <pre style="margin:12px 0 0;padding:14px;background:#0f1f33;color:#dbe7f3;border-radius:11px;overflow-x:auto;font-family:var(--mono);font-size:12px;line-height:1.65">pip install -r requirements.txt
python src/etapa5_dw.py          # construye data/modelo/otc_dw.db
python src/etapa5_consultas.py   # ejecuta las 24 consultas y valida integridad
python src/etapa5_exportar.py    # regenera dashboard/datos.js
python -m http.server 8000       # abre http://localhost:8000/dashboard/</pre>
      <p class="nota">El tablero no necesita Node ni build: es HTML, CSS y JavaScript. Se puede publicar en Firebase Hosting copiando <span class="codigo">dashboard/</span> o sirviéndolo desde el mismo dominio de la PWA.</p>
    </div>

    <div class="tarjeta">
      <p class="rotulo">Archivos de la entrega</p>
      <div class="chips" style="margin-top:10px">
        <a class="chip" href="../sql/01_esquema_dimensional.sql">Esquema dimensional</a>
        <a class="chip" href="../sql/02_perfil_dimensiones.sql">Perfil de dimensiones</a>
        <a class="chip" href="../sql/03_preguntas_analisis.sql">Preguntas de análisis</a>
        <a class="chip" href="../docs/ETAPA_5.md">Documento Etapa 5</a>
        <a class="chip" href="../src/etapa5_dw.py">ETL</a>
        <a class="chip" href="../src/etapa5_consultas.py">Runner de consultas</a>
      </div>
      <p class="nota">Para conectar con la arquitectura del cliente, el mismo modelo se carga a BigQuery para BI o a Firestore para la PWA; los nombres y costos individuales se separan en una colección privada con rol admin, como ya lo hace el repositorio de documentación del equipo.</p>
    </div>
  </section>`;
}

/* ------------------------------------------------------------------ */
/* Navegación                                                          */
/* ------------------------------------------------------------------ */

const PESTANAS = [
  ["resumen", "Resumen", vistaResumen],
  ["utilizacion", "Utilización", vistaUtilizacion],
  ["costos", "Costos", vistaCostos],
  ["tiempo", "Por terminar", vistaTiempo],
  ["habilidades", "Habilidades", vistaHabilidades],
  ["rotacion", "Rotación", vistaRotacion],
  ["activos", "Activos", vistaActivos],
  ["expediente", "Expediente", vistaExpediente],
  ["dimensiones", "Dimensiones", vistaDimensiones],
  ["modelo", "Modelo y SQL", vistaModelo],
];

let activa = "resumen";
const vista = $("#vista");
const nav = $("#pestanas");

function pintaNav() {
  nav.innerHTML = PESTANAS.map(([id, titulo]) =>
    `<button data-ir="${id}" class="${id === activa ? "activa" : ""}" aria-current="${id === activa ? "page" : "false"}">${titulo}</button>`
  ).join("");
}

function pinta() {
  const encontrada = PESTANAS.find(([id]) => id === activa) || PESTANAS[0];
  activa = encontrada[0];
  pintaNav();
  vista.innerHTML = encontrada[2]();
  vista.className = "seccion activa";
  window.location.hash = activa === "resumen" ? "" : activa;
  if (activa === "dimensiones") {
    vista.querySelectorAll("[data-dim]").forEach((b) => b.addEventListener("click", () => {
      dimActiva = b.dataset.dim;
      pinta();
      vista.scrollIntoView({ behavior: "smooth", block: "start" });
    }));
  }
  if (activa === "utilizacion") {
    const input = $("#buscar-banca");
    if (input) {
      input.addEventListener("input", () => {
        const q = input.value.trim().toLowerCase();
        const tablaBanca = $("#tabla-banca");
        const filas = tablaBanca.querySelectorAll("tbody tr");
        filas.forEach((fila) => {
          fila.style.display = !q || fila.textContent.toLowerCase().includes(q) ? "" : "none";
        });
      });
    }
  }
  vista.focus({ preventScroll: true });
}

document.addEventListener("click", (e) => {
  const boton = e.target.closest("[data-ir]");
  if (!boton) return;
  activa = boton.dataset.ir;
  pinta();
  window.scrollTo({ top: 0, behavior: "smooth" });
});

window.addEventListener("hashchange", () => {
  const id = window.location.hash.replace("#", "");
  if (id && PESTANAS.some(([x]) => x === id) && id !== activa) {
    activa = id;
    pinta();
  }
});

$("#corte").textContent = `Corte ${fecha(D.meta.corte)}`;
$("#generado").textContent = `Generado ${D.meta.generado}`;

const inicial = window.location.hash.replace("#", "");
if (PESTANAS.some(([id]) => id === inicial)) activa = inicial;
pinta();
