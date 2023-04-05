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
    
    <xsl:key name="anchors-by-id" match="tei:anchor[@xml:id]" use="('__all__', concat('#', @xml:id))"/>
    <xsl:key name="add-spans-by-span-to" match="tei:addSpan[@spanTo]" use="('__all__', @spanTo)"/>
    
    <xsl:function name="util:page-content" as="node()*">
        <xsl:param name="pb1" as="node()"/>
        <xsl:param name="pb2" as="node()"/>
        <xsl:param name="node" as="node()"/>
        
        <xsl:choose>
            <xsl:when test="$node[self::tei:teiHeader]">
                <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node[self::tei:facsimile]">
                <xsl:element name="{name($node)}" namespace="{$node/namespace-uri()}">
                    <xsl:copy-of select="$node/@*"/>
                    <xsl:copy-of select="$node/tei:surface"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$node[self::*]">
                <!-- $node is an element() -->
                <xsl:choose>
                    <xsl:when test="$node is $pb1">
                        <xsl:copy-of select="$node"/>
                    </xsl:when>
                    <!-- some $n in $node/descendant::* satisfies
                        ($n is $pb1 or $n is $pb2) -->
                    <xsl:when test="$node[descendant::tei:pb[. is $pb1 or . is $pb2]]">
                        <xsl:element name="{name($node)}" namespace="{$node/namespace-uri()}">
                            <xsl:sequence select="for $i in ( $node/node() |
                                $node/@* ) return util:page-content($pb1, $pb2, $i)"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="($node >> $pb1) and ($node &lt;&lt;
                        $pb2)">
                        <xsl:copy-of select="$node"/>
                    </xsl:when>
                    <xsl:otherwise />
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$node[count(. | ../@*) = count(../@*)]">
                <!-- $node is an attribute -->
                <xsl:attribute name="{name($node)}">
                    <xsl:sequence select="data($node)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="($node >> $pb1) and ($node &lt;&lt;
                        $pb2)">
                        <xsl:copy-of select="$node"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="util:line-content" as="node()*">
        <xsl:param name="pb1" as="node()"/>
        <xsl:param name="pb2" as="node()"/>
        <xsl:param name="node" as="node()"/>
        
        <xsl:choose>
            <xsl:when test="$node[self::tei:teiHeader]">
                <xsl:copy-of select="$node"/>
            </xsl:when>
            <xsl:when test="$node[self::tei:facsimile]">
                <xsl:element name="{name($node)}" namespace="{$node/namespace-uri()}">
                    <xsl:copy-of select="$node/@*"/>
                    <xsl:copy-of select="$node/tei:surface"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$node[self::*]">
                <!-- $node is an element() -->
                <xsl:choose>
                    <xsl:when test="$node is $pb1">
                        <xsl:copy-of select="$node"/>
                    </xsl:when>
                    <!-- some $n in $node/descendant::* satisfies
                        ($n is $pb1 or $n is $pb2) -->
                    <xsl:when test="$node[descendant::tei:lb[. is $pb1 or . is $pb2]]">
                        <xsl:element name="{name($node)}" namespace="{$node/namespace-uri()}">
                            <xsl:sequence select="for $i in ( $node/node() |
                                $node/@* ) return util:line-content($pb1, $pb2, $i)"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="($node >> $pb1) and ($node &lt;&lt;
                        $pb2)">
                        <xsl:copy-of select="$node"/>
                    </xsl:when>
                    <xsl:otherwise />
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$node[count(. | ../@*) = count(../@*)]">
                <!-- $node is an attribute -->
                <xsl:attribute name="{name($node)}">
                    <xsl:sequence select="data($node)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="($node >> $pb1) and ($node &lt;&lt;
                        $pb2)">
                        <xsl:copy-of select="$node"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="util:has-valid-context" as="xs:boolean">
        <xsl:param name="context"/>
        
        <!-- Presume that if @next contains content that it's accurate to increase excecution speed of script -->
        <xsl:sequence select="exists($context[normalize-space(@next)!=''])
            or exists($context[normalize-space(@prev)!=''])
            or exists($context[not(ancestor::tei:add | ancestor::tei:note) and
            not(util:is-in-add-span($context))])"/>
    </xsl:function>
    
    <xsl:function name="util:is-in-add-span" as="xs:boolean">
        <xsl:param name="context" as="node()"/>
        
        <xsl:variable name="preceding-add-spans"
            select="key('add-spans-by-span-to', '__all__', root($context))[. &lt;&lt; $context]"/>
        <xsl:variable name="span-ends"
            select="key('anchors-by-id',
            (for $span in $preceding-add-spans return $span/@spanTo),
            root($context))[. >> $context]"/>
        <xsl:sequence select="boolean($span-ends)"/>
    </xsl:function>
    
</xsl:stylesheet>