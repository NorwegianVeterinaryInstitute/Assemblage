// Define the list of valid database names
def validNames = ['resfinder', 'virulencefinder', 'plasmidfinder', 'mobsuite', 'bakta']

workflow VALIDATE_DB {
    take: 
    databases

    main:
    // Read the CSV file (path supplied via params.databases)
    def csvFile = file(databases)
    if( ! csvFile.exists() ) {
        error "CSV file not found: ${csvFile}"
    }

    // Read all lines and remove any blank lines
    def lines = csvFile.text.readLines().findAll { it.trim() }

    // Ensure there is at least one header and one data row
    if( lines.size() < 2 ) {
        error "CSV file must have a header and at least one data row."
    }

    // The first line is assumed to be the header (e.g. "name,db_path")
    def header = lines[0].split(',')*.trim()
    if( header.size() < 2 ) {
        error "CSV header should have at least two columns."
    }

    // Process each data row (skip header) and validate the values
    def dbTuples = lines.drop(1).collect { line ->
        def fields = line.split(',')*.trim()
        if( fields.size() < 2 ) {
            error "Line does not have two columns: $line"
        }
        def name = fields[0]
        def dbPath = fields[1]

        // Validate the database name
        if( ! validNames.contains(name) ) {
            error "Invalid database name: '$name'. Valid options are: ${validNames.join(', ')}"
        }

        // Validate that the database path exists
        def f = file(dbPath)
        if( ! f.exists() ) {
            error "Database path does not exist: '$dbPath'"
        }

        // Return a tuple [name, path] – note that the path can be passed as a string;
        // if a downstream process expects a 'path' type you can cast it with file(dbPath)
        [ name, f ]
    }

    emit:
    valid_db_ch = Channel.fromList(dbTuples)
}
