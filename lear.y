%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char*);
#define YYSTYPE char *

int ii = 0, itop = -1, istack[100];
int ww = 0, wtop = -1, wstack[100];

#define _BEG_IF     {istack[++itop] = ++ii;}
#define _END_IF     {itop--;}
#define _i          (istack[itop])

#define _BEG_WHILE  {wstack[++wtop] = ++ww;}
#define _END_WHILE  {wtop--;}
#define _w          (wstack[wtop])

%}

%token T_Int T_Void T_Return T_Print T_ReadInt T_While
%token T_If T_Else T_Break T_Continue T_Le T_Ge T_Eq T_Ne
%token T_And T_Or T_IntConstant T_StringConstant T_Identifier
%token T_Class T_Extend T_Constructor T_New

%left T_Or
%left T_And
%left T_Eq T_Ne
%left '<' '>' T_Le T_Ge
%left '+' '-'
%left '*' '/' '%'
%left '!'

%%
Program
:   /**/
|   Program function_definition       { /* empty */ }
|   Program class_definition       { /* empty */ }
|   Program statement       { /* empty */ }
;

class_definition
:T_Class className '{' constructor_definition statement_list '}' {printf("END class defination\n");}
;

className
:T_Identifier {printf("class definition %s \n",$1);}

constructor_definition 
:/**/
| constructor '(' param_list ')' '{' statement_list '}'
{
    { printf("end constructor\n\n"); }
}
;

constructor
:T_Constructor { printf("constructor %s \n", $1); }
;

new_expression
: T_New T_Identifier '(' arg_list ')' {printf("\tinvoke %s\n",$2);}
;

statement_list
:   statement                       
|   statement_list statement                      { /* empty */ }
;

if_statement 
: if condition then block endThen endIf
| if condition then block endThen else block endIf
;

if
: T_If  { _BEG_IF; printf("_beginIf_%d\n", _i); }
;

condition
: '(' expression ')'
;

then
: /**/{ printf("jz _elseIf_%d\n", _i); }
;

block 
: '{' statement_list '}'
;

endThen
:/**/ { printf("jmp _endIf_%d\n_elseIf_%d\n", _i, _i); }
;

else
: T_Else
;

endIf
:/**/ { printf("_endIf_%d\n\n", _i); _END_IF; }
;

while_statement
: while condition do block endWhile 
;

while 
:T_While { _BEG_WHILE; printf("_beginWhile_%d\n", _w); }
;

do
: { printf("\tjz _endWhile_%d\n", _w); }
;

endWhile
: { printf("\tjmp _beginWhile_%d\n_endWhile_%d\n\n", _w, _w); _END_WHILE; }
;

break_statement
: T_Break ';'{ printf("\tjmp _endWhile_%d\n", _w); }
;
continue_statement
: T_Continue ';'{ printf("\tjmp _beginWhile_%d\n", _w); }
;

statement 
: expression ';'
| assign_statement
| declaration_statement { printf("\n\n"); }
| array_declartion ';' { printf("\n\n"); }
| return_statement
| if_statement
| while_statement
| break_statement
| continue_statement
| print_statement
;

print_statement
: T_Print expression ';' {printf("\tprint\n");};
; 

assign_statement
: T_Int T_Identifier '=' expression ';'  {printf("\tint %s\n \tpop %s\n", $2,$2);}
| T_Identifier '=' expression ';' {printf("\tpop %s\n",$1);}
| T_Identifier T_Identifier '=' new_expression ';' { printf("\tpop_obj %s\n",$2);}
;

declaration_statement
: T_Int T_Identifier ';' {printf("\tint %s\n", $2);}
;

array_declartion 
: T_Int T_Identifier '[' T_IntConstant ']' {printf("\tarray %s %s", $2,$4);}

expression
:primary
|expression '+' expression {printf("\tadd\n");}
|expression '-' expression {printf("\tsub\n");}
|expression '*' expression {printf("\tmul\n");}
|expression '/' expression {printf("\tdiv\n");}
|expression '>' expression           { printf("\tcmpgt\n"); }
|expression '<' expression           { printf("\tcmplt\n"); }
|expression T_Ge expression          { printf("\tcmpge\n"); }
|expression T_Le expression          { printf("\tcmple\n"); }
|expression T_Eq expression          { printf("\tcmpeq\n"); }
|expression T_Ne expression          { printf("\tcmpne\n"); }
|expression T_Or expression          { printf("\tor\n"); }
|expression T_And expression         { printf("\tand\n"); }
;

primary
: T_IntConstant {  printf("\tpush_num %s\n", $1); }
| T_Identifier {  printf("\tpush %s\n", $1); }
| T_StringConstant {  printf("\tpush_str %s\n", $1); }
| '(' expression ')'
| call_function
| call_array
;

call_array
: T_Identifier '[' expression ']' {printf("\tcallArray %s\n\n", $1);}
;

param_list
: {}
| _param_list {printf("\n\n");}
;

_param_list
:T_Int T_Identifier { printf("\targ %s", $2); }
| _param_list ',' T_Int T_Identifier { printf(",%s", $4); }
;

function_definition 
: T_Int funcName '(' param_list ')' '{' statement_list '}'
{
    { printf("ENDFUNC\n\n"); }
}
;

funcName
:T_Identifier { printf("FUNC @%s\n", $1); }
;

arg_list
: /**/
| expression
| arg_list ',' expression
;

call_function
: T_Identifier '(' arg_list ')' 
{
    { printf("\tcall %s\n", $1); }
}
;

return_statement
: T_Return ';' { printf("\tret\n\n"); }
| T_Return expression ';' { printf("\tret ~\n\n"); }
;

%%

int main(int argc,char ** argv){
 extern FILE *yyin;

    // yyin =stdin;
    // yyin =fopen("test.lear","r");
    yyin = fopen(argv[1],"r");
 return yyparse();
}