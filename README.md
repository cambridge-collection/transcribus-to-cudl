# Transkribus TEI to CUDL TEI

Contains the XSLT that converts and tidies Transkribus-exported TEI files into CUDL TEI files.

## Prerequisites

1. A TEI file exported from Transkribus
1. A local copy of `staging-cudl-data-source`. 

If `staging-cudl-data-source` is placed at the root level of this repository, it will be automatically discovered by the XSLT code. 

If it is placed anywhere else, you will need to pass the **full (not relative) path** to the XSLT using the `full_path_to_cudl_data_source` parameter.

## Running the transformation

The conversion code was designed to be easily extensible to enable project-specific needs. At present, there are two XSLT files that can be used to tidy and import the Transkribus file into a CUDL-flavoured version of TEI:

### import-transkribus.xsl

This is the core code within the project. It imports the file with minimal tidying. For many projects, this will likely be all that's required.

### curious-cures.xsl

Imports the file in CUDL with extra source-specific tidies. It relies on the core code in import-transkribus.xsl - albeit overriding a couple of core functions so that they better suit the project's needs.

## Extending the transformation

The XSLT was designed to be easily extensible.

The basic procedure is:

1. Create a new XSLT file for the project.
1. Add `<xsl:import href="import-transcribus.xsl"/>` as the first child of `<xsl:stylesheet>` so that the core functionalities of `import-transkribus.xsl` are available.
**NB:** It is vital to use `<xsl:import/>` rather than `<xsl:include/>`.  Imported templates/functions are automatically assigned a lower precedence to any defined within the calling XSLT file. That means that you can override any existing template/function by placing a project-specific one within the new project's xsl file.
1. Add new templates/functions and/or override existing ones by placing the project-specific code within the project's xsl file.

The project-specific changes for the Curious Cures Project currently focus on tidying up various glyphs present within the Transkribus file. It does this by overriding two core functions:

### transkribus:regex_class_to_escape()

This function ensures that certain glyphs appear in the XML as numeric entities (*e.g.* `&#xA751;`) rather than the actual glyph (*e.g.* a crossed p 'ꝑ'). A fair number of the pre-modern manuscript glyphs are not present within the fonts used by most XML Editors. How this is dealt with varies from OS to OS and application to application, but the most common result is for these characters to be displayed as an empty rectangle (or TOFU block, as it is often called).

Although the data itself is accurate, these rectangles make editing the file difficult since it's impossible to differentiate the glyphs visually. Outputting them as numeric entities makes it evident what each one is.

### transkribus:char-tidy()

This function performs global replaces required to tidy the imported text. It currently fixes Tranksribus's hit or miss ability to identify a suspension mark (overline/macron) appearing over a single character. Many of these suspension marks are judged to be combining tilde characters (`~`) rather than a combining macron. This function replaces the combining tilde with a combining macron.
