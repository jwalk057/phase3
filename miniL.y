/* cs152-miniL phase3 */
%{
#include<stdio.h>
#include<stdlib.h>
#include<string>
#include<vector>
#include<string.h>
#include<sstream>

extern int yylex(void);
void yyerror(const char *msg);
extern int currLine;
extern int currPos;
FILE * yyinput;
int tmp_cnt = 0;


enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
};
struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;


Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

template <typename T>
  std::string NumToString ( T num )
  {
     std::ostringstream ss;
     ss << num;
     return ss.str();
  }

%}

%union{
  /* put your types here */
  double dval;
  char* sval;
}
%error-verbose
%start input
%token END FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ELSE FOR WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN MOD MULT DIV PLUS MINUS EQUAL L_PAREN R_PAREN ENDIF EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token<sval> IDENT
%token<sval> NUMBER 
%type <sval> ident term var statement expression multipicative-expr
%right ASSIGN
%left OR
%left AND
%right NOT
%left EQ NEQ LT GT LTE GTE
%left  ADD SUB
%left MULT DIV MOD
%right UMINUS
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left L_PAREN R_PAREN 


%% 
input:
			| input program 
		;

program:  
      | functions 
		;
functions:
      | function functions
    ;

function: FUNCTION IDENT 
{
  std::string func_name = $2;
  add_function_to_symbol_table(func_name);
  printf("func %s\n", $2);
}
	SEMICOLON
	BEGIN_PARAMS declarations END_PARAMS
	BEGIN_LOCALS declarations END_LOCALS
	BEGIN_BODY statements END_BODY
  {
    printf("endfunc\n");
  }
;

declarations: 
/* epsilon */
| declaration SEMICOLON declarations
;

declaration:
        IDENT COLON INTEGER 
        {
           std::string value = $1;
            if(find(value)){   
              char* id = $1;
              const char* msg1 = "Variable \"";
              const char* msg2 = "\" is already defined";
              char msg[100];
              strcpy(msg, msg1);
              strcat(msg, id);
              strcat(msg, msg2);
              yyerror(msg);}
            else{
              // add the variable to the symbol table.
              Type t = Integer;
              add_variable_to_symbol_table(value, t);
              printf(". %s\n", $1);
            }
        }
        | IDENT another-ident COLON INTEGER 
        {  std::string value = $1;
            if(find(value)){   
              char* id = $1;
              const char* msg1 = "Variable \"";
              const char* msg2 = "\" is already defined";
              char msg[100];
              strcpy(msg, msg1);
              strcat(msg, id);
              strcat(msg, msg2);
              yyerror(msg);}
            else{
              // add the variable to the symbol table.
              Type t = Integer;
              add_variable_to_symbol_table(value, t);
              printf(". %s\n", $1);
            }
        }
        | IDENT COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
        {
            std::string value = $1;
            if(find(value)){   
              char* id = $1;
              const char* msg1 = "Variable \"";
              const char* msg2 = "\" is already defined";
              char msg[100];
              strcpy(msg, msg1);
              strcat(msg, id);
              strcat(msg, msg2);
              yyerror(msg);}
            else{
              // add the variable to the symbol table.
              Type t = Array;
              add_variable_to_symbol_table(value, t);
              printf(". [] %s, %d\n", $1, $5);
            }
        }
        | ident COLON ENUM L_PAREN ident R_PAREN 
        {
        }
        | ident COLON ENUM L_PAREN ident another-ident R_PAREN 
        {
        }
        | IDENT another-ident COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
        {
          std::string value = $1;
            if(find(value)){   
              char* id = $1;
              const char* msg1 = "Variable \"";
              const char* msg2 = "\" is already defined";
              char msg[100];
              strcpy(msg, msg1);
              strcat(msg, id);
              strcat(msg, msg2);
              yyerror(msg);}
            else{
              // add the variable to the symbol table.
              Type t = Array;
              add_variable_to_symbol_table(value, t);
              printf(". [] %s, %d\n", $1, $6);
            }
        }
        | ident another-ident COLON ENUM L_PAREN ident R_PAREN 
        {
        } 
        | ident another-ident COLON ENUM L_PAREN ident another-ident R_PAREN 
        {
        }
      ;

