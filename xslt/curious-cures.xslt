<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:mml="http://www.w3.org/1998/Math/MathML" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util"
    xmlns:transkribus="http://cudl.lib.cam.ac.uk/xtf/ns/transkribus-import"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- This stylesheet contains project-specific overrides for default functionality -->
    
    <xsl:import href="import-transcribus.xsl"/>
    
    <xsl:function name="transkribus:regex_class_to_escape" as="xs:string">
        
        <!-- Regex class to escape ranges of unicode characters or named unicode blocks -->
        <xsl:value-of select="'[&#xE000;-&#xF8FF;\p{IsLatinExtended-D}&#x2125;&#x2108;]'"/>
    </xsl:function>
    
    <xsl:function name="transkribus:char-tidy" as="xs:string*">
        <!-- Stub function for any global replaces that are needed for transkribus-generated
             output, such as replacing combining tilde with a combining macron
        -->
        <xsl:param name="raw_string"/>
        
        <xsl:variable name="string_decomposed" select="normalize-unicode(normalize-unicode($raw_string, 'NFKC'),'NFKD')"/>
        
        <xsl:value-of select="normalize-unicode(replace($string_decomposed,'&#x0303;', '&#x0304;'), 'NFKC')"/>
    </xsl:function>

</xsl:stylesheet>