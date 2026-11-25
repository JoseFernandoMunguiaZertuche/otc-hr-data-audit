"""Exporta el modelo y las consultas al tablero estático de Dirección.

Genera `dashboard/datos.js` con un objeto `window.DATOS` para que el sitio
funcione abriendo el archivo directamente, sin servidor ni dependencias.

Uso:
    python src/etapa5_exportar.py
"""

from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
MODELO = RAIZ / "data" / "modelo"
DESTINO = RAIZ / "dashboard" / "datos.js"

MODELO_LOGICO = {
    "hechos": [
        {
            "nombre": "hecho_asignacion",
            "grano": "Una asignación de un colaborador a un proyecto",
            "filas": 31,
            "dimensiones": ["Tiempo", "Colaborador", "Puesto", "Departamento", "Cliente", "Proyecto", "Rol"],
        },
        {
            "nombre": "hecho_habilidad",
            "grano": "Un colaborador y una habilidad evaluada",
            "filas": 1539,
            "dimensiones": ["Tiempo", "Colaborador", "Habilidad"],
        },
        {
            "nombre": "hecho_activo",
            "grano": "Un activo del inventario",
            "filas": 123,
            "dimensiones": ["Tiempo", "Colaborador", "Activo"],
        },
    ],
    "dimensiones": [
        {"nombre": "dim_tiempo", "filas": 9497, "llave": "sk_tiempo (AAAAMMDD)", "scd": "0"},
        {"nombre": "dim_colaborador", "filas": 107, "llave": "id_colaborador", "scd": "2"},
        {"nombre": "dim_puesto", "filas": 23, "llave": "id_puesto", "scd": "1"},
        {"nombre": "dim_departamento", "filas": 6, "llave": "codigo", "scd": "1"},
        {"nombre": "dim_cliente", "filas": 8, "llave": "id_cliente", "scd": "1"},
        {"nombre": "dim_proyecto", "filas": 12, "llave": "id_proyecto", "scd": "2"},
        {"nombre": "dim_rol", "filas": 1, "llave": "rol_asignado", "scd": "1"},
        {"nombre": "dim_habilidad", "filas": 71, "llave": "cod_habilidad", "scd": "1"},
        {"nombre": "dim_activo", "filas": 123, "llave": "codigo", "scd": "1"},
    ],
}


def main() -> None:
    perfil = json.loads((MODELO / "perfil_dimensiones.json").read_text(encoding="utf-8"))
    resumen = json.loads((MODELO / "resumen_ejecutivo.json").read_text(encoding="utf-8"))
    resultados = json.loads((MODELO / "resultados_analisis.json").read_text(encoding="utf-8"))

    # El tablero es público: no publica nombres, IDs, series ni contactos,
    # aunque el perfil los use internamente para contar valores distintos.
    privadas = {
        "nombre_completo", "id_colaborador", "contacto_nom", "serie",
        "email", "telefono", "contacto_email", "contacto_tel",
        "pm_otc", "resp_cli", "proveedor",
    }
    for dimension in perfil.values():
        for atributo, meta in dimension["columnas"].items():
            if atributo in privadas:
                meta.pop("valores", None)
                meta.pop("top", None)

    datos = {
        "meta": {
            "titulo": "OT Consulting · Consulta para Dirección",
            "subtitulo": "Modelo dimensional de Recursos Humanos",
            "corte": resumen["corte"],
            "generado": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "moneda": "MXN",
            "fuente": "Sandbox HR Management (Firebase) → acondicionamiento M1–M14 → modelo dimensional",
            "etapa": "Etapa 5 · consultas y solución",
        },
        "resumen": resumen,
        "dimensiones": perfil,
        "modelo": MODELO_LOGICO,
        "resultados": resultados,
    }

    DESTINO.parent.mkdir(parents=True, exist_ok=True)
    contenido = (
        "/* Generado por src/etapa5_exportar.py. No editar a mano. */\n"
        "window.DATOS = "
        + json.dumps(datos, ensure_ascii=False, separators=(",", ":"))
        + ";\n"
    )
    DESTINO.write_text(contenido, encoding="utf-8")
    print(f"Tablero: {DESTINO}")
    print(f"Consultas exportadas: {len([k for k in resultados if not k.startswith('_')])}")
    print(f"Dimensiones: {len(perfil)}")


if __name__ == "__main__":
    main()
