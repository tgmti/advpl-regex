#Include 'Protheus.ch'

User Function RegTest()

Local oDlg
Local cRegExp := ""
Local cTexto := ""
Local cOutput := ""
Local cResult
Local cResult2
Local o1, o2, o3

DEFINE MSDIALOG oDlg FROM 0,0 TO 650,1100 PIXEL

@  18 ,  7 SAY "REGEXP" Of oDlg PIXEL SIZE 54 ,9
@  17 , 40 GET o1 VAR cRegExp MEMO OF oDlg PIXEL SIZE 500 ,50

@  75,  7 SAY "EXPRE." Of oDlg PIXEL SIZE 54 ,9
@  74 , 40 GET o2 VAR cTexto MEMO OF oDlg PIXEL SIZE 500 ,50

@  140 , 40 GET o3 VAR cResult MEMO OF oDlg PIXEL SIZE 500 ,50

@  211 ,  7 SAY "Tranformar" Of oDlg PIXEL SIZE 54 ,9
@  210 , 40 GET o3 VAR cOutput MEMO OF oDlg PIXEL SIZE 500 ,50

@  270 , 40 GET o3 VAR cResult2 MEMO OF oDlg PIXEL SIZE 500 ,50

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| cResult := Testa(cRegExp, cTexto, cOutput, @cResult2);
											,oDlg:Refresh();
											};
											,{|| oDlg:End() }) CENTERED

Static Function Testa(cRegExp, cTexto, cOutput, cResult2)
Local aRet
Local cRet     := ""
Local nI, nJ, nK
//Local bError   := ErrorBlock( { |oError| alert(oError:Description),cRet := "" } )
private oMatcher := nil

cResult2 := ""
//BEGIN SEQUENCE
	oMatcher := U_ReComp(StrTran(StrTran(cRegExp, chr(13)), chr(10)))
	If oMatcher:Find(cTexto)
		aRet := oMatcher:Result
		For nK := 1 To Len(aRet)
			cRet += "["+aRet[nK, 1]+"]."
			For nI := 1 To Len(aRet[nK, 2])
				For nJ := 1 To Len(aRet[nK, 2, nI])
					MsgInfo("Match "+Alltrim(Str(nK, 10,0))+", group "+Str(nI, 3, 0)+","+Str(nJ, 3, 0)+": "+aRet[nK, 2, nI, nJ])
				Next
			Next
		Next
		If !Empty(cOutput)
			cResult2 := oMatcher:Replace(cOutput)
		EndIf
	Else
		Alert("no match!")
	EndIf
//END
//ErrorBlock(bError)

