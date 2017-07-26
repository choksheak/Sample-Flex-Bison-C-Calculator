DIGIT       [0-9]
WORD        [a-zA-Z_]
ALNUM       [0-9a-zA-Z_]
HEX         [0-9A-F]
INTTAIL     (u?(b|s|i|l)?)

%option noyywrap

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "calc.h"

extern void update_location(void);
extern int parse_int(int skipNumChars, int radix);

// Handle deprecated call to fileno in flex generated code.
extern int fileno(FILE *stream);

#define YY_USER_ACTION update_location();

#define YY_NO_INPUT
#define YY_NO_UNPUT

#include "gen.calc.tokens.h"

%}

%%

"/*"[^*]*[*]+([^*/][^*]*[*]+)*[/]
"//"[^\n]*
"#"[^\n]*

"print"                         { return PRINT; }

{WORD}{ALNUM}*                  { yylval.s = my_strdup(yytext); return IDENTIFIER; }

[1-9]({DIGIT}|_)*{INTTAIL}      { yylval.i = parse_int(0, 10); return NUMBER; }
0x({HEX}|_)+{INTTAIL}           { yylval.i = parse_int(2, 16); return NUMBER; }
0b[01_]+{INTTAIL}?              { yylval.i = parse_int(2, 2); return NUMBER; }
0o[0-7_]+{INTTAIL}?             { yylval.i = parse_int(2, 8); return NUMBER; }
0[0-7_]+{INTTAIL}?              { yylval.i = parse_int(1, 8); return NUMBER; }

"("                             { return '('; }
")"                             { return ')'; }
"="                             { return '='; }
"-"                             { return '-'; }
"+"                             { return '+'; }
"*"                             { return '*'; }
"/"                             { return '/'; }
"%"                             { return '%'; }

[ \t\r\n]+

%%

// Note: strdup is not standard C and it actually returns a bad ref when I used the default one in cygwin gcc!
char *my_strdup(const char *s) {
    size_t len = strlen(s) + 1;
    char *t = malloc(len);
    if (t != NULL) {
        memcpy(t, s, len);
    }
    return t;
}

char *lex_filename = "";
int lex_linenum = 1;
int lex_colnum = 0;

void update_location(void) {
    for (char *s = yytext; *s != '\0'; s++) {
        if (*s == '\n') { //TODO: This does not handle \r newlines properly
            lex_colnum = 0;
            lex_linenum++;
        }
        else if (*s == '\t') {
            lex_colnum += 8 - (lex_colnum % 8);
        }
        else {
            lex_colnum++;
        }
    }
#if 0
    ECHO;
#endif
}

void yyerror(char const *errorMessage)
{
    fflush(stdout);

    printf("\nParse error near %s %i:%i - %s (last read token is `%s')\n",
        lex_filename != NULL ? lex_filename : "position",
        lex_linenum,
        lex_colnum,
        errorMessage,
        yytext);
}

// TODO: This algorithm is neither correct nor complete.
// Need to recognize by integer size and signed-ness.
// Best to not require conversion to string to get integral value.
int parse_int(int skipNumChars, int radix) {
    char *s = &(yytext[skipNumChars]);

    for (int i = 0; s[i] != '\0'; i++) {
        char c = s[i];

        if (c == '_' || c == 'u' || c == 'b' || c == 's' || c == 'i' || c == 'l') {
            char *t = my_strdup(s);

            do {
                if (c != '_') {
                    t[i] = '\0';
                    break;
                }

                int k = 0;

                for (int j = 0; s[j] != '\0'; j++) {
                    c = s[j];

                    if (c == 'u' || c == 'b' || c == 's' || c == 'i' || c == 'l') {
                        break;
                    }

                    if (s[j] != '_') {
                        t[k++] = s[j];
                    }
                }

                t[k] = '\0';
            }
            while (0);

            int retval = (int) strtol(t, NULL, radix);
            free(t);
            return retval;
        }
    }

    return (int) strtol(s, NULL, radix);
}

int parseStream(char *name, FILE *stream) {
    lex_filename = name;
    yyset_in(stream);
    return yyparse();
}

const char *getParseStatusName(int status) {
    switch (status) {
    case 0:
        return "Success";
    case 1:
        return "Failure";
    default:
        return "Unknown";
    }
}
