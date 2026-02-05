#!/bin/bash
# pdf-gen.sh - Generate a PDF file of specified size
# Usage: ./pdf-gen.sh <output-file> <size-in-kb>

# Function to pad PDF file to desired size using PDF comments
pad_pdf_file() {
    local file="$1"
    local target_kb="$2"
    local current_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    local target_size=$((target_kb * 1024))
    
    if [ $current_size -lt $target_size ]; then
        local padding_size=$((target_size - current_size))
        # Add padding as PDF comments (valid PDF content)
        # PDF comments start with % and go to end of line
        printf '\n%%%% Padding: ' >> "$file"
        head -c $((padding_size - 15)) /dev/zero | tr '\0' 'X' >> "$file"
        printf '\n' >> "$file"
    fi
}

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
    
    pad_pdf_file "$OUTPUT_FILE" "$SIZE_KB"
    
else
    # Use ghostscript or imagemagick if available
    if command -v gs &> /dev/null; then
        gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="$OUTPUT_FILE" -c "showpage" 2>/dev/null
    elif command -v convert &> /dev/null; then
        convert -size 612x792 xc:white "$OUTPUT_FILE" 2>/dev/null
    fi
    
    pad_pdf_file "$OUTPUT_FILE" "$SIZE_KB"
fi

FINAL_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
FINAL_SIZE_KB=$((FINAL_SIZE / 1024))

echo "✓ PDF generated: $OUTPUT_FILE"
echo "  Size: ${FINAL_SIZE_KB}KB (${FINAL_SIZE} bytes)"
