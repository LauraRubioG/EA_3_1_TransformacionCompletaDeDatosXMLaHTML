<?xml version="1.0" encoding="UTF-8"?>

<!--CONFIGURACION INICIAL-->
<!-- 
  <xsl:stylesheet>: Es la etiqueta principal, es la que nos indica que es un archivo XSLT. El elemento raiz.
  y el xml:xsl que tiene dentro como atributo nos indica la dirección oficial de las reglas de un XSLT
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- 
      <xsl:output>: Esta etiqueta configura cómo será el archivo final. Es decir, dice "De esto saca un HTML,
      usando el idioma de caracteres UFT-8(que este sirve para que se vean las tildes y la ñ) y
      ponlo ordenado, para ello el 'indent'"
    -->
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    
    <!-- 
      <xsl:strip-space> y <xsl:preserve-space>: 
      Usamos strip-space para limpiar los espacios en blanco innecesarios que vienen del XML, esto lo usamos para
      no ensuciar el código.
      Y el preserve-space es para todo lo contrario, para no borrar esos espacio. Por ello aqui lo usamos para
      indicarle que no borre los espacios de notas-adicionales
    -->
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="notas-adicionales"/>

    <!-- ESTRUCTURA PRINCIPAL -->

    <!-- 
      <xsl:template match="/">: Esta estiquieta es el 'Cerebro'. El simbolo / indica que todo lo siguiente se aplica
      el inicio del XML. Y aquí dentro es donde se crea la estructura de la página HTML, usanod el <head> y el <body>
    -->
    <xsl:template match="/">
        <html>
            <head>
                <title>Panel de Control de Reservas Detallado</title>
                <link rel="stylesheet" type="text/css" href="estilos.css"/>
            </head>
            <body>
                <!-- 
                  <xsl:comment>: Esta etiqueta crea un comentario que aparecerá en el código fuente de la web, pero que el usuario no
                  verá en la pantalla. Es decir, si tenemos por ejemplo un HTML de un XSLT bastante dificil, con esta etiqueta podemos
                  poner "pistas" dentro del código para nosotros o para otros programadores que vean el código en el fututo
                -->
                <xsl:comment> Dashboard HTML generado dinámicamente mediante XSLT </xsl:comment>
                <div class="contenedor">
                    <h1>DASHBOARD DE RESERVAS</h1>
                    <p class="total">Análisis y estado general del restaurante</p>

                    <!-- PANEL CON XPATH -->
                    <div class="panel-cuadricula">
                        
                        <!-- Consula XPATH 1: Estado de las reservas -->
                        <div class="tarjeta-estadistica estadistica-estado">
                            <div class="titulo-estadistica">confirmaciones</div>
                            <div class="valor-estadistica">
                                <!-- 
                                  <xsl:value-of>: Esta etiqueta sirve para mostrar un valor por pantalla. Va al XML
                                  y coge o calcula el dato que le pedimos en el 'select' de la etiqueta, y lo muestra.
                                  En esta consulta le decimos que cuenta cuántas reservas tenemos confirmadas.
                                  Va a reserva, al atributo estado y mira las que indica confirmadas y las cuenta.
                                -->
                                <xsl:value-of select="count(//reserva[@estado='confirmada'])"/>
                                <span class="fraccion-total"> / <xsl:value-of select="count(//reserva)"/></span>
                            </div>
                            <div class="subtitulo-estadistica">Reservas confirmadas (total)</div>
                        </div>

                        <!-- Consula XPATH 2: Ingresos proyectados -->
                        <div class="tarjeta-estadistica estadistica-ingresos">
                            <div class="titulo-estadistica">Ingresos Estimados</div>
                            <div class="valor-estadistica">
                                <xsl:value-of select="sum(//reserva/datos-reserva/@pago)"/>€
                            </div>
                            <div class="subtitulo-estadistica">Suma de reservas con pago</div>
                        </div>

                        <!-- Consula XPATH 3: Media de comensales -->
                        <div class="tarjeta-estadistica estadistica-comensales">
                            <div class="titulo-estadistica">Media Comensales</div>
                            <div class="valor-estadistica">
                                <xsl:value-of select="format-number(sum(//reserva/datos-reserva/numero-comensales) div count(//reserva), '#.0')"/>
                            </div>
                            <div class="subtitulo-estadistica">Comensales totales: <xsl:value-of select="sum(//reserva/datos-reserva/numero-comensales)"/></div>
                        </div>

                        <!-- Consula XPATH 4: Alerta de riesgo (Negocio) -->
                        <div class="tarjeta-estadistica estadistica-alertas">
                            <div class="titulo-estadistica">Faltan por pagar</div>
                            <div class="valor-estadistica valor-alerta">
                                <xsl:value-of select="count(//reserva[not(datos-reserva/@pago)])"/>
                            </div>
                            <div class="subtitulo-estadistica">Reservas de riesgo sin importe</div>
                        </div>

                        <!-- Consula XPATH 5: Zonas (NUEVO XPATH) -->
                        <div class="tarjeta-estadistica estadistica-zonas">
                            <div class="titulo-estadistica">Distribución Zonas</div>
                            <div class="valor-estadistica valor-zonas">
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
                                <th>Local / Estado Reserva</th>
                                <th>Información Cliente</th>
                                <th>Localización</th>
                                <th>Fecha y Hora</th>
                                <th>Detalles Reserva</th>
                                <th>Pago</th>
                                <th>Preferencias y Alergias</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- 
                              <xsl:apply-templates>: Esta etiqueta hace que nos ahorremos mucho código. Hace un salto, le indicamos
                              con el select que busque la etiqueta 'reserva' dentro de 'reservas' en el XML y que aplique
                              el código (template) definido abajo.
                            -->
                            <xsl:apply-templates select="reservas/reserva">
                                <!-- 
                                  <xsl:sort>: Esta etiqueta ordena los datos anteriores. 
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
      <xsl:template match="reserva">: ES EL CÓDIGO INDIVIDUAL.
      Cada vez que el 'apply-templates' de arriba encuentre una reserva, usará todo este bloque 
      para convertir los datos de esa reserva concreta en una fila (<tr>) para nuestra tabla HTML.
    -->
    <xsl:template match="reserva">
        <tr>
            <!-- 
              <xsl:attribute>: Sirve para añadir una clase de CSS a una etiqueta 
              HTML de forma dinámica según los datos.
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
            <!--
                Primera td de la columna: Local/Estado Reserva
            -->
            <td>
                <span class="texto-id"><xsl:value-of select="@id"/></span><br/>
                <span class="estado-icono">
                    <xsl:choose>
                        <xsl:when test="@estado = 'confirmada'">OK - </xsl:when>
                        <xsl:otherwise>PEND. - </xsl:otherwise>
                    </xsl:choose>
                    <!-- Aquí imprimimos el valor del atributo estado del XML -->
                    <span class="capitalizar"><xsl:value-of select="@estado"/></span>
                </span>
            </td>
            <!--
                Segunda td de la columna: Información Cliente
            -->
            <td>
                <!-- 
                    Aquí indiamos con el xs:value-off que queremsos que aparezca con el select
                    y usamos el strong y el small para indicar el texto
                -->
                <strong><xsl:value-of select="cliente/nombre-cliente"/></strong><br/>
                <small><xsl:value-of select="cliente/telefono-cliente"/></small><br/>
                <small><xsl:value-of select="cliente/email"/></small>
            </td>
            <!--
                Tercera td de la columna: Localización
            -->
            <td>
                <xsl:value-of select="local/nombre-local"/><br/>
                <small><xsl:value-of select="local/direccion"/></small>
            </td>
            <!--
                Cuarta td de la columna: Fecha y Hora
            -->
            <td>
                <xsl:value-of select="datos-reserva/fecha"/><br/>
                <span class="hora"><xsl:value-of select="datos-reserva/hora"/></span>
            </td>
            <!--
                Quinta td de la columna: Detalles Reserva
            -->
            <td>
                Mesa: <strong><xsl:value-of select="datos-reserva/zona-preferencia/@mesa"/></strong><br/>
                
                <!-- Choose que indica: Lógica de Zonas y Puntos de Color -->
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
                
                <!-- Choose que indica:Lógica de Tipo de Plato -->
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
            <!--
                Sexta td de la columna: Pago
            -->
            <td class="celda-centrada">
                <xsl:if test="datos-reserva/@pago">
                    <span class="precio"><xsl:value-of select="datos-reserva/@pago"/>€</span>
                </xsl:if>
                <xsl:if test="not(datos-reserva/@pago)">
                    <span class="alerta-pago">⚠️ Pendiente pago</span>
                </xsl:if>
            </td>
            <!--
                Septima td de la columna: Referencias y Alergias
            -->
            <td class="celda-centrada">
                <!-- 
                  <xsl:for-each>: Es un bucle repetidor. 
                  Le estamos diciendo: "Busca dentro del XML todas las etiquetas <alergia> de este cliente 
                  (que no sean la palabra 'ninguna'). Por cada una que encuentres, repite este trozo de código".
                  Así, si un cliente tiene 3 alergias, imprimirá 3 spans automáticos.
                -->
                <xsl:for-each select="preferencias/alergias-restricciones/alergia[. != 'ninguna']">
                    <!-- El punto "." significa "el valor actual por el que vamos en el bucle" (ej: "gluten") en el momento preciso-->
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
                        👶🪑 Sillita bebé
                    </xsl:element><br/>
                </xsl:if>
                
                <small><i><xsl:value-of select="preferencias/notas-adicionales"/></i></small>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>