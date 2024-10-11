#!/bin/bash

echo "-FixerMac- | By S3RGI09"

if [ "$EUID" -ne 0 ]; then 
    echo "Por favor, ejecuta este script con permisos de superusuario (sudo)."
    exit
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

    echo "Verificando problemas en los drivers..."
    if ! kextstat | grep -q "com.apple"; then
        echo "Error: No se encontraron drivers oficiales en el kernel."
        crear_reporte "Error: No se encontraron drivers oficiales en el kernel."
    else
        driver_errors=$(log show --predicate 'eventMessage contains "kext"' --info --last 1h | grep -i "error")
        if [[ -n "$driver_errors" ]]; then
            echo "Se encontraron problemas con los drivers: $driver_errors"
            crear_reporte "Se encontraron problemas con los drivers: $driver_errors"
        fi
    fi

    echo "Verificando sistema de archivos con fsck..."
    if ! fsck -fy / > /dev/null; then
        echo "Error: fsck no pudo reparar el sistema de archivos."
        crear_reporte "Error en la verificación con fsck."
    fi

    echo "Verificando espacio en disco..."
    free_space=$(diskutil info / | grep "Free Space" | awk '{print $3}')
    if [ "$free_space" -lt 100000000 ]; then
        echo "Error: Poco espacio en disco."
        crear_reporte "Error: Espacio en disco insuficiente ($free_space bytes)."
    fi

    echo "Verificando logs del sistema..."
    if log show --predicate 'eventMessage contains "error"' --info --last 1h | grep -q "error"; then
        echo "Se encontraron errores en los logs del sistema."
        crear_reporte "Errores encontrados en los logs del sistema."
    fi

    echo "Verificando actualizaciones pendientes..."
    if softwareupdate -l | grep -q "No new software available."; then
        echo "No hay actualizaciones pendientes."
    else
        echo "Existen actualizaciones pendientes."
        crear_reporte "Actualizaciones pendientes detectadas."
    fi

    echo "Verificando red y DNS..."
    if ! ping -c 1 8.8.8.8 > /dev/null; then
        echo "Error de conectividad de red."
        crear_reporte "Error: No se pudo hacer ping a 8.8.8.8 (problema de red/DNS)."
    fi
}

function corregir_errores {
    echo "Corrigiendo permisos y errores del sistema de archivos..."
    if ! diskutil repairVolume / > /dev/null; then
        echo "Error al reparar el sistema de archivos."
        crear_reporte "Error al intentar reparar el sistema de archivos."
    fi

    echo "Reconstruyendo caché del kernel..."
    if ! kextcache -i / > /dev/null; then
        echo "Error al reconstruir la caché del kernel."
        crear_reporte "Error al reconstruir la caché del kernel."
    fi

    echo "Verificando sistema de archivos con fsck..."
    if ! fsck -fy / > /dev/null; then
        echo "Error: fsck no pudo reparar el sistema de archivos."
        crear_reporte "Error en la corrección con fsck."
    fi

    echo "Corrigiendo permisos del sistema..."
    if ! diskutil repairPermissions / > /dev/null; then
        echo "Error: No se pudieron reparar los permisos."
        crear_reporte "Error en la corrección de permisos del sistema."
    fi

    echo "Limpiando caché del sistema..."
    read -p "¿Deseas limpiar la caché del sistema? (s/n): " confirmar
    if [[ "$confirmar" == "s" ]]; then
        if ! sudo rm -rf /Library/Caches/* /System/Library/Caches/* /var/folders/* > /dev/null; then
            echo "Error: No se pudo limpiar la caché del sistema."
            crear_reporte "Error al intentar limpiar la caché del sistema."
        else
            echo "Caché del sistema limpiada con éxito."
        fi
    else
        echo "Limpieza de caché cancelada."
    fi
}

verificar_errores

read -p "¿Deseas corregir los errores encontrados? (s/n): " respuesta

if [[ "$respuesta" == "s" ]]; then
    corregir_errores
    echo "Errores corregidos."
    
    read -p "¿Quieres reiniciar el sistema ahora? (s/n): " reiniciar
    if [[ "$reiniciar" == "s" ]]; then
        echo "Reiniciando el sistema..."
        sudo reboot
    else
        echo "Reinicio cancelado."
    fi
else
    echo "No se realizaron correcciones."
fi

if [ -f reporte.md ]; then
    echo "Se ha generado un reporte de errores: 'reporte.md'. Revisa el archivo para más detalles."
fi
