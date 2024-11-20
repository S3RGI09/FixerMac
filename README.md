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

4. **Opciones:**
   - El script te preguntará si deseas corregir los errores encontrados. Responde `s` para proceder con las correcciones o `n` para finalizar.
   - Después de las correcciones, se te dará la opción de reiniciar el sistema. Necesario para aplicar las correcciones.

## Reporte de Errores

Si el script encuentra errores que no puede corregir automáticamente, se generará un archivo llamado `reporte.md` en el que se detallarán los errores encontrados y las acciones recomendadas.

## Seguridad
El script en si mismo es seguro y esta diseñado para fines éticos, es necesario solicitar permisos de superusuario, ya que sin estos el script no puede corregir los errores, de todos modos, puedes verificar tu mismo el codigo y verificar que no contiene comportamientos potencialmente destructivos, y por el contrario, usa acciones controladas y claras con la interacción del usuario.

**Potencial de riesgo:** 3/10 (Bajo)
- Uso de permisos elevados (necesarios)
- Posible daño indirecto (improbable)
- Errores por parte del usuario

## Contribuciones

Si deseas contribuir a este proyecto, por favor crea un fork del repositorio y envía un pull request con tus mejoras o correcciones.

## Licencia

Este proyecto está bajo la licencia MIT. Para más detalles, revisa el archivo `LICENSE`.
