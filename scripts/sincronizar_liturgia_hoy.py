"""Sincroniza únicamente la liturgia del día actual con Cloud Firestore.

Variables de entorno requeridas:
  CATHOPLE_API_KEY          Clave privada de Cathople.
  FIREBASE_SERVICE_ACCOUNT Ruta al JSON de la cuenta de servicio Firebase.

La fecha se calcula siempre con la zona horaria de Costa Rica. El documento
del día se guarda antes de borrar documentos de otras fechas, de modo que un
fallo de Cathople nunca deja la colección vacía.
"""

from __future__ import annotations

import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Any
from zoneinfo import ZoneInfo

import firebase_admin
import requests
from firebase_admin import credentials, firestore


ZONA_HORARIA = ZoneInfo("America/Costa_Rica")
COLECCION = "liturgia_diaria"
API_URL = "https://api.cathople.com/api/v1/readings/daily"
TIMEOUT_SEGUNDOS = 30


class SincronizacionError(RuntimeError):
    """Error controlado durante la sincronización."""


def variable_requerida(nombre: str) -> str:
    valor = os.environ.get(nombre, "").strip()
    if not valor:
        raise SincronizacionError(
            f"Falta la variable de entorno {nombre}."
        )
    return valor


def iniciar_firestore(ruta_credencial: str):
    archivo = Path(ruta_credencial).expanduser().resolve()
    if not archivo.is_file():
        raise SincronizacionError(
            f"No existe la credencial Firebase: {archivo}"
        )

    if not firebase_admin._apps:
        firebase_admin.initialize_app(
            credentials.Certificate(str(archivo))
        )

    return firestore.client()


def descargar_lecturas(fecha_id: str, api_key: str) -> dict[str, Any]:
    respuesta = requests.get(
        API_URL,
        params={"date": fecha_id, "lang": "es"},
        headers={
            "Authorization": f"Bearer {api_key}",
            "Accept": "application/json",
        },
        timeout=TIMEOUT_SEGUNDOS,
    )

    try:
        respuesta.raise_for_status()
    except requests.HTTPError as error:
        detalle = respuesta.text[:500]
        raise SincronizacionError(
            f"Cathople respondió HTTP {respuesta.status_code}: {detalle}"
        ) from error

    try:
        cuerpo = respuesta.json()
    except requests.JSONDecodeError as error:
        raise SincronizacionError(
            "Cathople no devolvió un JSON válido."
        ) from error

    if cuerpo.get("success") is not True:
        raise SincronizacionError(
            f"Cathople indicó un fallo: {cuerpo}"
        )

    datos = cuerpo.get("data")
    if not isinstance(datos, dict):
        raise SincronizacionError(
            "La respuesta de Cathople no contiene data."
        )

    fecha_respuesta = str(datos.get("date", "")).strip()
    if fecha_respuesta != fecha_id:
        raise SincronizacionError(
            "Cathople devolvió una fecha diferente: "
            f"esperada={fecha_id}, recibida={fecha_respuesta or 'vacía'}."
        )

    return datos


def texto_versiculos(textos: Any) -> str:
    lineas: list[str] = []

    if not isinstance(textos, list):
        return ""

    for bloque in textos:
        if not isinstance(bloque, dict):
            continue

        versos = bloque.get("verses", [])
        if not isinstance(versos, list):
            continue

        for verso in versos:
            if not isinstance(verso, dict):
                continue

            numero = str(verso.get("verse_number", "")).strip()
            texto = str(verso.get("text", "")).strip()
            if not texto:
                continue

            lineas.append(f"{numero}. {texto}" if numero else texto)

    return "\n\n".join(lineas)


def convertir_lectura(lectura: Any) -> dict[str, str]:
    if not isinstance(lectura, dict):
        raise SincronizacionError("Una lectura tiene un formato inválido.")

    textos = lectura.get("texts", [])
    libro = ""
    if isinstance(textos, list) and textos and isinstance(textos[0], dict):
        libro = str(textos[0].get("book_name", "")).strip()

    resultado = {
        "tipo": str(
            lectura.get("reading_type") or lectura.get("id") or ""
        ).strip(),
        "titulo": str(lectura.get("reading_title", "")).strip(),
        "referencia": str(lectura.get("reference_text", "")).strip(),
        "libro": libro,
        "texto": texto_versiculos(textos),
    }

    if not resultado["texto"]:
        raise SincronizacionError(
            f"La lectura {resultado['tipo'] or 'desconocida'} no tiene texto."
        )

    return resultado


