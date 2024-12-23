# FixerMac <img src="https://www.projectwizards.net/media/pages/blog/2020/01/macos-03-version/912d5199b9-1731076114/macos.png" alt="macOS Image" width="50" height="50"/>

**FixerMac** es un script de bash diseñado para diagnosticar y corregir problemas comunes en macOS, incluyendo el sistema de archivos, el kernel, permisos, actualizaciones pendientes y errores de red. Además, genera un reporte (`reporte.md`) cuando encuentra errores que no puede corregir automáticamente.

## Requisitos

- macOS.
- Permisos de superusuario (sudo).

## Uso

1. **Clona el repositorio o descarga el script.**
   
2. **Ejecuta el script con permisos de superusuario:**
   ```
   chmod +x fixermac.sh
   sudo ./fixermac.sh
   ```

3. **El script realizará las siguientes verificaciones:**
   - Verificación del sistema de archivos (diskutil y fsck).
   - Extensiones de kernel no oficiales.
   - Extensiones de kernel no funcionando
   - Espacio en disco disponible.
   - Errores en los logs del sistema.
   - Actualizaciones del sistema pendientes.
   - Estado de la red y conectividad.
   - Drivers no funcionando
   - Fecha y hora correcta

4. **Opciones:**
   - El script te preguntará si deseas corregir los errores encontrados. Responde `s` para proceder con las correcciones o `n` para finalizar.
   - Después de las correcciones, se te dará la opción de reiniciar el sistema. Necesario para aplicar las correcciones.

## Reporte de Errores

Si el script encuentra errores que no puede corregir automáticamente, se generará un archivo llamado `reporte.md` en el que se detallarán los errores encontrados y las acciones recomendadas.

>[!warning]
>El script en si mismo es seguro y esta diseñado para fines éticos, es necesario solicitar permisos de superusuario, ya que sin estos el script no puede corregir los errores, de todos modos, puedes verificar tu mismo el codigo y verificar que no contiene comportamientos potencialmente destructivos, y por el contrario, usa acciones controladas y claras con la interacción del usuario.

**Potencial de riesgo:** 3/10 (Bajo)
- Uso de permisos elevados (necesarios)
- Posible daño indirecto (improbable)
- Errores por parte del usuario

## Problemas comunes
**Si no puedes acceder a webs HTTPS**, puede ser porque el certificado TLS está caducado o no es reconocido. Para solucionar esto, sigue estos pasos:

1. **Verifica la autoridad del certificado**:
   - Revisa si el problema es que la autoridad de certificación (CA) de la que se desconfía es **Let's Encrypt**.

2. **Descarga el certificado más reciente**:
   - Ve a [este enlace](https://letsencrypt.org/certs/isrgrootx1.txt) y copia todo el contenido del certificado.

3. **Crea un archivo con el certificado**:
   - Abre la **Terminal** y navega a tu directorio preferido.
   - Ejecuta el comando `nano cert.pem` para crear un archivo de texto llamado `cert.pem`.
   - Pega el contenido copiado del certificado y guarda el archivo presionando `Ctrl + X`, luego `Y` para confirmar y `Enter`.

4. **Instala el certificado en Keychain Access**:
   - Abre **Finder** y localiza el archivo `cert.pem`.
   - Haz doble clic en el archivo para abrirlo en **Keychain Access**.
   - Introduce tu contraseña para autorizar la instalación.
   - Asegúrate de seleccionar el llavero **"Sistema"** y marca la opción de **"Confiar"** para permitir que el sistema confíe en este certificado.

5. **Verifica la instalación**:
   - Comprueba que el certificado se haya instalado correctamente y que el navegador o sistema reconozca el certificado como válido.

6. **(Opcional) Borra certificados caducados**:
   - Si lo prefieres, puedes eliminar certificados caducados de **Keychain Access** para mantener el sistema limpio.

## Contribuciones

Si deseas contribuir a este proyecto, por favor crea un fork del repositorio y envía un pull request con tus mejoras o correcciones.

## Enlaces
- [Repositorio de Darwin, Kernel de MacOS](https://github.com/apple/darwin-xnu)
- [Soporte de Apple para errores de Kernel Panic](https://support.apple.com/es-lamr/guide/mac-help/mchlp2890/mac)
- [Soporte de Apple para Mac](https://support.apple.com/es-es/mac)
- [Utilizar Diagnóstico Apple](https://support.apple.com/es-es/102550)

## Licencia

Este proyecto está bajo la licencia MIT. Para más detalles, revisa el archivo `LICENSE`.
