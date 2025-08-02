# ShiftSearch - CLI Tool

A ruby based CLI tool for searching and managing data with support for JSON datasets, flexible search options, and duplicate detection.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Command Options](#command-options)
- [Search Operations](#search-operations)
- [Output Formats](#output-formats)
- [Duplicate Detection](#duplicate-detection)
- [Error Handling](#error-handling)
- [Examples](#examples)
- [Development](#development)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- **Ruby 3.4** or higher
- **Bundler** gem for dependency management
- **Git** for cloning the repository

### Installing Ruby 3.4

#### Using rbenv (Recommended)

Install rbenv if not already installed

Refer to: <https://github.com/rbenv/rbenv>

```bash

# Install Ruby 3.4
rbenv install 3.4.5
rbenv global 3.4.5

# Verify installation
ruby --version
```

You can also use RVM (<https://github.com/rvm/rvm>)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/hexmo/shift-search.git
cd shift-search
```

### 2. Install Dependencies

```bash
# Install bundler if not already installed
gem install bundler

# Install project dependencies
bundle install
```

### 3. Verify Installation

```bash
# Check if the CLI is working
bin/shift_search --help
```

## Basic Usage

The ShiftSearch CLI provides several core functionalities:

- **Search**: Find clients by various fields
- **Duplicate Detection**: Identify duplicate email addresses
- **Flexible Output**: JSON or CSV format options
- **File Operations**: Work with different JSON datasets

## Command Options

```bash
-s, --search=QUERY               Search clients by name
-k, --key=KEY                    Field to search (default: full_name)
    --duplicates                 Find duplicate emails
-f, --file=FILE                  Path to JSON dataset (default: data/clients.json)
    --format=FORMAT              Output format: json or csv (default: json)
-o, --output=FILE                Output file path (optional)
-h, --help                       Show help
```

## Search Operations

### 1. Basic Search (Full Name)

Search by full name using the default key:

```bash
bin/shift_search -s "John Doe"
```

**Output:**

```json
[
  {
    "id": 1,
    "full_name": "John Doe",
    "email": "john.doe@gmail.com"
  }
]
```

### 2. Search by Custom Field

Search using a specific field (key):

```bash
bin/shift_search -s "john.doe@gmail.com" -k email
```

**Output:**

```json
[
  {
    "id": 1,
    "full_name": "John Doe",
    "email": "john.doe@gmail.com"
  }
]
```

### 3. Search with Alternate Data File

Use a different JSON dataset:

```bash
bin/shift_search -s "John Doe" -f data/clients2.json -k legal_name
```

**Output:**

```json
[
  {
    "id": 1,
    "legal_name": "John Doe",
    "email": "john.doe@gmail.com"
  }
]
```

## Output Formats

### JSON Format (Default)

```bash
bin/shift_search -s "John Doe"
```

**Output:**

```json
[
  {
    "id": 1,
    "full_name": "John Doe",
    "email": "john.doe@gmail.com"
  }
]
```

### CSV Format

```bash
bin/shift_search -s "John Doe" --format=csv
```

**Output:**

```csv
id,full_name,email
1,John Doe,john.doe@gmail.com
```

### Output to File

Save results directly to a file:

```bash
bin/shift_search -s "John Doe" --format=csv -o output.csv
```

**Output:**

```
Results saved to output.csv
```

## Duplicate Detection

### Find Duplicate Emails (JSON)

```bash
bin/shift_search --duplicates
```

**Output:**

```json
[
  {
    "id": 2,
    "full_name": "Jane Smith",
    "email": "jane.smith@yahoo.com",
    "duplicate_email": "jane.smith@yahoo.com"
  },
  {
    "id": 15,
    "full_name": "Another Jane Smith",
    "email": "jane.smith@yahoo.com",
    "duplicate_email": "jane.smith@yahoo.com"
  }
]
```

### Find Duplicates with CSV Output

```bash
bin/shift_search --duplicates -f data/clients2.json --format=csv
```

**Output:**

```csv
id,legal_name,email,duplicate_email
2,Jane Smith,jane.smith@yahoo.com,jane.smith@yahoo.com
15,Another Jane Smith,jane.smith@yahoo.com,jane.smith@yahoo.com
```

## Error Handling

The CLI handles various error scenarios gracefully:

### Empty File

```bash
bin/shift_search -s "John" -f data/empty.json
```

**Error:** `Error loading data: File does not appear to be JSON. Expected '{' or '[', but got 'nil'`

### Invalid File Format

```bash
bin/shift_search -s "John" -f data/image.png
```

**Error:** `Error loading data: File does not appear to be JSON. Expected '{' or '[', but got '"\x89"'`

### Missing File

```bash
bin/shift_search -s "John" -f nonexistent.json
```

**Error:** `Error loading data: File not found: nonexistent.json`

### No Command Given

```bash
bin/shift_search
```

**Error:** `No command given. Use --help to see available options.`

## Examples

### Complete Usage Examples

```bash
# Basic search
bin/shift_search -s "John Doe"

# Search by email
bin/shift_search -s "john.doe@gmail.com" -k email

# Search with custom file and field
bin/shift_search -s "John Doe" -f data/clients2.json -k legal_name

# Get CSV output
bin/shift_search -s "John Doe" --format=csv

# Save to file
bin/shift_search -s "John Doe" --format=csv -o output.csv

# Find duplicates
bin/shift_search --duplicates

# Find duplicates with CSV output
bin/shift_search --duplicates -f data/clients2.json --format=csv

# Get help
bin/shift_search -h
bin/shift_search --help
```

## Troubleshooting

### Common Issues

1. **File Not Found**: Ensure the JSON file path is correct and the file exists
2. **Invalid JSON**: Verify that the data file contains valid JSON format
3. **No Results**: Check that the search query matches the data in the specified field
4. **Permission Issues**: Ensure you have read permissions for the data file and write permissions for output files

### Data File Requirements

- Must be valid JSON format
- Should contain an array of objects or a single object
- Each record should have consistent field names
- Email field is required for duplicate detection

### Supported File Formats

- **Input**: JSON files only
- **Output**: JSON or CSV format
- **Default Data Location**: `data/clients.json`

## Development

### Running Tests

If the project includes tests, you can run them with:

```bash
# Run all tests
bundle exec rspec
```
