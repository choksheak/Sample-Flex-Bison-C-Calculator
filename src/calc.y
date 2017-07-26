%token NUMBER IDENTIFIER PRINT

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "calc.h"

extern void setIdentifierValue(char const *s, int value);
extern int getIdentifierValue(char const *s);

%}

%start program

%%

primary_expression
    : NUMBER
        { $$.i = $1.i; }
    | IDENTIFIER
        { $$.i = getIdentifierValue($1.s); }
    | '(' expression ')'
        { $$.i = $2.i; }
    ;

unary_expression
    : primary_expression
        { $$.i = $1.i; }
    | '-' primary_expression
        { $$.i = -$2.i; }
    | '+' primary_expression
        { $$.i = $2.i; }
    ;

multiplicative_expression
    : unary_expression
        { $$.i = $1.i; }
    | multiplicative_expression '*' unary_expression
        { $$.i = $1.i * $3.i; }
    | multiplicative_expression '/' unary_expression
        { $$.i = $1.i / $3.i; }
    | multiplicative_expression '%' unary_expression
        { $$.i = $1.i % $3.i; }
    ;

additive_expression
    : multiplicative_expression
        { $$.i = $1.i; }
    | additive_expression '+' multiplicative_expression
        { $$.i = $1.i + $3.i; }
    | additive_expression '-' multiplicative_expression
        { $$.i = $1.i - $3.i; }
    ;

assignment_expression
    : IDENTIFIER assignment_operator additive_expression
        { setIdentifierValue($1.s, $3.i); $$.i = $3.i; }
    | IDENTIFIER assignment_operator assignment_expression
        { setIdentifierValue($1.s, $3.i); $$.i = $3.i; }
    ;

assignment_operator
    : '='
    ;

expression
    : additive_expression
        { $$.i = $1.i; }
    | assignment_expression
        { $$.i = $1.i; }
    ;

print_statement
    : PRINT expression
        { $$.i = $2.i; }
    ;

statement
    : assignment_expression
        { $$.i = $1.i; }
    | print_statement
        { printf("print: %i\n", $1.i); }
    ;

statement_list
    : statement
    | statement_list statement
    ;

program
    : /* empty */
    | statement_list
    ;

%%

#include <stdio.h>

struct identifier_node {
    char *name;
    int value;
    struct identifier_node *next;
};

struct identifier_node *identifiers_list = NULL;

void setIdentifierValue(char const *s, int value) {
    fflush(stdout);
    printf("Setting variable %s to %i\n", s, value);

    for (struct identifier_node *node = identifiers_list; node != NULL; node = node->next) {
        if (strcmp(node->name, s) == 0) {
            node->value = value;
            return;
        }
    }

    struct identifier_node *node = malloc(sizeof(struct identifier_node));
    node->name = my_strdup(s);
    node->value = value;
    node->next = identifiers_list;
    identifiers_list = node;
}

int getIdentifierValue(char const *s) {
    for (struct identifier_node *node = identifiers_list; node != NULL; node = node->next) {
        if (strcmp(node->name, s) == 0) {
            return node->value;
        }
    }

    fflush(stdout);
    printf("(variable `%s' is not defined)", s);
    return 0;
}
