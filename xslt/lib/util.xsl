<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:mml="http://www.w3.org/1998/Math/MathML" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    
    
    <xsl:function name="util:get-filename" as="xs:string">
        <xsl:param name="node"/>
        
        <xsl:value-of select="tokenize(document-uri(root($node)),'/')[last()]"/>
    </xsl:function>
    
    <xsl:function name="util:get-dir" as="xs:string">
        <xsl:param name="node"/>
        
        <xsl:value-of select="replace(string-join(tokenize(document-uri(root($node)),'/')[position() lt last()], '/'),'^file:', '')"/>
    </xsl:function>
    
    <xsl:function name="util:int-to-hex" as="xs:string">
        <xsl:param name="in" as="xs:integer"/>
        <xsl:sequence select="if ($in eq 0) then '0'
            else concat(
                        if ($in gt 16) 
                        then util:int-to-hex($in idiv 16) 
                        else '',
                        substring('0123456789ABCDEF', ($in mod 16) + 1, 1))"/>
        
    </xsl:function>
    
    <xsl:function name="util:indent-elem" as="xs:string*">
        <!-- Indent according to the depth of the passed element -->
        <xsl:param name="elem"/>
        
        <xsl:value-of select="util:indent-to-depth(count($elem/ancestor::*))"/>
    </xsl:function>
    
    <xsl:function name="util:indent-to-depth" as="xs:string*">
        <!-- Indent according to the depth of the value provided -->
        <xsl:param name="indent_level" as="xs:integer"/>
        
        <xsl:variable name="spaces-per-level" select="'    '" as="xs:string*"/>
        
        <xsl:variable name="text" as="xs:string*">
            <xsl:choose>
                <xsl:when test="$indent_level castable as xs:integer">
                    <xsl:sequence select="'&#10;'"/>
                    <xsl:for-each select="1 to xs:integer($indent_level)">
                        <xsl:sequence select="$spaces-per-level"/>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join($text,'')"/>
    </xsl:function>
    
</xsl:stylesheet>