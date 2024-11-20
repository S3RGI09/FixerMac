#!/bin/bash

RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}-FixerMac- | By S3RGI09${RESET}"
echo -e "${GREEN}v3.3 estable${RESET}"

if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Por favor, ejecuta este script con permisos de superusuario (sudo).${RESET}"
    exit 1
fi

function crear_reporte {
    echo -e "${ORANGE}Creando reporte de errores...${RESET}"
    echo "# Reporte de Errores - $(date)" > reporte.md
    echo "$1" >> reporte.md
    echo -e "${GREEN}El reporte ha sido creado en 'reporte.md'.${RESET}"
}

function verificar_errores {
    echo -e "${ORANGE}Iniciando verificación del sistema...${RESET}"
    
    echo -e "${ORANGE}Verificando errores del sistema de archivos...${RESET}"
    if ! diskutil verifyVolume / > /dev/null; then
        echo -e "${RED}Error: Sistema de archivos corrupto.${RESET}"
        crear_reporte "Error en la verificación del sistema de archivos."
    fi

    echo -e "${ORANGE}Comprobando extensiones de kernel...${RESET}"
    if kextstat | grep -v com.apple > /dev/null; then
        echo -e "${ORANGE}Se encontraron extensiones de kernel no oficiales. Verificando su estado...${RESET}"
        kextstat | grep -v com.apple | while read -r kext; do
            if ! kextstat | grep -q "$kext"; then
                echo -e "${RED}Error: El kext $kext no se está cargando correctamente.${RESET}"
                crear_reporte "Error: El kext $kext no se está cargando correctamente."
            fi
        done
    else
        echo -e "${GREEN}No se encontraron extensiones de kernel no oficiales.${RESET}"
    fi

    echo -e "${ORANGE}Verificando logs del sistema...${RESET}"
    if log show --predicate 'eventMessage contains "error"' --info --last 1h | grep -q "error"; then
        echo -e "${RED}Se encontraron errores en los logs del sistema.${RESET}"
        crear_reporte "Errores encontrados en los logs del sistema."
    fi

    echo -e "${ORANGE}Verificando espacio en disco...${RESET}"
    free_space=$(diskutil info / | grep "Free Space" | awk '{print $3}' | tr -d '()')
    if [[ "$free_space" =~ ^[0-9]+$ ]] && [ "$free_space" -lt 100000000 ]; then
        echo -e "${RED}Error: Poco espacio en disco.${RESET}"
        crear_reporte "Error: Espacio en disco insuficiente ($free_space bytes)."
    fi

    echo -e "${ORANGE}Verificando la hora del sistema...${RESET}"
    system_time=$(date +%s)
    ntp_time=$(date -u +%s -d @$(curl -s --head http://time.apple.com | grep -i ^date: | sed 's/Date: //'))

    if [ "$system_time" -ne "$ntp_time" ]; then
        echo -e "${RED}Error: La hora del sistema está desajustada.${RESET}"
        crear_reporte "Error: La hora del sistema está desajustada."
    else
        echo -e "${GREEN}La hora del sistema está correcta.${RESET}"
    fi
}

function corregir_errores {
    echo -e "${ORANGE}Corrigiendo errores detectados...${RESET}"
    
    echo -e "${ORANGE}1. Reparación del sistema de archivos con 'diskutil repairVolume'.${RESET}"
    read -p "¿Deseas continuar con esta operación? (s/n): " confirmar_diskutil
    if [[ "$confirmar_diskutil" == "s" ]]; then
        if ! diskutil repairVolume / > /dev/null; then
            echo -e "${RED}Error: No se pudo reparar el sistema de archivos.${RESET}"
            crear_reporte "Error al intentar reparar el sistema de archivos."
        else
            echo -e "${GREEN}Sistema de archivos reparado con éxito.${RESET}"
        fi
    else
        echo -e "${ORANGE}Reparación del sistema de archivos omitida.${RESET}"
    fi

    echo -e "${ORANGE}2. Reconstrucción de la caché del kernel con 'kextcache'.${RESET}"
    read -p "¿Deseas continuar con esta operación? (s/n): " confirmar_kextcache
    if [[ "$confirmar_kextcache" == "s" ]]; then
        if ! kextcache -i / > /dev/null; then
            echo -e "${RED}Error: No se pudo reconstruir la caché del kernel.${RESET}"
            crear_reporte "Error al reconstruir la caché del kernel."
        else
            echo -e "${GREEN}Caché del kernel reconstruida con éxito.${RESET}"
        fi
    else
        echo -e "${ORANGE}Reconstrucción de caché del kernel omitida.${RESET}"
    fi

    echo -e "${ORANGE}3. Limpieza de la caché del sistema.${RESET}"
    read -p "¿Deseas limpiar la caché del sistema? (s/n): " confirmar_cache
    if [[ "$confirmar_cache" == "s" ]]; then
        echo -e "${YELLOW}ADVERTENCIA: Esta acción eliminará archivos temporales que podrían causar problemas si están en uso.${RESET}"
        read -p "¿Estás seguro de querer continuar? (s/n): " doble_confirmar_cache
        if [[ "$doble_confirmar_cache" == "s" ]]; then
            if ! sudo rm -rf /Library/Caches/* /System/Library/Caches/* /var/folders/* > /dev/null; then
                echo -e "${RED}Error: No se pudo limpiar la caché del sistema.${RESET}"
                crear_reporte "Error al intentar limpiar la caché del sistema."
            else
                echo -e "${GREEN}Caché del sistema limpiada con éxito.${RESET}"
            fi
        else
            echo -e "${ORANGE}Limpieza de caché cancelada.${RESET}"
        fi
    else
        echo -e "${ORANGE}Limpieza de caché omitida.${RESET}"
    fi

    echo -e "${ORANGE}4. Ajuste de la hora del sistema con NTP.${RESET}"
    read -p "¿Deseas ajustar la hora del sistema? (s/n): " confirmar_ajuste_hora
    if [[ "$confirmar_ajuste_hora" == "s" ]]; then
        sudo systemsetup -setnetworktimeserver time.apple.com
        sudo systemsetup -setusingnetworktime on
        echo -e "${GREEN}Hora del sistema ajustada correctamente.${RESET}"
    else
        echo -e "${ORANGE}Ajuste de hora omitido.${RESET}"
    fi
}

verificar_errores

read -p "¿Deseas intentar corregir los errores detectados? (s/n): " corregir
if [[ "$corregir" == "s" ]]; then
    corregir_errores
    echo -e "${GREEN}Proceso de corrección finalizado.${RESET}"
else
    echo -e "${ORANGE}No se realizaron correcciones.${RESET}"
fi

if [ -f reporte.md ]; then
    echo -e "${GREEN}Se ha generado un reporte de errores: 'reporte.md'. Revisa el archivo para más detalles.${RESET}"
fi
