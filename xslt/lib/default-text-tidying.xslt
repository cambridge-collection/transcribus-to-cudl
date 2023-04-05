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
    
    <xsl:function name="transkribus:regex_class_to_escape" as="xs:string">
        <!-- Define a regex class containing all the characters that you want
             to appear as numeric entity references rather than literal unicode
             characters so that it is easier for an editor to edit the file
             in an XML editor.
             This is done because a fair number of the pre-modern manuscript glyphs 
             aren't present within the fonts used by most XML Editors. How this is dealt
             with varies from OS to OS and application to application, but the most 
             common result is for these characters to be displayed as an empty rectangle.
             These rectangles make editing the file more difficult since it's impossible to
             differentiate the glyphs from each other visually. Outputting the glyphs as numeric
             entities makes it evident what each one is.
        -->
        <xsl:value-of select="'[&#xE000;-&#xF8FF;\p{IsLatinExtended-D}&#x2125;&#x2108;]'"/>
    </xsl:function>
    
    <xsl:template name="process-text-nodes" as="item()*">
        <!-- The core text tidying template for all text nodes
             This template calls transkribus:char-tidy to perform a global
             replace/tidy of certain characters, normalises the glyphs to Unicode Normalisation 
             Form KC (https://unicode.org/reports/tr15/#Norm_Forms) and then outputs any of the
             glyphs caught by the regex from transkribus:regex_class_to_escape as numeric entities
        -->
        <xsl:param name="string"/>
        
        <xsl:variable name="chars_tidied" select="transkribus:char-tidy($string)"/>
        <xsl:variable name="string_normalised" select="normalize-unicode($chars_tidied, 'NFKC')"/>
        
        <xsl:analyze-string select="$string_normalised" regex="{transkribus:regex_class_to_escape()}">
            <xsl:matching-substring>
                <xsl:text disable-output-escaping="yes">&amp;#x</xsl:text>
                <xsl:value-of select="util:int-to-hex(string-to-codepoints(.))"/>
                <xsl:text>;</xsl:text>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:function name="transkribus:char-tidy" as="xs:string*">
        <!-- Stub function for any global replaces that are needed for transkribus-generated
             output, such as replacing combining tilde with a combining macron
        -->
        <xsl:param name="raw_string"/>
        
        <xsl:variable name="string_decomposed" select="normalize-unicode(normalize-unicode($raw_string, 'NFKC'),'NFKD')"/>
        
        <xsl:value-of select="normalize-unicode($string_decomposed, 'NFKC')"/>
    </xsl:function>
</xsl:stylesheet>