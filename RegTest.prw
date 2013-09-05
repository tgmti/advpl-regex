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
			cResult2 := oMatcher:Transform(cOutput, 1)
		EndIf
	Else
		Alert("no match!")
	EndIf
//END
//ErrorBlock(bError)

Return cRet