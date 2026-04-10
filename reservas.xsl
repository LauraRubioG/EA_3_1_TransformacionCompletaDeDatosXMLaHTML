<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <title>Panel de Control de Reservas Detallado</title>
                <link rel="stylesheet" type="text/css" href="estilos.css"/>
            </head>
            <body>
                <div class="container">
                    <h1>Panel de Control de Reservas</h1>
                    <p class="total">Total de reservas: <strong><xsl:value-of select="count(//reserva)"/></strong></p>
                    
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
                            <xsl:apply-templates select="reservas/reserva">
                                <xsl:sort select="datos-reserva/fecha" order="descending"/>
                            </xsl:apply-templates>
                        </tbody>
                    </table>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="reserva">
        <tr>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="@estado = 'confirmada'">fila-confirmada</xsl:when>
                    <xsl:when test="@estado = 'pendiente'">fila-pendiente</xsl:when>
                </xsl:choose>
            </xsl:attribute>
            
            <td>
                <span class="id-text"><xsl:value-of select="@id"/></span><br/>
                <span class="estado-icono">
                    <xsl:choose>
                        <xsl:when test="@estado = 'confirmada'">✓ </xsl:when>
                        <xsl:otherwise>? </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="@estado"/>
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
                Zona: <xsl:value-of select="datos-reserva/zona-preferencia"/><br/>
                Pax: <xsl:value-of select="datos-reserva/numero-comensales"/><br/>
                Menú: <xsl:value-of select="datos-reserva/@tipo-plato"/>
            </td>
            
            <td>
                <xsl:if test="datos-reserva/@pago">
                    <span class="precio"><xsl:value-of select="datos-reserva/@pago"/>€</span>
                </xsl:if>
                <xsl:if test="not(datos-reserva/@pago)">
                    <small>Pendiente pago</small>
                </xsl:if>
            </td>
            
            <td>
                <xsl:if test="preferencias/alergias-restricciones/alergia != 'ninguna'">
                    <span class="alerta-alergia">⚠️ <xsl:value-of select="preferencias/alergias-restricciones/alergia"/></span><br/>
                </xsl:if>
                
                <xsl:if test="preferencias/sillita-bebe">
                    <xsl:element name="span">
                        <xsl:attribute name="class">badge-bebe</xsl:attribute>
                        👶 Sillita bebé
                    </xsl:element><br/>
                </xsl:if>
                
                <small><i><xsl:value-of select="preferencias/notas-adicionales"/></i></small>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>