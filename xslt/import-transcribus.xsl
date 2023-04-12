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
    
    <xsl:output method="xml" indent="no" encoding="UTF-8" exclude-result-prefixes="#all"/>
    
    <xsl:include href="lib/util.xsl"/>
    <xsl:include href="lib/pagination-core.xsl"/>
    <xsl:include href="lib/default-text-tidying.xslt"/>
    
    <xsl:param name="full_path_to_cudl_data_source" as="xs:string*"/>
    
    <xsl:variable name="selected_path_to_cudl_source">
        <xsl:choose>
            <xsl:when test="replace($full_path_to_cudl_data_source,'/$','') != ''">
                <xsl:value-of select="replace($full_path_to_cudl_data_source,'/$','')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="xslt_repo_root" select="concat(replace(resolve-uri('.'),'/$',''), '/..')" as="xs:string"/>
                <xsl:value-of select="string-join(($xslt_repo_root, 'staging-cudl-data-source'), '/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="subpath_to_tei_dir" select="'items/data/tei'"/>
    
    <xsl:variable name="export_root" select="/*"/>
    
    <xsl:variable name="cudl_filename" select="//tei:idno[@type='external'][matches(.,'https://cudl.lib.cam.ac.uk/iiif/')]/tokenize(replace(.,'/\s*$',''), '/')[last()]" />
    <xsl:variable name="path_to_cudl_file" select="replace(concat(string-join(($selected_path_to_cudl_source, $subpath_to_tei_dir, $cudl_filename),'/'),'/',$cudl_filename,'.xml'),'^file:','')"/>
    <xsl:variable name="cudl_root" select="if (doc-available($path_to_cudl_file)) then doc($path_to_cudl_file)/* else ()"/>
    
    <xsl:key name="export_surfaces" match="//tei:surface" use="replace(@xml:id, 'facs_', '')" />
    <xsl:key name="cudl_pb" match="//tei:pb" use="replace(replace(@facs, '^\D+(\d+)$', '$1'),'^0+', '')" />
    
    <!-- Low priority template to ensure that all nodes are copied - unless
         a template with a higher priority (either specified or automatically
         computed) is supplied.
    -->
    <xsl:template match="node() | @*" mode="#all" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="add-page-content">
        <xsl:call-template name="process-text-nodes">
            <xsl:with-param name="string" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:variable name="paginated_content" as="item()*">
        <xsl:apply-templates select="//tei:body" mode="paginate"/>
    </xsl:variable>
    
    <xsl:template match="tei:body" mode="paginate">
        <xsl:variable name="context" select="."/>
        <xsl:for-each select="descendant::tei:pb[util:has-valid-context(.)]">
            <xsl:variable name="next-page" select="(following::tei:pb[util:has-valid-context(.)])[1]" as="item()*"/>
            <xsl:variable name="final-node" select="if ($next-page) then $next-page else following::node()[last()]"/>
            <xsl:variable name="image-number" select="replace(@facs,'#', '')"/>
            
            <div xml:id="surface-{$image-number}" facs="#{$image-number}" type="transkribus_page_container">
                <xsl:apply-templates select="util:page-content(.,$final-node, $context)" mode="pagination-postprocess"/>
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tei:body" priority="2" mode="pagination-postprocess">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:body[not(child::text()[normalize-space(.)])]
                                 [not(*[not(self::tei:div)])]
                                 [count(tei:div) eq 1]
                                 /tei:div" mode="pagination-postprocess">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="/" mode="#default">
        <xsl:apply-templates select="$cudl_root"/>
    </xsl:template>
    
    <xsl:template match="/tei:TEI">
        <xsl:text>&#10;</xsl:text>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:surface">
        <xsl:variable name="cudl_context" select="." />
        <xsl:variable name="surface_number" select="replace(@xml:id,'^\D+(\d+)$', '$1')"/>
        <xsl:variable name="imported_surface" select="transkribus:get-exported-surface($surface_number)"/>
        
        <xsl:copy>
            <xsl:copy-of select="@* except (@lrx, @lry, @ulx, @uly)"/>
            <xsl:copy-of select="$imported_surface/(@lrx, @lry, @ulx, @uly)"/>
            
            <xsl:for-each select="*|comment()">
                <xsl:value-of select="util:indent-elem(.)"/>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:if test="$imported_surface[tei:zone]">
                <xsl:apply-templates select="$imported_surface/tei:zone" mode="add-zone"/>
            </xsl:if>
            <xsl:value-of select="util:indent-elem(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:zone" mode="add-zone">
        <xsl:value-of select="util:indent-to-depth(count(ancestor::*) + 2)"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*|comment()" mode="add-zone"/>
            <xsl:if test="parent::tei:surface">
                <xsl:value-of select="util:indent-to-depth(count(ancestor::*) + 2)"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:zone">
        <!-- Ignore zone elements in CUDL file -->
        <xsl:apply-templates select="*|comment()"/>
    </xsl:template>
    
    <xsl:template match="tei:body">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <div>
                <xsl:for-each select="descendant::tei:pb">
                    <xsl:variable name="current_pb" select="."/>
                    <xsl:variable name="surface_num" select="replace(@facs, '^\D+(\d+)$', '$1')" as="xs:string"/>
                    <xsl:value-of select="util:indent-elem($current_pb)"/>
                    <xsl:choose>
                        <!-- Expensive replace -->
                        <xsl:when test="$paginated_content[replace(@xml:id, '^\D+(\d+)$', '$1') = $surface_num]">
                            <xsl:apply-templates select="$paginated_content[replace(@xml:id, '^\D+(\d+)$', '$1') = $surface_num]" mode="add-page-content"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$current_pb"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </div>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:div[@type='transkribus_page_container']" mode="add-page-content">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:pb" mode="add-page-content">
        
        <xsl:copy-of select="transkribus:get-cudl-pb(.)"/>
    </xsl:template>
    
    <xsl:template match="tei:ab[not(normalize-space(@type))]/@type" mode="add-page-content"/>
    
    <!-- Optimised getters -->
    
    <xsl:function name="transkribus:get-cudl-pb" as="item()*">
        <xsl:param name="imported_pb"/>
        
        <xsl:variable name="target_surface_num" select="$imported_pb/replace(replace(@facs,'^\D+(\d+)$', '$1'),'^0+','')"/>
        <xsl:copy-of select="key('cudl_pb', $target_surface_num, $cudl_root)"/>
    </xsl:function>
    
    <xsl:function name="transkribus:get-exported-surface" as="item()*">
        <xsl:param name="surface_number"/>
        
        <xsl:copy-of select="key('export_surfaces', $surface_number, $export_root)"/>
    </xsl:function>

</xsl:stylesheet>