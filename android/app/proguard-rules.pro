# PdfBox-Android (pulled in transitively by pdf_combiner) references an optional
# JPEG-2000 codec that is not on the classpath. Silence the R8 warnings.
-dontwarn com.gemalto.jp2.JP2Decoder
-dontwarn com.gemalto.jp2.JP2Encoder
-dontwarn com.gemalto.jp2.**
-dontwarn com.tom_roush.pdfbox.**
