# FixerMac - Script Bash

Este script, **FixerMac**, realiza un chequeo y reparación de errores en sistemas macOS, abordando problemas relacionados con el sistema de archivos, extensiones del kernel y permisos. Además, te permite reiniciar el equipo tras las reparaciones.

## Características

- **Chequeo de errores**: Escanea el sistema de archivos, verifica extensiones del kernel y detecta problemas de permisos.
- **Corrección automática**: Corrige errores detectados en el sistema de archivos y reconstruye la caché del kernel si es necesario.
- **Reinicio opcional**: Te permite reiniciar el equipo después de realizar las reparaciones.

## Requisitos

- **macOS**: El script está diseñado para funcionar en sistemas macOS.
- **Permisos de superusuario (root)**: Se debe ejecutar con permisos de administrador.

## Instalación y uso

1. Descargar el script y guardarlo como `FixerMac.sh`.
2. Otorgar permisos de ejecución con el comando:
   `chmod +x FixerMac.sh`
3. Ejecutar el script con permisos de superusuario usando:
   `sudo ./FixerMac.sh`

## Funcionamiento

1. El script comienza con un chequeo del sistema de archivos, extensiones del kernel y permisos.
2. Pregunta si deseas reparar los errores encontrados.
3. Si decides proceder, corrige los errores automáticamente y ofrece la opción de reiniciar el equipo.

## Licencia

FixerMac está licenciado bajo la licencia MIT.
