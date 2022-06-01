   /* cs152-miniL */
%{   
   #include "miniL-parser.h"
   int currLine = 1, currPos = 1;
   int numNumbers = 0;
   int numOperators = 0;
   int numParens = 0;
   int numEquals = 0;
%}

LETTERS  [A-Za-z]
DIGIT    [0-9]
COMMENT  "##"
   
%%
[ \t]+         {currPos += yyleng;} /* Ignores single spaces */
{COMMENT}.*    {} /* Ignores anything proceeding ## (comments) */

"function"  {return FUNCTION; currPos += yyleng;} 
"beginparams" {return BEGIN_PARAMS; currPos += yyleng;}
"endparams" {return END_PARAMS; currPos += yyleng;}
"beginlocals" {return BEGIN_LOCALS; currPos += yyleng;}
"endlocals" {return END_LOCALS; currPos += yyleng;}
"beginbody" {return BEGIN_BODY; currPos += yyleng;}
"endbody" {return END_BODY; currPos += yyleng;}
"integer" {return INTEGER; currPos += yyleng;}
"array" {return ARRAY; currPos += yyleng;}
"enum" {return ENUM; currPos += yyleng;}
"of" {return OF; currPos += yyleng;}
"if" {return IF; currPos += yyleng;}
"then" {return THEN; currPos += yyleng;}
"endif" {return ENDIF; currPos += yyleng;}
"else" {return ELSE; currPos += yyleng;}
"for" {return FOR; currPos += yyleng;}
"while" {return WHILE; currPos += yyleng;}
"do" {return DO; currPos += yyleng;}
"beginloop" {return BEGINLOOP; currPos += yyleng;}
"endloop" {return ENDLOOP; currPos += yyleng;}
"continue" {return CONTINUE; currPos += yyleng;}
"read" {return READ; currPos += yyleng;}
"write" {return WRITE; currPos += yyleng;}
"and" {return AND; currPos += yyleng;}
"or" {return OR; currPos += yyleng;}
"not" {return NOT; currPos += yyleng;}
"true" {return TRUE; currPos += yyleng;}
"false" {return FALSE; currPos += yyleng;}
"return" {return RETURN; currPos += yyleng;}

   /* ARITHMETIC OPERATORS */
"-" {return SUB; currPos += yyleng;}
"+" {return ADD; currPos += yyleng;}
"*" {return MULT; currPos += yyleng;}
"/" {return DIV; currPos += yyleng;}
"%" {return MOD; currPos += yyleng;}

   /* COMPARISON OPERATORS */
"==" {return EQ; currPos += yyleng;}
"<>" {return NEQ; currPos += yyleng;}
"<" {return LT; currPos += yyleng;}
">" {return GT; currPos += yyleng;}
"<=" {return LTE; currPos += yyleng;}
">=" {return GTE; currPos += yyleng;}

{LETTERS}(_?({LETTERS}|{DIGIT}))*  {currPos += yyleng; yylval.sval = yytext; return IDENT;}
(\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)   {currPos += yyleng; yylval.dval = atof(yytext); return NUMBER;}

   /* SPECIAL SYMBOLS */
";"         {return SEMICOLON; currPos += yyleng;}
":"         {return COLON; currPos += yyleng;}
","         {return COMMA; currPos += yyleng;}
"("         {return L_PAREN; currPos += yyleng;}
")"         {return R_PAREN; currPos += yyleng;}
"["         {return L_SQUARE_BRACKET; currPos += yyleng;}
"]"         {return R_SQUARE_BRACKET; currPos += yyleng;}
":="        {return ASSIGN; currPos += yyleng;}

{DIGIT}(_?({LETTERS}|{DIGIT}))* {printf("ERROR at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); exit(0);} /* Catches identifiers that start with digits */
{LETTERS}_?(_?({LETTERS}|{DIGIT})_?)* {printf("ERROR at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); exit(0);} /* Catches identifiers that end with underscore */
"\n"           {currLine++; currPos = 1;}

.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%
	/* C functions used in lexer */
   /* remove your original main function */
