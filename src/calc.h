#ifndef CALC_H
#define CALC_H

union calc_value {
    int i;
    char *s;
};

#define YYSTYPE union calc_value
extern YYSTYPE yylval;

extern char *lex_filename;
extern int lex_linenum;
extern int lex_colnum;

extern int parseStream(char *name, FILE *stream);
extern const char *getParseStatusName(int status);
extern char *my_strdup(const char *s);

extern void yyerror(char const *s);
extern void yyset_in(FILE *_in_str);
extern int yylex(void);
extern int yyparse(void);
extern int yyget_lineno(void);

#endif /* CALC_H */
