
%{

#include <stdio.h>
#include <string.h>

int lineNum = 1;
int printToken = 1;
int printSource = 1;
int isBegin = 1;
char line[1024]={};
char str[1024]={};


#define PKEY 		Ptoken("key")
#define PID 		Ptoken("id")
#define POP 		Ptoken("op")
#define PPUNC 		Ptoken("punc")
#define PINT 		Ptoken("integer")
#define PDUB 		Ptoken("double")
#define PCHAR 		Ptoken("char")
#define PSCI 		Ptoken("sci")
#define PSOURCE 	Psource()
#define PERROR(X)	Perror(X)
#define CAT		strcat(line, yytext)
#define CLR		line[0] = '\0'
#define CATSTR(x) 	strcat(str, yytext); Pstrdelete(x)

void Ptoken(char *);
void Psource();
void Pstrdelete(int );
void Pstring(int);
void Perror(char *);
%}


%x COMMENT
%x STRING
%x PRAGMA

D	[0-9]
A	[a-zA-Z]
AN	[a-zA-Z0-9]
V	[_]*{A}({AN}|[_])*
W	[ \t]
WT	[ \t\v\n]
OCM	({W}|("/*".*"*/"))
E	[eE][+-]?{D}+
FS	[fF]
DS	[lL]
US	[uU]
IS	(l|ll|L|LL)
ECS	[\'\"\\\(\%\?\{0abfnrtv]
NECS	({AN}|[ !#$%&\()*+,-./:;<=>?@\[\]^_`\{|}~])
C	"\'"({NECS}|\\{ECS})"\'"

%%


	/*Comment Area*/
"/*"			{ BEGIN(COMMENT); CAT; }
<COMMENT>.		{ CAT; }
<COMMENT>"*/"		{ BEGIN(INITIAL); CAT; }
<COMMENT>"\n"		{ CAT; PSOURCE; CLR; }
<INITIAL>"//".*\n	{ CAT; PSOURCE; CLR; }


	/*String Area*/
L?"\""			{ BEGIN(STRING); CAT; }
<STRING>(\\{ECS}|{NECS})*\"		{ BEGIN(INITIAL); CAT; CATSTR(0); Pstring(1); }
<STRING>(\\{ECS}|{NECS})*\\\n		{ CAT; CATSTR(2); PSOURCE; CLR; }
<STRING>\n	{ PERROR("Unknown token"); }

	/*Pragma Area*/
"#"{OCM}*"pragma"				{  if(!isBegin)PERROR("pragma need to be the beginning of the line."); 
						BEGIN(PRAGMA); CAT; }
<PRAGMA>{OCM}+"source"{OCM}+"on" 	{ CAT; printSource = 1; }
<PRAGMA>{OCM}+"source"{OCM}+"off"	{ CAT; printSource = 0; }
<PRAGMA>{OCM}+"token"{OCM}+"on"		{ CAT; printToken = 1; }
<PRAGMA>{OCM}+"token"{OCM}+"off"	{ CAT; printToken = 0; }
<PRAGMA>{OCM}				{ CAT; }
<PRAGMA>"//".*"\n"			{ BEGIN(INITIAL); CAT; PSOURCE; CLR; }
<PRAGMA>"/*".*"\n"			{ BEGIN(COMMENT); CAT; PSOURCE; CLR; }
<PRAGMA>"\n"				{ BEGIN(INITIAL); CAT; PSOURCE; CLR; }


"void"		{ PKEY; CAT; }
"int"		{ PKEY; CAT; }
"double"	{ PKEY; CAT; }
"bool"		{ PKEY; CAT; }
"char"		{ PKEY; CAT; }
"null"		{ PKEY; CAT; }
"for"		{ PKEY; CAT; }
"while"		{ PKEY; CAT; }
"do"		{ PKEY; CAT; }
"if"		{ PKEY; CAT; }
"else"		{ PKEY; CAT; }
"switch"	{ PKEY; CAT; }
"return"	{ PKEY; CAT; }
"break"		{ PKEY; CAT; }
"continue"	{ PKEY; CAT; }
"const"		{ PKEY; CAT; }
"true"		{ PKEY; CAT; }
"false"		{ PKEY; CAT; }
"struct"	{ PKEY; CAT; }
"case"		{ PKEY; CAT; }
"default"	{ PKEY; CAT; }
"printf"	{ PKEY; CAT; }
"scanf"		{ PKEY; CAT; }
"fopen"		{ PKEY; CAT; }
"freopen"	{ PKEY; CAT; }
"fflush"	{ PKEY; CAT; }
"fclose"	{ PKEY; CAT; }
"fread"		{ PKEY; CAT; }
"fwrite"	{ PKEY; CAT; }
"fgetc"		{ PKEY; CAT; }
"getc"		{ PKEY; CAT; }
"fputc"		{ PKEY; CAT; }
"putc"		{ PKEY; CAT; }
"fgets"		{ PKEY; CAT; }
"fputs"		{ PKEY; CAT; }
"fscanf"	{ PKEY; CAT; }
"sscanf"	{ PKEY; CAT; }
"fprintf"	{ PKEY; CAT; }
"sprintf"	{ PKEY; CAT; }
"perror"	{ PKEY; CAT; }
"ftell"		{ PKEY; CAT; }
"fseek"		{ PKEY; CAT; }
"fgetpos"	{ PKEY; CAT; }
"fsetpos"	{ PKEY; CAT; }
"rewind"	{ PKEY; CAT; }
"feof"		{ PKEY; CAT; }
"ferror"	{ PKEY; CAT; }
"FILE"		{ PKEY; CAT; }
"unsigned"	{ PKEY; CAT; }
"long"		{ PKEY; CAT; }

"NULL"		{ PID; CAT; }
"EOF"		{ PID; CAT; }
"stdin"		{ PID; CAT; }
"stdout"	{ PID; CAT; }
"stderr"	{ PID; CAT; }
{V}		{ PID; CAT; }

{C}		{ PCHAR; CAT; }

[\(\)\{\}\[\]:;,.]	{ PPUNC; CAT; }


0{US}?{IS}?		{ PINT; CAT; }
[1-9]{D}*{US}?{IS}?	{ PINT; CAT; }
0x[[:xdigit:]]+		{ PINT; CAT; }
{D}+{E}{FS}?		{ PSCI; CAT; }
{D}*"."{D}+({FS}|{DS})?	{ PDUB; CAT; }
{D}+"."{D}*({FS}|{DS})?	{ PDUB; CAT; }
{D}*"."{D}+{E}({FS}|{DS})? { PSCI; CAT; }
{D}+"."{D}*{E}({FS}|{DS})? { PSCI; CAT; }


"+"	{ POP; CAT; }
"-"	{ POP; CAT; }
"*"	{ POP; CAT; }
"/"	{ POP; CAT; }
"%"	{ POP; CAT; }
"++"	{ POP; CAT; }
"--"	{ POP; CAT; }
"<"	{ POP; CAT; }
"<="	{ POP; CAT; }
">"	{ POP; CAT; }
">="	{ POP; CAT; }
"=="	{ POP; CAT; }
"!="	{ POP; CAT; }
"="	{ POP; CAT; }
"&&"	{ POP; CAT; }
"||"	{ POP; CAT; }
"!"	{ POP; CAT; }
"&"	{ POP; CAT; }

[ \t]	{ CAT; }
"\n"	{ CAT; PSOURCE; CLR; }
<*>.	{ CAT; isBegin = 0; PERROR("Unknown token"); }

%%


void Perror(char *s){
	if(s == NULL)s = "";
	fprintf(stderr, "Error at line %d: %s\n", lineNum, s);
	exit(1);
}

void Pstrdelete(int n){
	int i, l = strlen(str);
	for(i=0;i<n;++i){
		str[l-1 -i] = '\0';
		
	}
}

void Pstring(int i){
	if(printToken == 1){
		Pstrdelete(i);
		printf("#%s:%s\n", "string", str);
	}
	isBegin = 0;
	str[0] = '\0';
}

void Ptoken(char *s){
	if(printToken == 1){
		printf("#%s:", s);
		ECHO;
		printf("\n");
	}
	isBegin = 0;
}

void Psource(){
	if(printSource == 1){
		printf("%d:%s", lineNum, line);
	}
	++lineNum;
	isBegin = 1;
}

int yywrap(){
	return 1;
}

int main(int argc, char *argv[]){
	yylex();
	return 0;
}