another-ident: {printf("another-ident->epsilon");}
      | COMMA ident another-ident {  
            std::string value = $2;
            if(find(value)){   
              char* id = $2;
              const char* msg1 = "Variable \"";
              const char* msg2 = "\" is already defined";
              char msg[100];
              strcpy(msg, msg1);
              strcat(msg, id);
              strcat(msg, msg2);
              yyerror(msg);}
            else{
              // add the variable to the symbol table.
              Type t = Integer;
              add_variable_to_symbol_table(value, t);
              printf(". %s\n", $2);
            }}
      ;

another-declaration: {}
      | declaration SEMICOLON another-declaration {}
      ;

statements: 
statement SEMICOLON
| statement SEMICOLON statements
;
statement:
         
        var {printf("= %s, ", $1);}ASSIGN expression {printf("\n");}   //Keep getting seg fault when trying $3. $1 also prints out full line for some reason.
        | IF bool-expr THEN statement SEMICOLON ENDIF {printf("statement -> IF bool-expr THEN statement SEMICOLON ENDIF \n");}
        | IF bool-expr THEN statement SEMICOLON another-if-statement ENDIF {printf("statement -> IF bool-expr THEN statement SEMICOLON another-if-statement ENDIF \n");}
        | IF bool-expr THEN statement SEMICOLON ELSE statement SEMICOLON ENDIF {printf("statement -> IF bool-expr THEN statement SEMICOLON ELSE statement SEMICOLON ENDIF \n");}
        | IF bool-expr THEN statement SEMICOLON another-if-statement ELSE statement SEMICOLON ENDIF {printf("statement -> IF bool-expr THEN statement SEMICOLON another-if-statement ELSE statement SEMICOLON ENDIF \n");}
        | IF bool-expr THEN statement SEMICOLON another-if-statement ELSE statement SEMICOLON another-else-statement ENDIF {printf("statement -> IF bool-expr THEN statement SEMICOLON another-if-statement ELSE statement SEMICOLON another-else-statement ENDIF \n");}
        | WHILE bool-expr BEGINLOOP statement SEMICOLON ENDLOOP {printf("statement -> WHILE bool-expr BEGINLOOP statement SEMICOLON ENDLOOP \n");}
        | WHILE bool-expr BEGINLOOP statement SEMICOLON another-statement ENDLOOP {printf("statement -> WHILE bool-expr BEGINLOOP statement SEMICOLON another-statement ENDLOOP \n");}
        | DO BEGINLOOP statement SEMICOLON ENDLOOP WHILE bool-expr {printf("statement -> DO BEGINLOOP statement SEMICOLON ENDLOOP WHILE bool-expr \n");}
        | DO BEGINLOOP statement SEMICOLON another-statement ENDLOOP WHILE bool-expr {printf("statement -> DO BEGINLOOP statement SEMICOLON another-statement ENDLOOP WHILE bool-expr \n");}
        | READ var {
          std::string value = $2;
            if(find(value)){   
              char* id = $2;
              const char* msg1 = "Variable \"";
              const char* msg2 = "\" not defined";
              char msg[100];
              strcpy(msg, msg1);
              strcat(msg, id);
              strcat(msg, msg2);
              yyerror(msg);}
            else{
              printf(".< %s\n", $2);
            }
        }
        | READ var COMMA another-var {
           std::string value = $2;
            if(find(value)){   
              char* id = $2;
              const char* msg1 = "Variable \"";
              const char* msg2 = "\" not defined";
              char msg[100];
              strcpy(msg, msg1);
              strcat(msg, id);
              strcat(msg, msg2);
              yyerror(msg);}
            else{
              printf(".< %s\n", $2);
            }
          }
        | WRITE var {
            std::string value = $2;
            if(find(value)){   
              char* id = $2;
              const char* msg1 = "Variable \"";
              const char* msg2 = "\" not defined";
              char msg[100];
              strcpy(msg, msg1);
              strcat(msg, id);
              strcat(msg, msg2);
              yyerror(msg);}
            else{
              printf(".> %s\n", $2);
            }
            }
        | WRITE var COMMA another-var {std::string value = $2;
            if(find(value)){   
              char* id = $2;
              const char* msg1 = "Variable \"";
              const char* msg2 = "\" not defined";
              char msg[100];
              strcpy(msg, msg1);
              strcat(msg, id);
              strcat(msg, msg2);
              yyerror(msg);}
            else{
              printf(".> %s\n", $2);
            }}
        | CONTINUE {}
        | RETURN expression { 
            printf("ret %s\n", $2);
            }
      ;