Return cRet

	
/*/{Protheus.doc} RegUnit
	Unidade de teste do RegExp
@author thiago
@since 07/09/2013
@version 1.0		

@description

O intuito desta função é testar o mecanismo de regexp com expressões conhecidas que ofereçam diferentes situações.
Para inserir um teste, basta incluir um novo elemento na Array aTests. O elemento deve ter o seguinte formato:

	{; //Número do teste
			<TEXTO QUE SERÁ TESTADO>
		,	<EXPRESÃO REGEX>
		,	{ ;
				{ <RESULTADO OCORRENCIA 1>, { { <CAPTURA 1 GRUPO 1>, <CAPTURA 2 GRUPO 2>, ..., <CAPTURA N GRUPO 2> }, { <CAPTURA 1 GRUPO 2>,...}, { <CAPTURA 1 GRUPO N>, ...} } } ;
			,	{ <RESULTADO OCORRENCIA 2>, { { <CAPTURA 1 GRUPO 1>, <CAPTURA 2 GRUPO 2>, ..., <CAPTURA N GRUPO 2> }, { <CAPTURA 1 GRUPO 2>,...}, { <CAPTURA 1 GRUPO N>, ...} } } ;
			... ...
			,	{ <RESULTADO OCORRENCIA N>, { { <CAPTURA 1 GRUPO 1>, <CAPTURA 2 GRUPO 2>, ..., <CAPTURA N GRUPO 2> }, { <CAPTURA 1 GRUPO 2>,...}, { <CAPTURA 1 GRUPO N>, ...} } } ;
		} ;
	} ;

O número do teste evidentemente apenas está ali para facilitar a manutenção. É comum montarmos o teste e o mesmo conter
informações erradas, por isso, use o debug para checar e deixar seu teste com informação 100% confiável.
Tome cuidado especial se a expressão utilizada por ventura capturar caracteres especiais, como \n e \r, pois será necessário deixar
explicíto também nos resultados ou nos grupos tais caracteres
/*/
User Function RegUnit()
Local aTests := ;
{ ;
	{; //1
			"amorzinho, te amo mucho mucho para sempre"	;
		,	"([maeto]+).([mucho]+)"	;
		,	{ ;
				{ "amo", {{"a"}, {"o"}} };
			,	{ "amo mucho", {{"amo"}, {"mucho"}} };
			,	{ "mucho", {{"m"}, {"cho"}} };
		} ;
	};
	,{; //2
			"amorzinho, te amo mucho mucho para sempre"	;
		,	"([ma eto]+) (( {0,1}[mucho]+))"	;
		,	{ ;
				{ " te amo mucho", {{" te amo"}, {"mucho"}, {"mucho"}} };
		} ;
	};
	,{; //3
			"amorzinho, te amo mucho mucho para sempre"	;
		,	"([ma eto]+) (( {0,1}[mucho]+)+)"	;
		,	{ ;
				{ " te amo mucho mucho", {{" te amo"}, {"mucho mucho"}, {"mucho", " mucho"}} };
		} ;
	};
	,{; //4
			"amorzinho, te amo mucho mucho para sempre"	;
		,	"([ma eto]+)(( [mucho]+)+)"	;
		,	{ ;
				{ " te amo mucho mucho", {{" te amo"}, {" mucho mucho"}, {" mucho", " mucho"}} };
		} ;
	};
	,{; //5
			"amorzinho, te amo mucho mucho para sempre"	;
		,	"([ma eto]+)(( [mucho]+)+) para sempre"	;
		,	{ ;
				{ " te amo mucho mucho para sempre", {{" te amo"}, {" mucho mucho"}, {" mucho", " mucho"}} };
		} ;
	};
	,{; //6
			"amorzinho, te amo mucho mucho para sempre"	;
		,	"([ma eto]+)(( [mucho]+)+) para (sempre)?"	;
		,	{ ;
				{ " te amo mucho mucho para sempre", {{" te amo"}, {" mucho mucho"}, {" mucho", " mucho"}, {"sempre"}} };
		} ;
	};
	,{; //7
			"thiagothiagothiago"	;
		,	"(thiago)+\1"	;
		,	{ ;
				{ "thiagothiagothiago", {{"thiago", "thiago"}} };
		} ;
	};
	,{; //8
			"thiagothiagothiago"	;
		,	"(thiago)+\1?"	;
		,	{ ;
				{ "thiagothiagothiago", {{"thiago", "thiago", "thiago"}} };
		} ;
	};
	,{; //9
			"thiagothiagothiago"	;
		,	"(thiago){2}\1?"	;
		,	{ ;
				{ "thiagothiagothiago", {{"thiago", "thiago"}} };
		} ;
	};
	,{; //10
			"teste teste@gmail.com"+CRLF+"teste2 teste2@totvs.com.br"	;
		,	"[\w-\._\+%]+@(?:[\w-]+\.)+[\w]{2,6}"	;
		,	{ ;
				{ "teste@gmail.com", {} };
			,	{ "teste2@totvs.com.br", {} };
		} ;
	};
	,{; //11
			"ip1: 192.168.0.1"+CRLF+"ip2: 192.36.0.2"	;
		,	"(?:([2](?:[0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9])[.]){3}(?:([2](?:[0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9]))"	;
		,	{ ;
				{ "192.168.0.1", { { "192","168","0"}, { "1" } } };
			,	{ "192.36.0.2", { { "192","36","0"}, { "2" } } };
		} ;
	};
	,{; //12
			'lin1col1,lin1col2,lin1col3'+CRLF+"lin2col1,lin2col2,lin2col3"+CRLF+'"linha3""col1",lin3col2,lin3col3'	;
		,	'(?:("(?:[^"]|"")+"|[^",\n\r]++)[,\n\r]?)+'	;
		,	{ ;
				{ "lin1col1,lin1col2,lin1col3"+CHR(13), { { "lin1col1" ,"lin1col2","lin1col3" } } };
			,	{ "lin2col1,lin2col2,lin2col3"+CHR(13), { { "lin2col1","lin2col2","lin2col3" } } };
			,	{ '"linha3""col1",lin3col2,lin3col3'+CHR(13), { { '"linha3""col1"','lin3col2','lin3col3' } } };
		} ;
	};
	,{; //13
			'1 + 1 = 2'	;
		,	'\d+\s*[+*-/.]\s*\d+(\s*=\s*\d+)?'	;
		,	{ ;
				{ "1 + 1 = 2", { { " = 2" }} };
		} ;
	};
	,{; //14
			'1 + 1 = 2'	;
		,	'\d+\s*[+*-/.]\s*\d+((\s*=\s*\d+))?'	;
		,	{ ;
				{ "1 + 1 = 2", { { " = 2" }, { " = 2" } } };
		} ;
	};
	,{; //15
			'00'	;
		,	'^[0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7}$'	;
		,	{ ;
				{ "00", {} };
		} ;
	};
	,{; //16
			'10000000'	;
		,	'^[0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7}$'	;
		,	{ ;
				{ "10000000", {} };
		} ;
	};
	,{; //17
			'01000000'	;
		,	'^[0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7}$'	;
		,	{ ;
				{ "01000000", {} };
		} ;
	};
	,{; //18
			'00000000'	;
		,	'^[0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7}$'	;
		,	{ ;
		} ;
	};
	,{; //19
			'00000000'	;
		,	'^([0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7})$'	;
		,	{ ;
		} ;
	};
	,{; //20
			'01000000'	;
		,	'^([0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7})$'	;
		,	{ ;
				{ "01000000", {{ "01000000" }} };
		} ;
	};
	,{; //21
			'00000000'	;
		,	'^(([0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7}))$'	;
		,	{ ;
		} ;
	};
	,{; //22
			'01000000'	;
		,	'^(([0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7}))$'	;
		,	{ ;
				{ "01000000", {{ "01000000" }, { "01000000" }} };
		} ;
	};
	,{; //23
			'00000000'	;
		,	'^((((([0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7})))))$'	;
		,	{ ;
		} ;
	};
	,{; //24
			'01000000'	;
		,	'^(?:(?:(?:(?:(?:[0-9]{2}|[0][1-9][0-9]{6}|[1-9][0-9]{7})))))$'	;
		,	{ ;
				{ "01000000", {} };
		} ;
	};
}
Local cLog := ""
Local nI
Local nJ
Local nK
Local nL
Local oMatcher

