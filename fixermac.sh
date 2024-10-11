#!/bin/bash

echo "-FixerMac- | By S3RGI09"

if [ "$EUID" -ne 0 ]; then 
    echo "Por favor, ejecuta este script con permisos de superusuario (sudo)."
    exit
fi

function verificar_errores {
    echo "Verificando errores del sistema de archivos..."
    diskutil verifyVolume /
    echo "Comprobando kernel..."
    sudo kextstat | grep -v com.apple
    echo "Verificando sistema de archivos con fsck..."
    sudo fsck -fy /
}

function corregir_errores {
    echo "Corrigiendo permisos y errores del sistema de archivos..."
    sudo diskutil repairVolume /
    echo "Reconstruyendo caché del kernel..."
    sudo kextcache -i /
    echo "Verificando sistema de archivos con fsck..."
    sudo fsck -fy /
}

echo "Iniciando chequeo del sistema..."
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
