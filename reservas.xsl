<?xml version="1.0" encoding="UTF-8"?>

<!-- 
  ========================================================================================
  <xsl:stylesheet>: Esta es la etiqueta principal que envuelve todo. Le dice al ordenador 
  "Oye, este archivo es una hoja de transformación XSLT". Es como la portada de nuestro libro de reglas.
  ========================================================================================
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- 
      <xsl:output>: Le dice al sistema cómo queremos que salga el resultado final. 
      Aquí le estamos diciendo: "Quiero que el resultado sea código HTML, usando 
      texto estándar (UTF-8) y que me lo pongas ordenadito con saltos de línea (indent='yes')"
    -->
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    
    <!-- 
      <xsl:strip-space> y <xsl:preserve-space>: 
      Imagina que tu XML tiene muchos espacios en blanco y saltos de línea inútiles entre las etiquetas. 
      'strip-space' elimina esos huecos vacíos para que el procesamiento sea más rápido.
      Sin embargo, con 'preserve-space' le decimos: "¡Ojo! En las notas adicionales NO me borres 
      los espacios, porque ahí el cliente ha escrito frases normales y necesitamos los espacios entre palabras".
    -->
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="notas-adicionales"/>

    <!-- 
      ========================================================================================
      <xsl:template match="/">: ESTE ES EL PUNTO DE PARTIDA.
      La barra "/" significa "la raíz" o "el principio de todo el documento XML". 
      Es como decir: "Cuando empieces a leer el XML, empieza a pintar este esqueleto HTML básico".
      ========================================================================================
    -->
    <xsl:template match="/">
        <html>
            <head>
                <title>Panel de Control de Reservas Detallado</title>
                <link rel="stylesheet" type="text/css" href="estilos.css"/>
            </head>
            <body>
                <!-- 
                  <xsl:comment>: Esto sirve para meter un comentario en el código HTML resultante final. 
                  Si alguien le da a "Ver código fuente" en el navegador web, verá esto. 
                  Pero NO se muestra escrito de forma normal en la pantalla de la página web.
                -->
                <xsl:comment> Dashboard HTML generado dinámicamente mediante XSLT </xsl:comment>
                <div class="contenedor">
                    <h1>DASHBOARD DE RESERVAS</h1>
                    <p class="total">Análisis y estado general del restaurante</p>

                    <!-- PANEL DASHBOARD CON XPATH -->
                    <div class="panel-cuadricula">
                        
                        <!-- Tarjeta 1: Estado de las reservas -->
                        <div class="tarjeta-estadistica estadistica-estado">
                            <div class="titulo-estadistica">Estado Ocupación</div>
                            <div class="valor-estadistica">
                                <!-- 
                                  <xsl:value-of>: Esta es la etiqueta que más vas a usar. Sirve para IMPRIMIR un valor en la pantalla.
                                  Va al XML, hace el cálculo o busca el dato que le pides en el 'select', y escupe el texto aquí.
                                  En este caso le decimos "cuenta (count) cuántas reservas tienen el estado 'confirmada'".
                                -->
                                <xsl:value-of select="count(//reserva[@estado='confirmada'])"/>
                                <span style="font-size:0.5em; color:#bdc3c7;"> / <xsl:value-of select="count(//reserva)"/></span>
                            </div>
                            <div class="subtitulo-estadistica">Reservas confirmadas (total)</div>
                        </div>

                        <!-- Tarjeta 2: Ingresos proyectados -->
                        <div class="tarjeta-estadistica estadistica-ingresos">
                            <div class="titulo-estadistica">Ingresos Estimados</div>
                            <div class="valor-estadistica">
                                <xsl:value-of select="sum(//reserva/datos-reserva/@pago)"/>€
                            </div>
                            <div class="subtitulo-estadistica">Suma de reservas con pago</div>
                        </div>

                        <!-- Tarjeta 3: Media de comensales -->
                        <div class="tarjeta-estadistica estadistica-comensales">
                            <div class="titulo-estadistica">Media Comensales</div>
                            <div class="valor-estadistica">
                                <xsl:value-of select="format-number(sum(//reserva/datos-reserva/numero-comensales) div count(//reserva), '#.0')"/>
                            </div>
                            <div class="subtitulo-estadistica">Comensales totales: <xsl:value-of select="sum(//reserva/datos-reserva/numero-comensales)"/></div>
                        </div>

                        <!-- Tarjeta 4: Alerta de riesgo (Negocio) -->
                        <div class="tarjeta-estadistica estadistica-alertas">
                            <div class="titulo-estadistica">Faltan por pagar</div>
                            <div class="valor-estadistica" style="color: var(--sweet-peony);">
                                <xsl:value-of select="count(//reserva[not(datos-reserva/@pago)])"/>
                            </div>
                            <div class="subtitulo-estadistica">Reservas de riesgo sin importe</div>
                        </div>

                        <!-- Tarjeta 5: Zonas (NUEVO XPATH) -->
                        <div class="tarjeta-estadistica estadistica-zonas">
                            <div class="titulo-estadistica">Distribución Zonas</div>
                            <div class="valor-estadistica" style="font-size: 1.1em; line-height: 1.6;">
                                <span class="punto punto-interior"></span>Int: <xsl:value-of select="count(//reserva[datos-reserva/zona-preferencia='interior'])"/> |
                                <span class="punto punto-terraza"></span>Ter: <xsl:value-of select="count(//reserva[datos-reserva/zona-preferencia='terraza'])"/><br/>
                                <span class="punto punto-jardin"></span>Jar: <xsl:value-of select="count(//reserva[datos-reserva/zona-preferencia='jardin'])"/> |
                                <span class="punto punto-barra"></span>Bar: <xsl:value-of select="count(//reserva[datos-reserva/zona-preferencia='barra'])"/>
                            </div>
                            <div class="subtitulo-estadistica">Mesas por área</div>
                        </div>

                    </div>
                    
                    <table>
                        <thead>
                            <tr>
                                <th>ID / Estado</th>
                                <th>Cliente / Contacto</th>
                                <th>Localización</th>
                                <th>Fecha y Hora</th>
                                <th>Detalles Reserva</th>
                                <th>Pago</th>
                                <th>Preferencias y Alergias</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- 
                              <xsl:apply-templates>: Esta etiqueta es magia pura. En lugar de escribir aquí mismo
                              todo el código de las filas de la tabla (que haría que el archivo fuera larguísimo y lioso),
                              le decimos: "Oye, busca todas las etiquetas 'reserva' dentro de 'reservas' en el XML, y 
                              aplícales el molde (template) que he definido más abajo". Es como delegar el trabajo.
                            -->
                            <xsl:apply-templates select="reservas/reserva">
                                <!-- 
                                  <xsl:sort>: Esto ordena los datos antes de pintarlos. 
                                  Aquí le decimos que los ordene por su fecha, de forma descendente (los más recientes primero).
                                -->
                                <xsl:sort select="datos-reserva/fecha" order="descending"/>
                            </xsl:apply-templates>
                        </tbody>
                    </table>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <!-- 
      ========================================================================================
      <xsl:template match="reserva">: ESTE ES EL MOLDE INDIVIDUAL.
      Cada vez que el 'apply-templates' de arriba encuentre una reserva, usará todo este bloque 
      para convertir los datos de esa reserva concreta en una fila (<tr>) para nuestra tabla HTML.
      ========================================================================================
    -->
    <xsl:template match="reserva">
        <tr>
            <!-- 
              <xsl:attribute>: Sirve para inyectarle atributos HTML a la etiqueta en la que estamos (el <tr>).
              Por ejemplo, aquí le estamos añadiendo la clase (class="...").
            -->
            <xsl:attribute name="class">
                <!-- 
                  <xsl:choose>, <xsl:when> y <xsl:otherwise>: 
                  Esto es un semáforo de decisiones (como un if-else, o un switch).
                  Pregunta: "¿Qué estado tiene esta reserva?".
                  - CUANDO (when) es 'confirmada', pinto la clase 'fila-confirmada'.
                  - CUANDO (when) es 'pendiente', pinto la clase 'fila-pendiente'.
                -->
                <xsl:choose>
                    <xsl:when test="@estado = 'confirmada'">fila-confirmada</xsl:when>
                    <xsl:when test="@estado = 'pendiente'">fila-pendiente</xsl:when>
                </xsl:choose>
            </xsl:attribute>
            
            <td>
                <span class="texto-id"><xsl:value-of select="@id"/></span><br/>
                <span class="estado-icono">
                    <!-- Semáforo sin emojis, con abreviaturas profesionales -->
                    <xsl:choose>
                        <xsl:when test="@estado = 'confirmada'">OK - </xsl:when>
                        <xsl:otherwise>PEND. - </xsl:otherwise>
                    </xsl:choose>
                    <!-- Aquí imprimimos el valor del atributo estado del XML -->
                    <span class="capitalizar"><xsl:value-of select="@estado"/></span>
                </span>
            </td>
            
            <td>
                <strong><xsl:value-of select="cliente/nombre-cliente"/></strong><br/>
                <small><xsl:value-of select="cliente/telefono-cliente"/></small><br/>
                <small><xsl:value-of select="cliente/email"/></small>
            </td>
            
            <td>
                <xsl:value-of select="local/nombre-local"/><br/>
                <small><xsl:value-of select="local/direccion"/></small>
            </td>
            
            <td>
                <xsl:value-of select="datos-reserva/fecha"/><br/>
                <span class="hora"><xsl:value-of select="datos-reserva/hora"/></span>
            </td>
            
            <td>
                Mesa: <strong><xsl:value-of select="datos-reserva/zona-preferencia/@mesa"/></strong><br/>
                
                <!-- Lógica de Zonas y Puntos de Color -->
                <xsl:choose>
                    <xsl:when test="datos-reserva/zona-preferencia = 'interior'">
                        <span class="punto punto-interior"></span>
                    </xsl:when>
                    <xsl:when test="datos-reserva/zona-preferencia = 'terraza'">
                        <span class="punto punto-terraza"></span>
                    </xsl:when>
                    <xsl:when test="datos-reserva/zona-preferencia = 'jardin'">
                        <span class="punto punto-jardin"></span>
                    </xsl:when>
                    <xsl:when test="datos-reserva/zona-preferencia = 'barra'">
                        <span class="punto punto-barra"></span>
                    </xsl:when>
                </xsl:choose>
                Zona: <span class="capitalizar"><xsl:value-of select="datos-reserva/zona-preferencia"/></span><br/>
                
                Pax: <xsl:value-of select="datos-reserva/numero-comensales"/><br/>
                
                <!-- Lógica de Tipo de Plato -->
                <xsl:choose>
                    <xsl:when test="datos-reserva/@tipo-plato = 'degustacion'">
                        <span class="etiqueta-plato etiqueta-degustacion">Menú Degustación</span>
                    </xsl:when>
                    <xsl:when test="datos-reserva/@tipo-plato = 'carta'">
                        <span class="etiqueta-plato etiqueta-carta">A la Carta</span>
                    </xsl:when>
                    <xsl:when test="datos-reserva/@tipo-plato = 'menu'">
                        <span class="etiqueta-plato etiqueta-menu">Menú del Día</span>
                    </xsl:when>
                </xsl:choose>

                <!-- 
                  <xsl:if>: Es una pregunta directa simple. "Si pasa esto, haz lo de dentro".
                  Aquí dice: "Si el número de comensales es mayor (>) que 4, entonces imprime 
                  en pantalla la alerta de 'Grupo Grande'". Si son 4 o menos, se lo salta y no hace nada.
                -->
                <xsl:if test="datos-reserva/numero-comensales > 4">
                    <br/><span class="etiqueta-alerta">GRUPO GRANDE</span>
                </xsl:if>
            </td>
            
            <td>
                <xsl:if test="datos-reserva/@pago">
                    <span class="precio"><xsl:value-of select="datos-reserva/@pago"/>€</span>
                </xsl:if>
                <xsl:if test="not(datos-reserva/@pago)">
                    <small>Pendiente pago</small>
                </xsl:if>
                
                <!-- ALERTA: Cliente VIP (Gasto > 50€) -->
                <xsl:if test="datos-reserva/@pago > 50">
                    <br/><span class="etiqueta-vip">CLIENTE VIP</span>
                </xsl:if>
            </td>
            
            <td>
                <!-- 
                  <xsl:for-each>: Es un bucle repetidor. 
                  Le estamos diciendo: "Busca dentro del XML todas las etiquetas <alergia> de este cliente 
                  (que no sean la palabra 'ninguna'). Por cada una que encuentres, repite este trozo de código".
                  Así, si un cliente tiene 3 alergias, imprimirá 3 spans automáticos.
                -->
                <xsl:for-each select="preferencias/alergias-restricciones/alergia[. != 'ninguna']">
                    <!-- El punto "." significa "el valor actual por el que vamos en el bucle" (ej: "gluten") -->
                    <span class="alerta-alergia">
                        <xsl:choose>
                            <xsl:when test=". = 'gluten'">🌾</xsl:when>
                            <xsl:when test=". = 'lactosa'">🥛</xsl:when>
                            <xsl:when test=". = 'frutos secos'">🥜</xsl:when>
                            <xsl:when test=". = 'marisco'">🦐</xsl:when>
                            <xsl:when test=". = 'huevo'">🥚</xsl:when>
                            <xsl:when test=". = 'soja'">🌱</xsl:when>
                            <xsl:otherwise>⚠️</xsl:otherwise>
                        </xsl:choose> Alergia: <span class="capitalizar"><xsl:value-of select="."/></span>
                    </span><br/>
                </xsl:for-each>
                
                <xsl:if test="preferencias/sillita-bebe">
                    <!-- 
                      <xsl:element>: Sirve para crear una etiqueta HTML de cero dinámicamente.
                      Aquí le decimos "créame una etiqueta <span>" y dentro le mete la clase y el texto.
                    -->
                    <xsl:element name="span">
                        <xsl:attribute name="class">etiqueta-bebe</xsl:attribute>
                        [i] Sillita bebé
                    </xsl:element><br/>
                </xsl:if>
                
                <small><i><xsl:value-of select="preferencias/notas-adicionales"/></i></small>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>