For nI := 1 to Len(aTests)
	If nI == 22
		ConOut("If condicional")
	EndIf
	oMatcher := U_ReComp(aTests[nI, 2])
	If oMatcher:Find(aTests[nI, 1])
		If Len(aTests[nI, 3]) == 0
			cLog += "Wasn't expected any result for test "+Alltrim(Str(nI, 10,0))+CRLF
		ElseIf Len(oMatcher:Result) != Len(aTests[nI, 3])
			cLog += "Wrong count of results in test "+Alltrim(Str(nI, 10,0))+CRLF
		Else
			For nJ := 1 To Len(oMatcher:Result)
				If aTests[nI,3,nJ,1] != oMatcher:Result[nJ,1]
					cLog += "Result "+Alltrim(Str(nJ, 10,0))+" is wrong in test "+Alltrim(Str(nI, 10,0))+CRLF
				ElseIf Len(aTests[nI,3,nJ, 2]) != Len(oMatcher:Result[nJ, 2])
					cLog += "Wrong count of groups in result "+Alltrim(Str(nJ, 10,0))+" of test "+Alltrim(Str(nI, 10,0))+CRLF
				Else
					For nK := 1 To Len(oMatcher:Result[nJ, 2])
						If Len(aTests[nI,3,nJ,2,nK]) != Len(oMatcher:Result[nJ, 2, nK])
							cLog += "Wrong count of occurrences in group "+Alltrim(Str(nK, 10,0))+" of result "+Alltrim(Str(nJ, 10,0))+" of test "+Alltrim(Str(nI, 10,0))+CRLF
						Else
							For nL := 1 To Len(oMatcher:Result[nJ, 2, nK])
								If aTests[nI,3,nJ,2,nK, nL] != oMatcher:Result[nJ, 2, nK, nL]
									cLog += "Wrong capture of occurrence "+Alltrim(Str(nL, 10,0))+" in group "+Alltrim(Str(nK, 10,0))+" of result "+Alltrim(Str(nJ, 10,0))+" of test "+Alltrim(Str(nI, 10,0))+CRLF
								EndIf
							Next
						EndIf
					Next
				EndIf
			next 
		EndIf
	ElseIf Len(aTests[nI, 3]) > 0
		cLog += "Can't match test "+Alltrim(Str(nI, 15))+CRLF
	EndIf
Next

If Empty(cLog)
	MsgInfo("Everything ok!")
Else
	Alert(cLog)
EndIf