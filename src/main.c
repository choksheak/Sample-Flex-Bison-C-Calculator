#include <stdio.h>
#include <stdlib.h>

#include "calc.h"

int parseFile(char *filename) {
    FILE *f = fopen(filename, "r");
    if (f == NULL) {
        printf("Error: Cannot read file `%s'.\n", filename);
        return EXIT_FAILURE;
    }

    int parseStatus = parseStream(filename, f);

    printf("\nParse status = %s\n", getParseStatusName(parseStatus));

    fclose(f);

    return parseStatus;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <input-file> ...\n", argv[0]);
        return EXIT_FAILURE;
    }

    for (int i = 1; i < argc; i++) {
        parseFile(argv[i]);
    }

    return EXIT_SUCCESS;
}

