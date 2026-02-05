# bash_bin
A collection of helpful bash scripts

## Scripts

### activate.sh
Activates a Python virtual environment by recursively searching for an 'activate' file.

**Usage:**
```bash
./activate.sh              # Search in current directory
./activate.sh /path/to/dir # Search in specified directory
```

### new-script.sh
Makes a script executable and adds it to git (if in a git repository).

**Usage:**
```bash
./new-script.sh <script-name>
```

**Example:**
```bash
./new-script.sh my-new-script.sh
```

### pdf-gen.sh
Generates a PDF file of a specified size.

**Usage:**
```bash
./pdf-gen.sh [output-file] [size-in-kb]
```

**Examples:**
```bash
./pdf-gen.sh                    # Creates output.pdf (100KB)
./pdf-gen.sh mydoc.pdf          # Creates mydoc.pdf (100KB)
./pdf-gen.sh mydoc.pdf 500      # Creates mydoc.pdf (500KB)
```
