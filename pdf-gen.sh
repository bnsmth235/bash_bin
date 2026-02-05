#!/bin/bash
# pdf-gen.sh - Generate a PDF file of specified size
# Usage: ./pdf-gen.sh <output-file> <size-in-kb>

# Default values
OUTPUT_FILE="output.pdf"
SIZE_KB=100

# Parse arguments
if [ $# -ge 1 ]; then
    OUTPUT_FILE="$1"
fi

if [ $# -ge 2 ]; then
    SIZE_KB="$2"
fi

# Ensure output file has .pdf extension
if [[ ! "$OUTPUT_FILE" =~ \.pdf$ ]]; then
    OUTPUT_FILE="${OUTPUT_FILE}.pdf"
fi

# Check if required tools are available
if ! command -v gs &> /dev/null && ! command -v convert &> /dev/null; then
    echo "Generating PDF using basic method..."
    
    # Calculate approximate content size needed
    # PDF overhead is roughly 1KB, so we subtract that from target size
    CONTENT_SIZE=$((SIZE_KB - 1))
    
    # Create a simple PDF with text content
    cat > "$OUTPUT_FILE" << 'EOF'
%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj
2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj
3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
/Contents 4 0 R
/Resources <<
/Font <<
/F1 <<
/Type /Font
/Subtype /Type1
/BaseFont /Helvetica
>>
>>
>>
>>
endobj
4 0 obj
<<
/Length 44
>>
stream
BT
/F1 12 Tf
100 700 Td
(Generated PDF) Tj
ET
endstream
endobj
xref
0 5
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000317 00000 n 
trailer
<<
/Size 5
/Root 1 0 R
>>
startxref
410
%%EOF
EOF
    
    # Pad the file to reach desired size
    CURRENT_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
    if [ $CURRENT_SIZE -lt $((SIZE_KB * 1024)) ]; then
        PADDING_SIZE=$(((SIZE_KB * 1024) - CURRENT_SIZE))
        dd if=/dev/zero bs=1 count=$PADDING_SIZE 2>/dev/null >> "$OUTPUT_FILE"
    fi
    
else
    # Use ghostscript or imagemagick if available
    if command -v gs &> /dev/null; then
        gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="$OUTPUT_FILE" -c "showpage" 2>/dev/null
    elif command -v convert &> /dev/null; then
        convert -size 612x792 xc:white "$OUTPUT_FILE" 2>/dev/null
    fi
    
    # Pad to desired size if needed
    CURRENT_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
    if [ $CURRENT_SIZE -lt $((SIZE_KB * 1024)) ]; then
        PADDING_SIZE=$(((SIZE_KB * 1024) - CURRENT_SIZE))
        dd if=/dev/zero bs=1 count=$PADDING_SIZE 2>/dev/null >> "$OUTPUT_FILE"
    fi
fi

FINAL_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
FINAL_SIZE_KB=$((FINAL_SIZE / 1024))

echo "✓ PDF generated: $OUTPUT_FILE"
echo "  Size: ${FINAL_SIZE_KB}KB (${FINAL_SIZE} bytes)"