def clasificar_lecturas(datos: dict[str, Any]) -> dict[str, Any]:
    lecturas = datos.get("readings", [])
    if not isinstance(lecturas, list):
        raise SincronizacionError("readings no es una lista.")

    por_tipo: dict[str, dict[str, str]] = {}
    for lectura_original in lecturas:
        lectura = convertir_lectura(lectura_original)
        tipo = lectura["tipo"].lower().replace("_", "").replace("-", "")
        por_tipo[tipo] = lectura

    primera = por_tipo.get("firstreading")
    evangelio = por_tipo.get("gospel")
    if primera is None or evangelio is None:
        raise SincronizacionError(
            "Falta la primera lectura o el Evangelio en Cathople."
        )

    return {
        "primeraLectura": primera,
        "salmo": por_tipo.get("psalm"),
        "segundaLectura": por_tipo.get("secondreading"),
        "evangelio": evangelio,
    }


def construir_documento(
    fecha_id: str,
    datos: dict[str, Any],
) -> dict[str, Any]:
    version = datos.get("version", {})
    fuente = datos.get("source", {})
    if not isinstance(version, dict):
        version = {}
    if not isinstance(fuente, dict):
        fuente = {}

    documento: dict[str, Any] = {
        "fecha": fecha_id,
        **clasificar_lecturas(datos),
        "versionBiblia": {
            "codigo": str(version.get("code", "")).strip(),
            "nombre": str(version.get("name", "")).strip(),
            "abreviatura": str(version.get("abbreviation", "")).strip(),
        },
        "fuente": {
            "nombre": "Cathople",
            "api": str(fuente.get("apiEndpoint", "")).strip() or None,
            "enlace": str(fuente.get("usccbLink", "")).strip() or None,
        },
        "publicado": True,
        "actualizadoEn": firestore.SERVER_TIMESTAMP,
    }
    return documento


def eliminar_otras_fechas(db, fecha_id: str) -> int:
    eliminados = 0
    lote = db.batch()
    operaciones = 0

    for documento in db.collection(COLECCION).stream():
        if documento.id == fecha_id:
            continue

        lote.delete(documento.reference)
        operaciones += 1
        eliminados += 1

        if operaciones == 400:
            lote.commit()
            lote = db.batch()
            operaciones = 0

    if operaciones:
        lote.commit()

    return eliminados


def main() -> int:
    fecha_id = datetime.now(ZONA_HORARIA).date().isoformat()
    print("=" * 60)
    print("SINCRONIZACIÓN DE LA LITURGIA DE HOY")
    print("=" * 60)
    print(f"Fecha de Costa Rica: {fecha_id}")

    try:
        api_key = variable_requerida("CATHOPLE_API_KEY")
        credencial = variable_requerida("FIREBASE_SERVICE_ACCOUNT")
        db = iniciar_firestore(credencial)

        print("Descargando lecturas desde Cathople...")
        datos = descargar_lecturas(fecha_id, api_key)
        documento = construir_documento(fecha_id, datos)

        referencia = db.collection(COLECCION).document(fecha_id)
        print(f"Guardando {COLECCION}/{fecha_id}...")
        referencia.set(documento)

        guardado = referencia.get()
        if not guardado.exists or guardado.to_dict().get("publicado") is not True:
            raise SincronizacionError(
                "Firestore no confirmó correctamente el documento nuevo."
            )

        print("Documento de hoy verificado correctamente.")
        eliminados = eliminar_otras_fechas(db, fecha_id)
        print(f"Documentos de otras fechas eliminados: {eliminados}")
        print("Sincronización terminada correctamente.")
        return 0

    except (SincronizacionError, requests.RequestException) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        print(
            "No se eliminaron lecturas existentes debido al fallo.",
            file=sys.stderr,
        )
        return 1
    except Exception as error:  # Protección final para tareas programadas.
        print(
            f"ERROR INESPERADO ({type(error).__name__}): {error}",
            file=sys.stderr,
        )
        print(
            "No se eliminaron lecturas existentes debido al fallo.",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
