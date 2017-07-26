# Sample-Flex-Bison-C-Calculator

This is sample learning code for a simple calculator program using Flex and Bison. I think this is a good starting point for anyone who wants to learn how to use Flex and Bison without getting into too many details.

I looked around the web for alternative lexers and parser generators, but in the end still concluded to use Flex and Bison. A notable Flex replacement is re2c, but the documentation seems to be lacking. There are more options for parser generators. The two most notable ones I found were Gold and Lemon. But both do not seem to have the completeness and stability of Bison. Lemon seems to be functionally complete, so that could be a good candidate to consider using in future.

Hopefully this is helpful to someone out there. Have fun!

## Running the Program

You will first need to download or checkout (git clone) the code. After that, you will need gcc, flex and bison in order to compile the program. In order to compile, just do "make". To run, do "make test".

The output executable is calc.exe. Just run "calc.exe test/test.txt" to run the test program.

## Syntax

#### Operators
  - \+ : addition and as a unary operator, like "+4"
  - \- : subtraction and as a unary operator, like "-4"
  - \* : multiplication
  - \/ : division
  - \% : modulus
  - \= : assignment to variable

#### Expression Grouping
  - (...) : expressions can be grouped within parentheses

#### Variables
  - Variable names follow the C syntax i.e. \[a-zA-Z_\]\[0-9a-ZA-Z_\]*
  - You can create any variable by assigning a value to it. e.g. a = 1
  - If you use an undefined variable, the program will print an error, and return zero as its value.

#### Data Types
  - For this sample program, we only support integer arithmetic.
  - It should be quite easy to support floating point arithmetic, but it does not add much value to a sample program like this.

#### Functions
  - The only function available is "print". e.g. print 3 * 5

#### Statements
  - Each statement must be either an assignment or a print statement (must do something with side effects).
  - You can have any number of statements in the program. An empty input is valid.
  - The semicolon character is not needed to separate statements. In fact, the semicolon character will not be recognized and will result in a parse error.