another-var:
         var {}
         | var COMMA another-var {}
      ;

another-statement: {}
        | statement SEMICOLON another-statement {}
      ;

another-if-statement: {}
        | statement SEMICOLON another-if-statement {}
      ;

another-else-statement: {}
        | statement SEMICOLON another-else-statement {}
      ;

bool-expr: 
        relation-and-expr {printf("bool-expr -> relation-and-expr \n");}
        | relation-and-expr OR bool-expr {printf("bool-expr -> relation-and-expr OR bool-expr \n");}
      ;

relation-and-expr:
          relation-expr {printf("relation-and-expr -> relation-expr \n");}
          |relation-expr AND relation-and-expr {printf("relation-and-expr -> relation-expr AND relation-and-expr \n");}
      ;

relation-expr:
        expression comp expression {printf("relation-expr -> expression comp expression \n");}
        | TRUE {printf("relation-expr -> TRUE \n");}
        | FALSE {printf("relation-expr -> FALSE \n");}
        | L_PAREN bool-expr R_PAREN {printf("relation-expr -> L_PAREN bool-expr R_PAREN \n");}
        | NOT expression comp expression {printf("relation-expr -> NOT expression comp expression \n");}
        | NOT TRUE {printf("relation-expr -> NOT TRUE \n");}
        | NOT FALSE {printf("relation-expr -> NOT FALSE \n");}
        | NOT L_PAREN bool-expr R_PAREN {printf("relation-expr -> NOT L_PAREN bool-expr R_PAREN \n");}
      ;

comp:
      EQ {printf("comp -> EQ \n");}
      |NEQ {printf("comp -> NEQ \n");}
      | LT {printf("comp -> LT \n");}
      | GT {printf("comp -> GT \n");}
      | LTE {printf("comp -> LTE \n");}
      | GTE {printf("comp -> GTE \n");}
      ;

term:
      SUB var {printf("term -> SUB var \n");}
      | SUB NUMBER  {printf("term -> SUB NUMBER \n");}
      | SUB L_PAREN expression R_PAREN {printf("term -> SUB L_PAREN expression R_PAREN \n");}
      | var {$$ = $1;}
      | NUMBER {$$ = $1;}
      | L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN \n");}
      | ident L_PAREN R_PAREN {printf(" term -> ident L_PAREN R_PAREN \n");}
      | ident L_PAREN expression R_PAREN {printf("term -> ident L_PAREN expression R_PAREN \n");}
      | ident L_PAREN expression another-expression R_PAREN {printf("term -> ident L_PAREN expression another-expression R_PAREN \n");}
    ;

another-expression: {printf("another-expression->epsilon");}
      | COMMA expression another-expression {printf("another-expression -> COMMA expression another-expression \n");}
    ;

expression:
      multipicative-expr {}
      | multipicative-expr ADD expression {}
      | multipicative-expr SUB expression {printf("expression -> multipicative-expr SUB expression \n");}
    ;

multipicative-expr:
          term {}
          | term MULT multipicative-expr {}
          | term DIV multipicative-expr {printf("multipicative-expr -> term DIV multipicative-expr \n");}
          | term MOD multipicative-expr {printf("multipicative-expr -> term MOD multipicative-expr \n");}
;

var:
      ident {}
      | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {}
    ;
  
ident:
      IDENT { $$ = $1; }
   ;

%% 

int main(int argc, char **argv) {
   if (argc > 1) {
      yyinput = fopen(argv[1], "r");
      if (yyinput == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   print_symbol_table();
   return 0;
}
void yyerror(const char *msg) {
 printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
 exit(1);
}
