%{
int yylex();
char *error_text="Undeclared Variable";
void yyerror(char *);
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int type=0;
int declaring=0;//distinguishes a declared and a non declaring variable
int exptrue=0;//global value that tells us whether the expression is true or not
int cond=0;//checks if the statement is inside a if or not
int econd=0;//checks if the statement is inside a else or not
int expvalue=0;
struct node
{
	char name[25];
	int value;
	struct node *next;
}*head=NULL,*search;//my global search and head pointer of the symbol table

void printlist()
	{	
		struct node *search = head;
		while(search!=NULL)
			{
				printf("%s\n",search->name);
				search=search->next;
			}
		printf("\n");
	}

void add(struct node *new_node)
	{
		if(head==NULL)
			{
				new_node->next = head;
				head=new_node;
			} 
		else
			{
				new_node->next=head;
				head = new_node;
			}
	}

int find(char *s)
	{
		if(head==NULL)
			return 0;
		search = head;
		while(search!=NULL){
				if(strcmp(search->name,s)==0)
					return 1;
				search = search->next;
			}
		return 0;
	}
int type,eval;
int stoi(char *s)
{
 int i,num=0;
 for(i=0;s[i]!='\0';i++)
 	{
 		num = num*10 + (int)(s[i]) - 48;
 	}
}
%}
%union
{
    int Int;
    float Float;
    char String[25];
}
%token INT FLOAT CHAR DOUBLE
%token IF ELSE PRINTF PRINTLN 
%token NUM ID
%token SENTENCE

%type<Int> NUM
%type<String> ID
%type<String> SENTENCE

%right '='
%left AND OR
%left LE GE EQ NE LT GT
%left LS RS
%left '+' '-'
%left '*' '/' '%'
%%

start: StmtList
	;

Declaration: Type Assignment {declaring = 0;}
	| Assignment
    | PrintFunc
	| PrintFuncln
	;

/* Assignment block */
Assignment: ID ',' Assignment {
				if((cond==0&&econd==0)||(cond==1&&exptrue!=0)||(econd==1&&exptrue==0))
					{
						if(declaring==0) {
							if(find($<String>1)==0) yyerror((char*)error_text);;
							}
						else
						{
							struct node *new_node = (struct node*)malloc(sizeof(struct node));
							strcpy(new_node->name,$<String>1);
							new_node->value = 0.0;
							add(new_node);
						}
					}
			     }
	| ID '=' Expr ',' Assignment {
						if((cond==0&&econd==0)||(cond==1&&exptrue!=0)||(econd==1&&exptrue==0)){
							if(declaring==0) {
								if(find($<String>1)==0) yyerror((char*)error_text);search->value = $<Int>3;
							}
							else
							{
								struct node *new_node = (struct node*)malloc(sizeof(struct node));
								strcpy(new_node->name,$<String>1);
								new_node->value = $<Int>3;
								add(new_node);
							}
						}
				     }
	| ID '=' Expr {
			if((cond==0&&econd==0)||(cond==1&&exptrue!=0)||(econd==1&&exptrue==0)){ 
					eval = $<Int>3;
					if(declaring==0) {
						if(find($<String>1)==0) yyerror((char*)error_text);search->value = eval;
					}
					else
					{
						struct node *new_node = (struct node*)malloc(sizeof(struct node));
						strcpy(new_node->name,$<String>1);
						new_node->value = eval;
						add(new_node);
					} 
				}
		      }
	| ID {
	if((cond==0&&econd==0)||(cond==1&&exptrue!=0)||(econd==1&&exptrue==0)){
				if(declaring==0) {
					if(find($<String>1)==0) yyerror((char*)error_text);
				}
				else
				{

					struct node *new_node = (struct node*)malloc(sizeof(struct node));
					strcpy(new_node->name,$<String>1);
					new_node->value = 0.0;
					add(new_node);
				} 
			}
	     }
	;

CompoundStmt:	'{' StmtList '}'
	;
StmtList:	CompoundStmt | StmtList Stmt
	|
	;
Stmt: Declaration ';' {declaring=0;}
	| IfStmt
	;

/* Type Identifier block */
Type:	INT {declaring = 1;}
	| FLOAT {declaring = 1;}
	| CHAR {declaring = 1;}
	| DOUBLE {declaring = 1;}
	;


/* IfStmt Block */
IfStmt : IF '(' Bexpr ')' Stmt ElseStmt { exptrue=0;cond=0;}
	;
ElseStmt : ELSE Stmt {exptrue=0;cond=0;econd=0;}
	|
	;

/* Print Function in the same line */
PrintFunc : PRINTF '(' Expr ')' {if((cond==0&&econd==0)||(cond==1&&exptrue!=0)||(econd==1&&exptrue==0)) printf("%d",$<Int>3);}
	| PRINTF '('  SENTENCE ')' { if((cond==0&&econd==0)||(cond==1&&exptrue!=0)||(econd==1&&exptrue==0)) printf("%s",$<String>3);}
	;
/* Print Function in the same line */
PrintFuncln : PRINTLN '(' Expr ')' {if((cond==0&&econd==0)||(cond==1&&exptrue!=0)||(econd==1&&exptrue==0)) printf("%d\n",$<Int>3);}
	|PRINTLN '('  SENTENCE ')' { if((cond==0&&econd==0)||(cond==1&&exptrue!=0)||(econd==1&&exptrue==0)) printf("%s\n",$<String>3);}
	;
	
/*Boolean Expression Block*/
Bexpr: Expr {if(expvalue) exptrue=1; else exptrue=0;}
	;

/*Expression Block*/
Expr:
    |'('Expr')'{$<Int>$=expvalue=$<Int>2;}
    | Expr LE Expr
        {
          $<Int>$=expvalue=($<Int>1<=$<Int>3); 
        } 
	| Expr GE Expr
        {
          $<Int>$=expvalue=($<Int>1>=$<Int>3); 
        }
	| Expr NE Expr
        {
          $<Int>$=expvalue=($<Int>1!=$<Int>3); 
        }
	| Expr EQ Expr
		{
          $<Int>$=expvalue=($<Int>1==$<Int>3)?1:0;
		}
	| Expr GT Expr
        {
          $<Int>$=expvalue=($<Int>1>$<Int>3);
        }
	| Expr LT Expr
        {
           $<Int>$=expvalue=($<Int>1<=$<Int>3); 
        }
    | Expr '+' Expr
          {
            $<Int>$=$<Int>1+$<Int>3;
           }
        | Expr '-' Expr
          {
            $<Int>$=$<Int>1-$<Int>3;
           }
	   | Expr '*' Expr
	  {
	    $<Int>$=$<Int>1*$<Int>3;
	   }
	 | Expr '/' Expr
	  {
	    $<Int>$=$<Int>1/$<Int>3;
	   }
	   | Expr '%' Expr
	  {
	    $<Int>$=$<Int>1%$<Int>3;
	   }
	   | Expr AND Expr
	  {
	    $<Int>$=($<Int>1&$<Int>3);
	   }
	   | Expr OR Expr
	  {
	    $<Int>$=($<Int>1|$<Int>3);
	   }
    | ID 
		{ 
		   if(find($<String>1)==0) yyerror((char*)error_text);
		   $<Int>$=expvalue=search->value;
        }  
              
    | NUM {$<Int>$=expvalue=$<Int>1;}
	;

%%
#include"lex.yy.c"
#include<ctype.h>
int count=0;
int main()
{
	
    if(!yyparse())
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	
    return 0;
}
         
void yyerror(char *s) {
	printf("\n%d : %s %s\n", yylineno, s, yytext );
}        
