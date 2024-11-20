#!/bin/bash

echo "-FixerMac- | By S3RGI09 (Mejorado por Seguridad)"

if [ "$EUID" -ne 0 ]; then 
    echo "Por favor, ejecuta este script con permisos de superusuario (sudo)."
    exit 1
fi

function crear_reporte {
    echo "Creando reporte de errores..."
    echo "# Reporte de Errores - $(date)" > reporte.md
    echo "$1" >> reporte.md
    echo "El reporte ha sido creado en 'reporte.md'."
}

function verificar_errores {
    echo "Iniciando verificación del sistema..."
    
    echo "Verificando errores del sistema de archivos..."
    if ! diskutil verifyVolume / > /dev/null; then
        echo "Error: Sistema de archivos corrupto."
        crear_reporte "Error en la verificación del sistema de archivos."
    fi

    echo "Comprobando extensiones de kernel..."
    if kextstat | grep -v com.apple > /dev/null; then
        echo "Se encontraron extensiones de kernel no oficiales. Verificando su estado..."
        kextstat | grep -v com.apple | while read -r kext; do
            if ! kextstat | grep -q "$kext"; then
                echo "Error: El kext $kext no se está cargando correctamente."
                crear_reporte "Error: El kext $kext no se está cargando correctamente."
            fi
        done
    else
        echo "No se encontraron extensiones de kernel no oficiales."
    fi

    echo "Verificando logs del sistema..."
    if log show --predicate 'eventMessage contains "error"' --info --last 1h | grep -q "error"; then
        echo "Se encontraron errores en los logs del sistema."
        crear_reporte "Errores encontrados en los logs del sistema."
    fi

    echo "Verificando espacio en disco..."
    free_space=$(diskutil info / | grep "Free Space" | awk '{print $3}' | tr -d '()')
    if [[ "$free_space" =~ ^[0-9]+$ ]] && [ "$free_space" -lt 100000000 ]; then
        echo "Error: Poco espacio en disco."
        crear_reporte "Error: Espacio en disco insuficiente ($free_space bytes)."
    fi
}

function corregir_errores {
    echo "Corrigiendo errores detectados..."
    
    echo "1. Reparación del sistema de archivos con 'diskutil repairVolume'."
    read -p "¿Deseas continuar con esta operación? (s/n): " confirmar_diskutil
    if [[ "$confirmar_diskutil" == "s" ]]; then
        if ! diskutil repairVolume / > /dev/null; then
            echo "Error: No se pudo reparar el sistema de archivos."
            crear_reporte "Error al intentar reparar el sistema de archivos."
        else
            echo "Sistema de archivos reparado con éxito."
        fi
    else
        echo "Reparación del sistema de archivos omitida."
    fi

    echo "2. Reconstrucción de la caché del kernel con 'kextcache'."
    read -p "¿Deseas continuar con esta operación? (s/n): " confirmar_kextcache
    if [[ "$confirmar_kextcache" == "s" ]]; then
        if ! kextcache -i / > /dev/null; then
            echo "Error: No se pudo reconstruir la caché del kernel."
            crear_reporte "Error al reconstruir la caché del kernel."
        else
            echo "Caché del kernel reconstruida con éxito."
        fi
    else
        echo "Reconstrucción de caché del kernel omitida."
    fi

    echo "3. Limpieza de la caché del sistema."
    read -p "¿Deseas limpiar la caché del sistema? (s/n): " confirmar_cache
    if [[ "$confirmar_cache" == "s" ]]; then
        echo "ADVERTENCIA: Esta acción eliminará archivos temporales que podrían causar problemas si están en uso."
        read -p "¿Estás seguro de querer continuar? (s/n): " doble_confirmar_cache
        if [[ "$doble_confirmar_cache" == "s" ]]; then
            if ! sudo rm -rf /Library/Caches/* /System/Library/Caches/* /var/folders/* > /dev/null; then
                echo "Error: No se pudo limpiar la caché del sistema."
                crear_reporte "Error al intentar limpiar la caché del sistema."
            else
                echo "Caché del sistema limpiada con éxito."
            fi
        else
            echo "Limpieza de caché cancelada."
        fi
    else
        echo "Limpieza de caché omitida."
    fi
}

verificar_errores

read -p "¿Deseas intentar corregir los errores detectados? (s/n): " corregir
if [[ "$corregir" == "s" ]]; then
    corregir_errores
    echo "Proceso de corrección finalizado."
else
    echo "No se realizaron correcciones."
fi

if [ -f reporte.md ]; then
    echo "Se ha generado un reporte de errores: 'reporte.md'. Revisa el archivo para más detalles."
fi
