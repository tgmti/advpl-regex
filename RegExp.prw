#include 'totvs.ch'
#include 'RegExp.ch'


Static bLetters := ClassPattern("A", "Z") //Classe de letras
Static bDigits := ClassPattern("0", "9") //Classe de dígitos (\n)
Static bWord := { |cStr| Eval(bDigits, cStr) .Or. Eval(bLetters, Upper(cStr)) } //Classe \w
Static bNWord := { |cStr| !Eval(bWord, cStr) } //Classe \W
Static bNDigits := { |cStr| !Eval(bDigits, cStr) } //Classe \N
Static bAny := { |cStr| ! (cStr $ CRLF) } //Classe .
Static Startable := { REGEXP_RESULT_UNKNOWN, REGEXP_RESULT_SUCCESS, REGEXP_RESULT_PARTIAL }
Static Acceptable := { REGEXP_RESULT_SUCCESS, REGEXP_RESULT_PARTIAL }
Static Deniable := { REGEXP_RESULT_NOMATCH, REGEXP_RESULT_FAIL }
Static Definable := { REGEXP_RESULT_FAIL, REGEXP_RESULT_SUCCESS }

/*/{Protheus.doc} RegExpPattern
Classe pai de padrões de RegExp

@author Thiago Oliveira Santos
@since 23/05/2013
@version 1.0
/*/
CLASS RegExpPattern

DATA Type
DATA Satisfatory
DATA UniSatisfatory
DATA lCase
DATA nTimes //Contador para controle da validação da Pattern
DATA Min
DATA Max
DATA NextPattern
DATA QuantType
DATA oParent

METHOD New(nMin, nMax, nQuantType) CONSTRUCTOR
METHOD ResetSatisfatory()
METHOD Mirror()
METHOD RedoMirror(aMirror)
METHOD StartMatch(cStr, nPos, lCase)
METHOD Matching(cStr, nPos)
METHOD Satisfy()
METHOD IsLazy()
METHOD IsPosible(cStr, nPos, lCase)
METHOD InInit(cStr, nPos)
METHOD InEnd(cStr, nPos)
ENDCLASS

/*/{Protheus.doc} New
	
	Construtor
	
@author thiago.santos
@since 26/08/2013
@version 1.0

@param nMin, numeric, Número mínimo exigido (padrão 1)
@param nMax, numeric, Número máximo exigido (padrão 1)
@param nQuantType, numeric, Tipo de Quantificador (NORMAL, LAZY ou VORACIOUS)

/*/
METHOD New(nMin, nMax, nQuantType) CLASS RegExpPattern
Default nMin := 1
Default nMax := 1
Default nQuantType := REGEXP_QUANTIFIER_NORMAL

self:Min := nMin
self:Max := nMax
self:QuantType := nQuantType
Return



/*/{Protheus.doc} ResetSatisfatory
	Reseta o estado das flags de satisfação de pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

/*/
METHOD ResetSatisfatory() CLASS RegExpPattern
self:UniSatisfatory := (self:Min == 0)
self:Satisfatory := (self:Min == 0)
Return



/*/{Protheus.doc} Mirror
	Retorna uma array com um espelho do Estado atual do Pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@return array, Espelho de estado do pattern

/*/
METHOD Mirror() CLASS RegExpPattern
Local aRet       := {}

aAdd(aRet, self:nTimes)
aAdd(aRet, self:Satisfatory)
aAdd(aRet, self:lCase)
aAdd(aRet, self:UniSatisfatory)

Return aRet



/*/{Protheus.doc} RedoMirror
	Retorna o pattern para o Estado espelhado informado por parâmetro
@author thiago.santos
@since 26/08/2013
@version 1.0

@param aMirror, array, Espelho de estado do pattern

/*/
METHOD RedoMirror(aMirror) CLASS RegExpPattern

self:nTimes := aMirror[1]
self:Satisfatory := aMirror[2]
self:lCase := aMirror[3]
self:UniSatisfatory := aMirror[4]

Return



/*/{Protheus.doc} StartMatch
	Inicia a validação de pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cStr, character, String a validar
@param nPos, numeric, Posição inicial a validar
@param lCase, boolean, Determina se é case sensitive (true) ou não (false)

@return integer, o resultado da apuração inicial

/*/
METHOD StartMatch(cStr, nPos, lCase) CLASS RegExpPattern
Default lCase := .T.
self:nTimes := 0
self:ResetSatisfatory()
self:lCase := lCase

Return self:Matching(cStr, @nPos)



/*/{Protheus.doc} Satisfy
	Método chamado para dizer que a ocorrência atual da regexp é satisfatória,
	e avançar o contador de repetição
@author thiago.santos
@since 26/08/2013
@version 1.0

@return integer, o reusltado da regexp

/*/
METHOD Satisfy() CLASS RegExpPattern
Local nRet := REGEXP_RESULT_PARTIAL

self:nTimes++
If self:Min > self:nTimes
	self:Satisfatory := .F.
ElseIf Empty(self:Max) .Or. self:nTimes < self:Max
	self:Satisfatory := .T.
ElseIf self:nTimes == self:Max
	nRet := REGEXP_RESULT_SUCCESS
	self:UniSatisfatory := .T.
Else
	nRet := REGEXP_RESULT_FAIL
EndIf

Return nRet



/*/{Protheus.doc} IsLazy
	Determina se o quantificador da regexp é do tipo LAZY
@author thiago.santos
@since 26/08/2013
@version 1.0

@return boolean, verdadeiro se o tipo for lazy, falso caso contrário.

/*/
METHOD IsLazy() CLASS RegExpPattern

Return (self:Satisfatory .And. self:QuantType == REGEXP_QUANTIFIER_LAZY)



/*/{Protheus.doc} IsPosible
	Determina se a Pattern é possível no contexto atual
@author thiago
@since 06/09/2013
@version 1.0

@param cStr, character, Texto a validar
@param nPos, numérico, Posição atual
@param lCase, boolean, Se é case sensitive

@return boolean, Verdadeiro se possível, falso senão.

/*/
METHOD IsPosible(cStr, nPos, lCase) CLASS RegExpPattern
Local aMirror := self:Mirror()
Local nRet := self:StartMatch(cStr, nPos, lCase)

self:RedoMirror(aMirror)

Return aIn(nRet, Acceptable)

METHOD InInit(cStr, nPos) CLASS RegExpPattern


Return self:oParent:InInit(cStr, nPos)

METHOD InEnd(cStr, nPos) CLASS RegExpPattern

Return self:oParent:InEnd(cStr, nPos)

/*/{Protheus.doc} LiteralRegExpPattern
Classe de RegExp que representa String literais

@author thiago.santos
@since 23/05/2013
@version 1.0
/*/
CLASS LiteralRegExpPattern FROM RegExpPattern
DATA aMatch
DATA CaseComp
DATA Comp

METHOD New(aMatch, nMin, nMax, nQuantType) CONSTRUCTOR
METHOD Matching(cStr, nPos)
METHOD GetLen(nPos)
ENDCLASS

/*/{Protheus.doc} New
	
	Construtor
	
@author thiago.santos
@since 26/08/2013
@version 1.0

@param aMatch, array, array com strings aceitas para match
@param nMin, numeric, Número mínimo exigido (padrão 1)
@param nMax, numeric, Número máximo exigido (padrão 1)
@param nQuantType, numeric, Tipo de Quantificador (NORMAL, LAZY ou VORACIOUS)

/*/
METHOD New(aMatch, nMin, nMax, nQuantType) CLASS LiteralRegExpPattern
_Super:New(nMin, nMax, nQuantType)

self:Type   := REGEXP_LITERAL
self:aMatch := IIF(ValType(aMatch) == "C", { aMatch }, aMatch)
self:Comp := {|cMatch| Lower(cMatch) == Lower(SubStr(cStr, nPos, Len(cMatch))) }
self:CaseComp := {|cMatch| cMatch == SubStr(cStr, nPos, Len(cMatch)) }

Return

/*/{Protheus.doc} Matching
	Segue com a validação de matching para o pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cStr, character, String a analisar
@param nPos, integer, Posição atual

@return integer, o resultado da avaliação (um REGEXP_RESULT)

/*/
METHOD Matching(cStr, nPos) CLASS LiteralRegExpPattern
Local nRet       := REGEXP_RESULT_NOMATCH
Local lContinue  := .T.
Local nLen
Local lRet

While lContinue
	If self:lCase
		lRet := ((nLen := aScan(self:aMatch, self:CaseComp)) > 0)
	Else
		lRet := ((nLen := aScan(self:aMatch, self:Comp)) > 0)
	EndIf

	If lRet
		nLen := self:GetLen(nLen)
		nRet := self:Satisfy()
		nPos += nLen - 1
		lContinue := (nRet == REGEXP_RESULT_PARTIAL .And. !self:Satisfatory)
	Else
		lContinue := .F.
	EndIf

	nPos++
End

nPos--

Return nRet

/*/{Protheus.doc} GetLen
	Retorna o tamanho da pattern na posição solicitada
@author thiago.santos
@since 26/08/2013
@version 1.0

@param nPos, integer, Posição a avaliar

@return integer, o tamanho do pattern na posição solicitada

/*/
METHOD GetLen(nPos) CLASS LiteralRegExpPattern
Return Len(self:aMatch[nPos])

/*/{Protheus.doc} ParameterRegExpPattern
	Classe de Regexp que representa referência recursiva de parâmetro
@author thiago.santos
@since 26/08/2013
@version 1.0

/*/
CLASS ParameterRegExpPattern FROM LiteralRegExpPattern
DATA aCapture

METHOD New(aCapture, nMin, nMax, nQuantType) CONSTRUCTOR
METHOD StartMatch(cStr, nPos, lCase)
METHOD GetLen(nPos)

ENDCLASS

/*/{Protheus.doc} New
	
	Construtor
	
@author thiago.santos
@since 26/08/2013
@version 1.0

@param aCapture, array, array com grupos a capturar
@param nMin, numeric, Número mínimo exigido (padrão 1)
@param nMax, numeric, Número máximo exigido (padrão 1)
@param nQuantType, numeric, Tipo de Quantificador (NORMAL, LAZY ou VORACIOUS)

/*/
METHOD New(aCapture, nMin, nMax, nQuantType) CLASS ParameterRegExpPattern
_Super:new("", nMin, nMax, nQuantType)
self:aCapture := aCapture
self:Comp := {|aCap| Lower(Result(cStr, aCap[1], aCap[2])) == Lower(SubStr(cStr, nPos, aCap[2]-aCap[1])) }
self:CaseComp := {|aCap| Result(cStr, aCap[1], aCap[2]) == Lower(SubStr(cStr, nPos, aCap[2]-aCap[1])) }

Return

/*/{Protheus.doc} StartMatch
	Inicia a validação de pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cStr, character, String a validar
@param nPos, numeric, Posição inicial a validar
@param lCase, boolean, Determina se é case sensitive (true) ou não (false)

@return integer, o resultado da apuração inicial

/*/
METHOD StartMatch(cStr, nPos, lCase) CLASS ParameterRegExpPattern
Local aCapture := aGroups[self:aCapture[1]]
Local nRet

self:aMatch := aCapture
nRet := _Super:StartMatch(cStr, @nPos, lCase)

Return nRet

METHOD GetLen(nPos) CLASS ParameterRegExpPattern
Return aGroups[self:aCapture[1],nPos,2] - aGroups[self:aCapture[1],nPos,1]



/*/{Protheus.doc} BlCodeRegExpPattern
	Classe de regexp que valida um bloco de código para um caracter
@author thiago.santos
@since 26/08/2013
@version 1.0

/*/
CLASS BlCodeRegExpPattern FROM RegExpPattern
DATA bCode


METHOD New(bCode, nMin, nMax, nQuantType) CONSTRUCTOR
METHOD Matching(cStr, nPos)

ENDCLASS

METHOD New(bCode, nMin, nMax, nQuantType) CLASS BlCodeRegExpPattern
_Super:New(nMin, nMax, nQuantType)

self:Type   := REGEXP_CODEBLOCK
self:bCode := bCode

Return

/*/{Protheus.doc} Matching
	Segue com a validação de matching para o pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cStr, character, String a analisar
@param nPos, integer, Posição atual

@return integer, o resultado da avaliação (um REGEXP_RESULT)

/*/
METHOD Matching(cStr, nPos) CLASS BlCodeRegExpPattern
Local nRet      := REGEXP_RESULT_PARTIAL
Local lContinue := .T.

While lContinue
	lContinue := .F.
	self:UniSatisfatory := .F.

	If Eval(self:bCode, SubStr(cStr, nPos, 1))
		self:nTimes++
		self:UniSatisfatory := .T.
		If self:Min > self:nTimes
			self:Satisfatory := .F.
			If Len(cStr) > nPos
				lContinue := .T.
				nPos++
			Else
				nRet := REGEXP_RESULT_FAIL
			EndIf
		ElseIf (Empty(self:Max) .Or. self:nTimes < self:Max)
			self:Satisfatory := .T.
		ElseIf self:nTimes == self:Max
			nRet := REGEXP_RESULT_SUCCESS
		Else
			nRet :=  REGEXP_RESULT_FAIL
			self:Satisfatory := .F.
		EndIf
	Else
		nRet :=  REGEXP_RESULT_NOMATCH
	EndIf
End

Return nRet



/*/{Protheus.doc} OrRegExpPattern
	Classe de regexp para validação de "ou" (padrão |)
@author thiago.santos
@since 26/08/2013
@version 1.0

/*/
CLASS OrRegExpPattern FROM RegExpPattern

DATA Patterns
DATA vPatterns
DATA oSelected

METHOD New(aPatterns) CONSTRUCTOR
METHOD Mirror()
METHOD RedoMirror(aMirror)
METHOD StartMatch(cStr, nPos, lCase)
METHOD Matching(cStr, nPos0)
METHOD IsPosible(cStr, nPos, lCase)

ENDCLASS

METHOD New(aPatterns) CLASS OrRegExpPattern
Local nI
self:Type := REGEXP_OR
self:Patterns := aPatterns

For nI := 1 To Len(aPatterns)
	aPatterns[nI]:oParent := self
Next

Return

/*/{Protheus.doc} StartMatch
	Inicia a validação de pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cStr, character, String a validar
@param nPos, numeric, Posição inicial a validar
@param lCase, boolean, Determina se é case sensitive (true) ou não (false)

@return integer, o resultado da apuração inicial

/*/
METHOD StartMatch(cStr, nPos0, lCase, nForceOr) CLASS OrRegExpPattern
Local nI
Local nRes
Local nRet       := 0
Local nSuccess
Local nPos
self:vPatterns := {}

self:oSelected := nil

For nI := 1 To Len(self:Patterns)
	If ValType(nForceOr) == "U" .Or. nForceOr == nI
		nPos := nPos0
		nRes := self:Patterns[nI]:StartMatch(cStr, @nPos, lCase)
		If nRes == REGEXP_RESULT_SUCCESS .Or. nRes == REGEXP_RESULT_PARTIAL ;
			.Or. (nRes == REGEXP_RESULT_NOMATCH .And. self:Patterns[nI]:Satisfatory)
			//
			aAdd(self:vPatterns, {nRes, nPos, self:Patterns[nI] })
			If nRet != REGEXP_RESULT_SUCCESS
				If nRes == REGEXP_RESULT_SUCCESS
					self:oSelected := self:Patterns[nI]
					nRet := nRes
				ElseIf (ValType(self:oSelected) != "O" .Or. !self:oSelected:Satisfatory) .And. self:Patterns[nI]:Satisfatory
					self:oSelected := self:Patterns[nI]
					nRet := nRes
				ElseIf (ValType(self:oSelected) != "O" .Or. !self:oSelected:Satisfatory) ;
					.Or. nRes == REGEXP_RESULT_PARTIAL
					//
					self:oSelected := self:Patterns[nI]
					nRet := nRes
				ElseIf nRes == REGEXP_RESULT_NOMATCH .And. (Empty(nRet)  .Or. nRet == REGEXP_RESULT_FAIL)
					self:oSelected := self:Patterns[nI]
					nRet := nRes
				EndIf
			EndIf
		EndIf
	EndIf
Next

If ValType(self:oSelected) == "O"
	nPos := aScan(self:vPatterns, {|aLine| aLine[3] == self:oSelected })
	nPos0 := self:vPatterns[nPos, 2]
	nRet := self:vPatterns[nPos, 1]
EndIf
Return If(Empty(nRet), REGEXP_RESULT_FAIL, nRet)

/*/{Protheus.doc} Matching
	Segue com a validação de matching para o pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cStr, character, String a analisar
@param nPos0, integer, Posição atual

@return integer, o resultado da avaliação (um REGEXP_RESULT)

/*/
METHOD Matching(cStr, nPos0) CLASS OrRegExpPattern
Local nI
Local nLen       := Len(self:vPatterns)
Local nRet
Local nPos

For nI := 1 To nLen
	If self:vPatterns[nI, 1] == REGEXP_RESULT_PARTIAL
		nPos := self:vPatterns[nI, 2] + 1
		If ((nRet := self:vPatterns[nI, 3]:Matching(cStr, @nPos)) == REGEXP_RESULT_NOMATCH ;
			.Or. nRet == REGEXP_RESULT_FAIL) .And. !self:vPatterns[nI, 3]:Satisfatory
			//
			aDel(self:vPatterns, nI)
			nLen--
			nI-- //Descontar pelo movimento da Matriz no aDel
		Else
			self:vPatterns[nI, 1] := nRet
			If nRet == REGEXP_RESULT_SUCCESS .Or. nRet == REGEXP_RESULT_PARTIAL
				self:vPatterns[nI, 2] := nPos
			EndIf
		EndIf
		If nI >= nLen
			Exit //Se nI for maior do que o tamaho da matriz descontando os deletados, sair do laço
		EndIf
	EndIf
Next

aSize(self:vPatterns, nLen) //Redimencionar a matriz

If (nPos := aScan(self:vPatterns, { |aLine| aLine[3] == self:oSelected })) == 0
	self:oSelected := nil
EndIf

Return ChkOrPosibles(self, nPos, nRet, @nPos0)

/*/{Protheus.doc} IsPosible
	Determina se a Pattern é possível no contexto atual
@author thiago
@since 06/09/2013
@version 1.0

@param cStr, character, Texto a validar
@param nPos, numérico, Posição atual
@param lCase, boolean, Se é case sensitive

@return boolean, Verdadeiro se possível, falso senão.

/*/
METHOD IsPosible(cStr, nPos, lCase) CLASS OrRegExpPattern
Local lRet := .F.
Local nI

For nI := 1 To Len(self:Patterns)
	If lRet := self:Patterns[nI]:IsPosible(cStr, nPos, lCase)
		Exit
	EndIf
Next

Return lRet

Static Function ChkOrPosibles(self, nPos, nRet, nPos0)
Local nI

If Valtype(self:oSelected) != "O" .Or. nPos == 0 .Or. self:vPatterns[nPos,1] != REGEXP_RESULT_SUCCESS
	For nI := 1 To Len(self:vPatterns)
		nRet := self:vPatterns[nI, 1]
		If nRet == REGEXP_RESULT_SUCCESS
			self:oSelected := self:vPatterns[nI, 3]
			Exit
		ElseIf (ValType(self:oSelected) != "O" .Or. !self:oSelected:Satisfatory) .And. self:vPatterns[nI]:Satisfatory
			self:oSelected := self:vPatterns[nI, 3]
		ElseIf ValType(self:oSelected) != "O" .Or. !self:oSelected:Satisfatory ;
			.Or. nRet == REGEXP_RESULT_PARTIAL
			//
			self:oSelected := self:vPatterns[nI, 3]
		EndIf
	Next
EndIf

If Valtype(self:oSelected) == "O"
	nPos := aScan(self:vPatterns, { |aLine| aLine[3] == self:oSelected })
	nPos0 := self:vPatterns[nPos, 2]
	nRet := self:vPatterns[nPos, 1]
	self:Satisfatory := self:oSelected:Satisfatory
Else
	self:Satisfatory := .F.
EndIf

Return If(Empty(nRet), REGEXP_RESULT_FAIL, nRet)



/*/{Protheus.doc} GroupRegExpPattern
	Classe de RegExp para validação de um grupo de patterns
@author thiago.santos
@since 26/08/2013
@version 1.0

/*/
CLASS GroupRegExpPattern FROM RegExpPattern

//Estáticas
DATA Patterns
DATA lInInit
DATA lInEnd
//Variáveis
DATA Posibles
DATA PosiRepets
DATA nCount
DATA LastResult
DATA nStart
DATA nEnd
DATA lReset
DATA Minimal
DATA LastFail
DATA nForceOr

METHOD New(aPatterns, nMin, nMax, nQuantType, lInInit, lINEnd) CONSTRUCTOR
METHOD Mirror()
METHOD RedoMirror(aMirror)
METHOD StartMatch(cStr, nPos, lCase)
METHOD Matching(cStr, nPos0)
METHOD IsLazy()
METHOD IsPosible(cStr, nPos, lCase)
METHOD InInit(cStr, nPos)
METHOD InEnd(cStr, nPos)

ENDCLASS

METHOD New(aPatterns, nMin, nMax, nQuantType, lInInit, lINEnd) CLASS GroupRegExpPattern
Local nI
_Super:New(nMin, nMax, nQuantType)

Default nMin := 1
Default nMax := 1
Default lInInit := .F.
Default lInEnd := .F.

self:Type := REGEXP_GROUP
self:Patterns := aPatterns
self:lInInit := lInInit
self:lINEnd := lINEnd
self:LastResult :=  REGEXP_RESULT_UNKNOWN

For nI := 1 To Len(aPatterns)
	aPatterns[nI]:oParent := self
Next

Return

/*/{Protheus.doc} Mirror
	Retorna uma array com um espelho do Estado atual do Pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@return array, Espelho de estado do pattern

/*/
METHOD Mirror() CLASS GroupRegExpPattern
Local aRet := _Super:Mirror()

aAdd(aRet, aClone(self:Posibles))
aAdd(aRet, aClone(self:PosiRepets))
aAdd(aRet, self:LastResult)
aAdd(aRet, aClone(aGroups))
aAdd(aRet, self:nStart)
aAdd(aRet, self:nEnd)
aAdd(aRet, self:nForceOr)
aAdd(aRet, self:nCount)

Return aRet

/*/{Protheus.doc} RedoMirror
	Retorna o pattern para o Estado espelhado informado por parâmetro
@author thiago.santos
@since 26/08/2013
@version 1.0

@param aMirror, array, Espelho de estado do pattern

/*/
METHOD RedoMirror(aMirror) CLASS GroupRegExpPattern
Local nPosIni := Len(aMirror) - 7

_Super:RedoMirror(aMirror)

self:Posibles := aMirror[nPosIni]
self:PosiRepets := aMirror[nPosIni + 1]
self:LastResult := aMirror[nPosIni + 2]
aGroups := aMirror[nPosIni + 3]
self:nStart := aMirror[nPosIni + 4]
self:nEnd := aMirror[nPosIni + 5]
self:nForceOr := aMirror[nPosIni + 6]
self:nCount := aMirror[nPosIni + 7]

Return

/*/{Protheus.doc} StartMatch
	Inicia a validação de pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cStr, character, String a validar
@param nPos, numeric, Posição inicial a validar
@param lCase, boolean, Determina se é case sensitive (true) ou não (false)

@return integer, o resultado da apuração inicial

/*/
METHOD StartMatch(cStr, nPos, lCase) CLASS GroupRegExpPattern
Local nI
Local nAux
Local nRet
self:ResetSatisfatory()
nRet := IIF(self:Satisfatory, REGEXP_RESULT_SUCCESS, REGEXP_RESULT_NOMATCH)

self:nEnd := 0
self:Minimal := 1
self:nCount := 0
self:lReset := .T.
self:nForceOr := nil

For nI := nPos To Len(cStr)
	self:LastFail := nil
	self:Posibles := {}
	self:PosiRepets := {}
	nAux := nI
	nRet := _Super:StartMatch(cStr, @nAux, lCase)

	IF aIn(nRet, Startable) ;
		//.Or. (nRet == REGEXP_RESULT_NOMATCH .And. self:Satisfatory)
		//
		nPos := nAux
		Exit
	ElseIf self:Satisfatory
		nPos := self:nEnd
		Exit
	ElseIf self:lInInit
		If !self:Satisfatory
			self:LastResult :=  REGEXP_RESULT_FAIL
			Exit
		Else
			//nPos := nAux//If self:nCount < Len(self:Patterns)
			//self:lReset := .T.
			//nI--
		EndIf
	Else
		self:nCount := 0
		self:lReset := .T.
		If ValType(self:LastFail) != "U"
			nI := self:LastFail
		EndIf
	EndIf
Next


Return nRet

/*/{Protheus.doc} Matching
	Segue com a validação de matching para o pattern
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cStr, character, String a analisar
@param nPos0, integer, Posição atual

@return integer, o resultado da avaliação (um REGEXP_RESULT)

/*/
METHOD Matching(cStr, nPos0) CLASS GroupRegExpPattern
Local nLen       := Len(self:Patterns)
Local nLenStr    := Len(cStr)
Local lStarted   := .F.
Local lContinue  := .T.
Local nPos        := nPos0
Local lPosibling := .F.
Local aMirror
Local aAux
Local nCnt
Local nAux

Private oPattern

While lContinue
	If !lPosibling
		If self:lReset
			self:nForceOr := nil
			self:nCount++
			self:Patterns[self:nCount]:ResetSatisfatory()
			lStarted := (self:nCount == 1)
		EndIf
	
		oPattern := self:Patterns[self:nCount]

		//Saber se a Pattern é satisfatória antes de qualquer análise é importante,
		//pois isso é um indicador de que na String analisada ao menos um caracter
		//justifica a Pattern
		If oPattern:Satisfatory
			//Projeção de possibilidades.
			//Neste trecho são analisadas as próximas patterns, enquanto a sequência se mantiver satisfatória.
			//Estas possibilidades serão assumidas mais pra frente, da última para a primeira, se a Pattern atual falhar ou se
			//A string for analisada até o final e a Pattern atual continuar válida
			nCnt := self:nCount
			If self:Patterns[nCnt]:QuantType == REGEXP_QUANTIFIER_NORMAL .And.;
				 self:Patterns[nCnt]:Satisfatory .And. ;
				 self:LastResult != REGEXP_RESULT_FAIL
				 // 
				While (nCnt < nLen) .And. self:Patterns[nCnt]:Satisfatory .And. self:Patterns[nCnt]:UniSatisfatory
					nCnt++
					self:Patterns[nCnt]:ResetSatisfatory()
				End
				For nCnt := nCnt to self:nCount+1 STEP -1
					If self:Patterns[nCnt]:IsPosible(cStr, nPos, self:lCase)
						aMirror := { nPos, self:Mirror() }
						aMirror[2,1] := Max(1, aMirror[2,1]) //Possibilidades podem ser detectadas antes de testar o primeiro pattern
						aTail(aMirror[2]) := nCnt
						aAdd(self:Posibles, aMirror)
					EndIf
				Next
				If self:nTimes > 0 .And. self:UniSatisfatory .And. (Empty(self:Max) .Or. self:nTimes+1 < self:Max)
					If self:Patterns[1]:IsPosible(cStr, nPos, self:lCase)
						aMirror := { nPos, self:Mirror() }
						aTail(aMirror[2]) := 1
						aAdd(self:Posibles, aMirror)
					EndIf
				Endif
			EndIf
		EndIf
	Else
		oPattern := self:Patterns[self:nCount]
		lPosibling := .F.
		If self:nStart == nil //Possibilidades podem ser detectadas antes de testar o primeiro pattern
			self:nStart := nPos
		EndIf
	EndIf

	//Os resultados abaixo são indicadores de que a Pattern deve ser iniciada
	If self:LastResult ==  REGEXP_RESULT_NOMATCH .Or. self:lReset
		If oPattern:Type == REGEXP_OR
			If ValType(self:nForceOr) == "U"
				self:nForceOr := 1
			EndIf
			If self:nForceOr < Len(oPattern:Patterns)
				aMirror := self:Mirror()
				aMirror[Len(aMirror)-1] := self:nForceOr+1
				aAdd(self:Posibles, {nPos, aMirror})
			EndIf
		EndIf
		self:lReset := .F.
		//Se for a primeira Pattern, definir a posição inicial do Match como a atual
		If self:nCount == 1
			self:Unisatisfatory := .F.
			self:nStart := nPos
			self:nTimes++
		EndIf
		self:LastResult := oPattern:StartMatch(cStr, @nPos, self:lCase, self:nForceOr)
	Else
		self:LastResult := oPattern:Matching(cStr, @nPos)
	EndIf

	ProcOk(self, @lStarted, @nPos, @nLen, @nLenStr, @cStr)

	If (self:LastResult == REGEXP_RESULT_NOMATCH .Or. self:LastResult == REGEXP_RESULT_FAIL .Or. ;
		(nLenStr <= nPos .And. self:LastResult ==  REGEXP_RESULT_PARTIAL))
		//
		If Len(self:Posibles) > 0
			While Len(self:Posibles) > 0
				nAux := (aMirror := aTail(self:Posibles))[1]
				aSize(self:Posibles, Len(self:Posibles) - 1)
				If Len(aMirror) > 2 .Or. !(self:Satisfatory .And. self:UniSatisfatory) .Or. nAux <= nPos
					UndoGroup(nAux)
					nPos := nAux
					self:lReset := .T.
					self:RedoMirror(aMirror[2])
					lPosibling := .T.
					Exit
				EndIf
			End
			If lPosibling
				Loop
			EndIf
		ElseIf self:UniSatisfatory
			If self:Min > 1 .Or. self:Max != 1
				If self:Min > self:nTimes .Or. Empty(self:Max) .Or. self:nTimes < self:Max
					If nPos < nLenStr
						self:Satisfatory := (self:Min <= self:nTimes)
					Else
						self:Satisfatory := .T.
						self:LastResult := REGEXP_RESULT_SUCCESS
						nPos := self:nEnd - 1
					EndIf
				ElseIf self:nTimes == self:Max
					self:Satisfatory := .T.
					self:LastResult := REGEXP_RESULT_SUCCESS
					nPos := self:nEnd - 1
				EndIf
			Else
				self:Satisfatory := .T.
				self:LastResult := REGEXP_RESULT_SUCCESS
				nPos := self:nEnd - 1
			EndIf
			ChkGroup(self, @cStr)
		EndIf
	EndIf

	nPos++
	lContinue := nPos <= nLenStr .And. self:LastResult == REGEXP_RESULT_PARTIAL .And. !(self:Satisfatory .And. self:UniSatisfatory)

End
nPos--

//Abaixo possíveis falhas são reavaliadas.
//No caso, se a Pattern atual resultou em um NOMATCH ou se a String analisada já chegou no último caracter
//E ainda não foi obtido um Sucesso
If self:LastResult == REGEXP_RESULT_NOMATCH .Or. self:LastResult ==  REGEXP_RESULT_FAIL .Or. ;
		(nLenStr <= nPos .And. self:LastResult ==  REGEXP_RESULT_PARTIAL)
	//Se o resultado atual não for um NoMatch e for satisfatório, o resultado é um sucesso
	//Veja que neste ponto não há outras possibilidades a explorar
	If self:LastResult != REGEXP_RESULT_NOMATCH .And. self:nCount == nLen .And. self:Satisfatory .And. nPos < nLenStr
		self:LastResult := REGEXP_RESULT_SUCCESS
		self:UniSatisfatory := .T.
	//Se o resultado não tem que estar "colado" no início da String e houver mais caracteres
	//a analisar, reseta-se toda a validação e começa-se a avaliar a String de novo
	ElseIf (!self:lInInit) .And. !self:Satisfatory .And. (nLenStr > self:nStart+1) .And. (!lStarted)
		UndoGroup(0)
		//nPos := self:nStart+1
		self:LastResult := self:StartMatch(cStr, @nPos, self:lCase)
	ElseIf self:LastResult !=  REGEXP_RESULT_PARTIAL .And. self:Satisfatory
		self:LastResult := REGEXP_RESULT_NOMATCH
	EndIf
EndIf

If  self:Satisfatory .And. ValType(self:nEnd) == "N" .And. self:LastResult == REGEXP_RESULT_NOMATCH
	nPos0 := self:nEnd - 1
ElseIf self:LastResult == REGEXP_RESULT_SUCCESS .Or. self:LastResult == REGEXP_RESULT_PARTIAL
	nPos0 := nPos
Else
	self:LastFail := nPos
EndIf

Return self:LastResult

METHOD IsLazy() CLASS GroupRegExpPattern
Local lRet       := _Super:IsLazy()

If !lRet
	lRet := self:Satisfatory .And. self:Min == 1 .And. self:Max == 1 .And. aTail(self:Patterns):IsLazy() 
EndIf

Return lRet

/*/{Protheus.doc} IsPosible
	Determina se a Pattern é possível no contexto atual
@author thiago
@since 06/09/2013
@version 1.0

@param cStr, character, Texto a validar
@param nPos, numérico, Posição atual
@param lCase, boolean, Se é case sensitive

@return boolean, Verdadeiro se possível, falso senão.

/*/
METHOD IsPosible(cStr, nPos, lCase) CLASS GroupRegExpPattern

Return self:Patterns[1]:IsPosible(cStr, nPos, lCase)

Static Function ProcOk(self, lStarted, nPos, nLen, nLenStr, cStr)
Local nAux
//Se o último resultado for um sucesso, então isso é sinal de que não há mais o que fazer com a Pattern atual
If self:LastResult == REGEXP_RESULT_SUCCESS
	//Se não for a última Pattern, o resultado é convertido em PARTIAL e o contador de patterns será avançado na próxima chamada
	If self:nCount < nLen
		self:LastResult := REGEXP_RESULT_PARTIAL
		self:lReset := .T.
	Else
		If !self:lInEnd .Or. (Len(cStr) <= nPos)
			self:UniSatisfatory := .T.
			If self:Min > 1 .Or. self:Max != 1
				If self:Min > self:nTimes .Or. Empty(self:Max) .Or. self:nTimes < self:Max
					If nPos < nLenStr
						self:Satisfatory := (self:Min <= self:nTimes)
						self:nCount := 0
						self:Posibles := {}
						self:lReset := .T.
						self:LastResult :=  REGEXP_RESULT_PARTIAL
					Else
						self:LastResult :=  IIF(self:Min > self:nTimes, REGEXP_RESULT_FAIL, REGEXP_RESULT_SUCCESS)
					EndIf
				ElseIf self:nTimes == self:Max
					self:LastResult := REGEXP_RESULT_SUCCESS
					self:UniSatisfatory := .T.
				Else
					self:LastResult := REGEXP_RESULT_FAIL
				EndIf
			EndIf
		Else
			self:LastResult := REGEXP_RESULT_NOMATCH
		EndIf
	EndIf

	//Vale notar que um resultado nunca terá que ser colado com o final se ele for quantificado.
	//Um Group RegExp só será quantificado se for uma sub-expressão. Não é feito tratamento
	//para esta situação porque os Ifs acima já a satisfazem
	If self:lInEnd .And. nPos < nLenStr .And. self:LastResult ==  REGEXP_RESULT_SUCCESS
		If !self:lInInit .And. !lStarted
			UndoGroup(0)
			nPos := self:nStart+1
			self:LastResult := self:StartMatch(cStr, @nPos, self:lCase)
		Else
			self:LastResult :=  REGEXP_RESULT_FAIL
		EndIf
	EndIf
Else
	If oPattern:Satisfatory .And. self:nCount == nLen .And. !self:UniSatisfatory
		self:UniSatisfatory := .T.
		self:Satisfatory := (self:Min <= self:nTimes .And. (Empty(self:Max) .Or. self:nTimes <= self:Max))
		self:nEnd := nPos
	EndIf
	If self:nCount < nLen ;
		.And. oPattern:Satisfatory ;
		.And. (oPattern:IsLazy() ;
			.Or. (self:LastResult != REGEXP_RESULT_PARTIAL ;
				.And. oPattern:QuantType == REGEXP_QUANTIFIER_VORACIOUS))
		//
		nAux := nPos
		If self:LastResult == REGEXP_RESULT_PARTIAL
			nAux++
		EndIf
		If aIn(self:Patterns[self:nCount+1]:StartMatch(cStr, @nAux, self:lCase), Acceptable)
			//Força avançar para o próximo se for preguiçoso e o próximo já satisfazer
			If self:LastResult != REGEXP_RESULT_PARTIAL
				nPos--
			EndIf
			self:LastResult := REGEXP_RESULT_PARTIAL
			self:lReset := .T.
		EndIf
		UndoGroup(nPos)
	EndIf
EndIf	

If (self:LastResult == REGEXP_RESULT_PARTIAL .And. (oPattern:Satisfatory .Or. self:lReset) .And. nLenStr <= nPos) ;
	.Or. (!self:Satisfatory .And. oPattern:Satisfatory .And. (self:LastResult == REGEXP_RESULT_NOMATCH ;
																	.Or. self:LastResult ==  REGEXP_RESULT_FAIL))
	//
	nAux := self:nCount+1
	While nAux <= nLen
		self:Patterns[nAux]:ResetSatisfatory()
		If !self:Patterns[nAux]:Satisfatory
			self:LastResult := REGEXP_RESULT_FAIL
			Exit
		Endif
		nAux++
	End
	If nAux > nLen
		If !self:UniSatisfatory
			self:UniSatisfatory := .T.
			self:Satisfatory := (self:Min <= self:nTimes .And. (Empty(self:Max) .Or. self:nTimes <= self:Max))
			self:nEnd := nPos
		EndIf
		If nLenStr <= nPos .And. self:Satisfatory .And. self:LastResult == REGEXP_RESULT_PARTIAL
			self:LastResult := REGEXP_RESULT_SUCCESS
		EndIf
	EndIf
EndIf

If self:UniSatisfatory .Or. self:LastResult == REGEXP_RESULT_SUCCESS

	If aIn(self:LastResult, Acceptable)
		self:nEnd := nPos+1
		ChkGroup(self, @cStr)
	EndIf

	If self:nCount >= nLen
		If self:Min > self:nTimes .Or. Empty(self:Max) .Or. self:nTimes < self:Max
			self:Satisfatory := (self:Min <= self:nTimes)
		ElseIf self:nTimes == self:Max
			self:Satisfatory := .T.
		Else
			self:LastResult := REGEXP_RESULT_FAIL
		EndIf
	EndIf
EndIf

Return

METHOD InInit(cStr, nPos) CLASS GroupRegExpPattern
Local lRet

If ValType(self:oParent) == "U"
	lRet := self:lInInit
Else
	lRet := _Super:InInit()
EndIf

Return lRet

METHOD InEnd(cStr, nPos) CLASS GroupRegExpPattern
Local lRet
Default cStr := ""
Default nPos := 0
If ValType(self:oParent) == "U"
	lRet := self:lInEnd .And. (nPos < Len(cStr) .Or. self:nCount < Len(self:Patterns))
Else
	lRet := _Super:InEnd(cStr, nPos)
EndIf

Return lRet

Static Function Result(cStr, nStart, nEnd)

Return SubStr(cStr, nStart, nEnd - nStart)


/*/{Protheus.doc} RegExp
	Classe que representa uma regexp
@author thiago.santos
@since 26/08/2013
@version 1.0

/*/
CLASS RegExp

DATA cText
DATA Pattern
DATA Result
DATA GrpIndex
DATA nStart
DATA nEnd

METHOD New(oPattern, aGrpIndex)
METHOD Find(cStr, nMaxOcur, nStart, lCase)
METHOD Match(cStr, lCase)
METHOD Transform(cOutput, nIndex)
METHOD Replace(cOutput)

ENDCLASS

/*/{Protheus.doc} New
	Construtor
@author thiago.santos
@since 26/08/2013
@version 1.0

@param oPattern, object, pattern a avaliar
@param aGrpIndex, array, Array com índice de agrupamentos

/*/
METHOD New(oPattern, aGrpIndex) CLASS RegExp

self:Pattern := oPattern
self:GrpIndex := aGrpIndex
self:nEnd := 0

Return

/*/{Protheus.doc} Find
	Método para encontrar a primeira ocorrência da regexp
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cStr, String a analizar
@param nMaxOcur, integer, número máximo de ocorrências aceitas. Padrão 0 (ilimitado)
@param lCase, Determina se é case sensitive

@todo Fazer com que o método encontra N ocorrências
/*/
METHOD Find(cStr, nMaxOcur, nStart, lCase) CLASS RegExp
Local lRet       := .F.
Local aRes       := {}
Local aRet
Local nPos
Default nMaxOcur := 0
Default nStart := 1

nPos := nStart
self:cText := cStr
aRet := LookRegEx(self, cStr, @nPos, lCase)
If ValType(aRet) == "A"
	lRet := .T.
	self:nStart := self:Pattern:nStart
	self:nEnd := self:Pattern:nEnd
	aAdd(aRes, aRet)
	If !self:Pattern:lInInit .And. !self:Pattern:lInEnd
	
		While ValType(aRet) == "A" .And. nPos <= Len(cStr)
			aRet := LookRegEx(self, cStr, @nPos, lCase)
			If ValType(aRet) == "A"
				self:nEnd := self:Pattern:nEnd
				aAdd(aRes, aRet)
				If nMaxOcur > 0 .And. Len(aRes) >= nMaxOcur
					Exit
				EndIf
			EndIf
		End
	EndIf
EndIf

self:Result := aRes

Return Len(aRes) > 0


/*/{Protheus.doc} Match
	Verifica se a string fornecida bate exatamente com a regexp
@author thiago
@since 01/09/2013
@version 1.0

@param cStr, character, String a validar
@param lCase, boolean, Determina se é case sensitive

/*/
METHOD Match(cStr, lCase) CLASS RegExp

Return (Valtype(LookRegEx(self, cStr,, lCase, .T.)) == "A")

/*/{Protheus.doc} Transform
	Método para gerar uma string a partir de agrupamentos da string processada com a regexp
@author thiago.santos
@since 26/08/2013
@version 1.0

@param cOutput, character, padrão de saída
@param nIndex, integer, Índice do resultado

@todo Fazer com que o método efetivamente substitua as ocorrências da string original pelo padrão
/*/
METHOD Transform(cOutput, nIndex) CLASS RegExp
Local nLen       := Len(cOutPut)
Local nStart     := 1
Local cNum
Local nNum
Local nNum2
Local cRet
Local cChar
Local cAux
Local nI

Private aGroups

If nIndex > 0 .And. ValType(self:Result) != "U" .And. Len(self:Result) >= nIndex
	aGroups := self:Result[nIndex, 2]

	If Len(aGroups) == 0
		cRet := cOutput
	Else
		cRet := ""
		For nI := 1 To nLen
			If (cChar := SubStr(cOutput, nI, 1)) == "\" .And. nI < nLen
				cRet += SubStr(cOutput, nStart, nI - nStart)
				nI++
				nStart := nI
				cChar := SubStr(cOutput, nI, 1)
				Do Case
					Case cChar == "n"
						cRet += chr(13)
					Case cChar == "r"
						cRet += chr(10)
					Case "0" <= cChar .And. cChar <= "9"
						nNum := GrabNumber(aGroups, @cOutput, @cChar, @nI, @nLen, @cNum)
						If 0 < nNum .And. nNum <= Len(aGroups)
							If Len(aGroups[nNum]) > 0
								cRet += aGroups[nNum][1]
							EndIf
						Else
							cRet += "\"+cNum
						EndIf
						nStart := nI
					Case cChar == "<"
						nI++
						cAux := ""
						While !((cChar := SubStr(cOutput, nI, 1)) $ ",>")
							cAux += cChar
							nI++
						End
						nI++
						If cChar == "," .And. "0" <= (cChar := SubStr(cOutput, nI, 1)) .And. cChar <= "9"
							nNum2 := GrabNumber(aGroups, @cOutput, @cChar, @nI, @nLen)
						Else
							nNum2 := 1
						EndIf
						If !Empty(cAux) .And. (nNum := aScan(self:GrpIndex, { |aGroup| aGroup[1] == cAux })) > 0 ;
							.And. (0 < nNum2 .And. nNum2 <= Len(aGroups[nNum]) .Or. nNum2 == 1)
							//
							If Len(aGroups[nNum]) > 0
								cRet += aGroups[nNum][1]
							EndIf
						Else
							cRet += "\!#ERRORNAMEDGROUP#!"
						EndIf
						nStart := nI
					Case cChar == "("
						nI++
						If "0" <= (cChar := SubStr(cOutput, nI, 1)) .And. cChar <= "9"
							nNum2 := 0
							nNum := GrabNumber(aGroups, @cOutput, @cChar, @nI, @nLen, @cNum)
							If cChar == ","
								nI++
								If "0" <= (cChar := SubStr(cOutput, nI, 1)) .And. cChar <= "9"
									nNum2 := GrabNumber(aGroups, @cOutput, @cChar, @nI, @nLen, @cNum)
								EndIf
							EndIf
							If 0 < nNum .And. nNum <= Len(aGroups)
								If Len(aGroups[nNum]) > 0
									If 0 >= nNum2 .Or. nNum2 > Len(aGroups[nNum])
										nNum2 := 1
									EndIf
									cRet += aGroups[nNum, nNum2]
								EndIf
							Else
								cRet += "\"+cNum
							EndIf
						Else
							UserException("Not implemented yet")
							Return nil
						EndIf
						If SubStr(cOutput, nI, 1) != ")"
							UserException("Group capturing invalid")
							Return nil
						Else
							nI++
							nStart := nI
						EndIf
					Case cChar == "{" //Codeblock
						nI++
						cAux := ""
						While (cChar := SubStr(cOutput, nI, 1)) != "}"
							cAux += cChar
							nI++
						End
						cRet += &cAux
						nStart := nI+1
					OtherWise
						cRet += "\"+cChar
				EndCase
			EndiF
		Next
		cRet += SubStr(cOutput, nStart)
	EndIf
EndIf

Return cRet


/*/{Protheus.doc} Replace
	Substitui as ocorrências encontradas pelo padrão de output fornecido
@author thiago
@since 01/09/2013
@version 1.0

@param cOutput, character, Padrão de output

/*/
METHOD Replace(cOutput) CLASS RegExp
Local cRet       := ""
Local nInit      := 1
Local nI

If ValType(self:Result) != "U" .And. Len(self:GrpIndex) > 0
	For nI := 1 To Len(self:Result)
		cRet += Substr(self:cText, nInit, self:Result[nI, 3, 1]-nInit) ;
					+self:Transform(cOutput, nI)
		nInit := self:Result[nI, 3, 2]
	Next
	cRet += Substr(self:cText, nInit)
EndIf

Return cRet

/*/{Protheus} GrabNumber
	Obtém um número contínuo a partir da posição especificada
@author thiago
@since 01/09/2013
@version 1.0

@param aGroups, array, Grupos capturados
@param cOutput, character, Padrão de output
@param cChar, character, caracter inicialmente capturado
@param nI, integer, posição
@param nLen, integer, tamanho máximo do output

@return integer, o número capturado
/*/
Static Function GrabNumber(aGroups, cOutput, cChar, nI, nLen, cNum)
cNum := ""
While "0" <= cChar .And. cChar <= "9".And. nI <= nLen .And. val(cNum+cChar) <= Len(aGroups)
	cNum += cChar
	nI++
	If nI <= nLen
		cChar := SubStr(cOutput, nI, 1)
	EndIf
End
Return int(val(cNum))

/*/{Protheus} LookRegEx
	Função para busca ou validação de regexp
@author thiago
@since 01/09/2013
@version 1.0

@param self, object, Instância de regexp
@param cStr, character, String a processar
@param nPosIni, integer, Posição inicial
@param lCase, boolean, Se é case sensitive
@param lMatch, boolean, se é para validar ou buscar

@return array, Vetor com as ocorrências encontradas, ou nil caso não existam ocorrências
/*/
Static Function LookRegEx(self, cStr, nPosIni, lCase, lMatch)
Local aRet       := nil
Local aBoundary
Local aGrpRes
Local nPos
Local nJ
Local nRet
Local nRetAnt

Default lCase := .T.
Default lMatch := .F.
Default nPosIni := 1

Private oRegExp    := self
Private aGrpProj   := IIF(lMatch, {}, Array(Len(self:GrpIndex)))
Private aGroups := aClone(aGrpProj)
Private lProjectin := nil //Declarando apenas para se certificar que sua existência anterior não vai interferir

aGrpRes := aClone(aGrpProj)
For nPos := 1 To Len(aGroups)
	aGroups[nPos] := {}
	aGrpRes[nPos] := {}
Next

If lMatch
	aBoundary := { self:Pattern:lInInit, self:Pattern:lInEnd}
	self:Pattern:lInInit := .T.
	self:Pattern:lInEnd := .T.
EndIf

//Achar o primeiro match start
nPos := nPosIni
nRet := self:Pattern:StartMatch(cStr, @nPos, lCase)
If nRet == REGEXP_RESULT_NOMATCH
	nRet := IIF(self:Pattern:Satisfatory, REGEXP_RESULT_SUCCESS, REGEXP_RESULT_FAIL)
EndIf

//Seguir avaliando se ainda não tem um resultado definitivo
If !aIn(nRet, Definable)
	For nPos := nPos+1 To Len(cStr)
		IF aIn(nRet := self:Pattern:Matching(cStr, @nPos), Definable)
			Exit
		ElseIf nRet == REGEXP_RESULT_NOMATCH .And. self:Pattern:Satisfatory
			nRet := REGEXP_RESULT_SUCCESS
			Exit
		EndIf
		nRetAnt := nRet
	Next
EndIf

If lMatch
	self:Pattern:lInInit := aBoundary[1]
	self:Pattern:lInEnd := aBoundary[2]
EndIf

If nRet !=  REGEXP_RESULT_SUCCESS
	nRet :=  IIF(nRet == REGEXP_RESULT_PARTIAL .And. self:Pattern:Satisfatory, REGEXP_RESULT_SUCCESS, REGEXP_RESULT_FAIL)
EndIf

If nRet ==  REGEXP_RESULT_SUCCESS
	nPosIni := self:Pattern:nEnd
	aRet := {nil,aGrpRes, { self:Pattern:nStart, self:Pattern:nEnd } }
	aRet[1] := Result(cStr, self:Pattern:nStart, self:Pattern:nEnd)
	For nPos := 1 To Len(aGroups)
		For nJ := 1 To Len(aGroups[nPos])
			If self:Pattern:nStart <= aGroups[nPos, nJ, 1] ;
				.And. aGroups[nPos, nJ, 2] <= self:Pattern:nEnd ;
				.And. ValType(aGroups[nPos, nJ]) != "U" .And. aGroups[nPos, nJ, 4] 
				//
				aAdd(aRet[2, nPos], Result(cStr, aGroups[nPos, nJ, 1], aGroups[nPos, nJ, 2]))
			EndIf
		Next
	Next
EndIf

Return aRet

/*/{Protheus} ChkGroup
	Função para captura de grupo
@author thiago
@since 01/09/2013
@version 1.0

@param oPattern, objecto, instância do padrão a verificar
@param cStr, character, String de onde extrair a captura

/*/
Static Function ChkGroup(oPattern, cStr)
Local nInd
Local nPos

If Len(aGroups) > 0 .And. (nInd := aScan(oRegExp:GrpIndex, { |aGroup| aScan(aGroup[2], oPattern) > 0 }) ) > 0
	If (nPos := aScan(aGroups[nInd], {|aItem| oPattern:nStart <= aItem[1]})) > 0
		aGroups[nInd][nPos] := {oPattern:nStart, oPattern:nEnd, oPattern:nTimes, oPattern:UniSatisfatory .Or. oPattern:LastResult ==  REGEXP_RESULT_SUCCESS}
	Else
		aAdd(aGroups[nInd], {oPattern:nStart, oPattern:nEnd, oPattern:nTimes, oPattern:UniSatisfatory .Or. oPattern:LastResult ==  REGEXP_RESULT_SUCCESS} )
	EndIf
EndIf

Return

/*/{Protheus} UndoGroup
	Desfaz os grupos capturados após a posição informada
@author thiago
@since 01/09/2013
@version 1.0

@param nStart, integer, posição máxima a considerar o grupo aceitável

/*/
Static Function UndoGroup(nStart)
Local nI
Local nJ
Local nDel
Local nLen
Default nStart := 0

For nI := 1 To Len(aGroups)
	If nStart == 0
		aGroups[nI] := {}
	Else
		nDel := 0
		For nJ := 1 To (nLen := Len(aGroups[nI]))
			If ValType(aGroups[nI][nJ]) != "U" .And. aGroups[nI][nJ][1] >= nStart
				aDel(aGroups[nI], nJ)
				nJ--
				nDel++
			EndIf
		Next
		If nDel > 0
			aSize(aGroups[nI], nLen - nDel)
		EndIf
	EndIf
Next

Return

/*/{Protheus} ClassPattern

Classe base para gerar classes de caracter (do tipo intervalo)

@param cIni, character, Caracter inicial
@param cFim, character, caracter final

@return codeblock, Um bloco de código para validar de um caracter é da classe

@author Thiago Oliveira Santos
@since 22/05/2013
@version 1.0
/*/
Static Function ClassPattern(cIni, cFim, lNot)
Local bRet
Default lNot := .F.
If lNot
	bRet := { |cStr| cIni > cStr .Or. cStr > cFim }
Else
	bRet := { |cStr| cIni <= cStr .And. cStr <= cFim }
EndIf

Return bRet

/*/{Protheus} WordPattern

Pattern para letras (\w)

@return codeblock, o Pattern

@author Thiago Oliveira Santos
@since 22/05/2013
@version 1.0
/*/
Static Function WordPattern()
Return bWord

/*/{Protheus} NWordPattern

Pattern para caracteres que não são letras (\W)

@return codeblock, o pattern

@author Thiago Oliveira Santos
@since 22/05/2013
@version 1.0
/*/
Static Function NWordPattern()
Return bNWord

/*/{Protheus} DigPattern

Pattern para dígitos (\d)

@return codeblock, o pattern

@author Thiago Oliveira Santos
@since 22/05/2013
@version 1.0
/*/
Static Function DigPattern()
Return bDigits

/*/{Protheus} NDigPattern

Pattern para não dígitos (\D)

@return codeblock, o pattern

@author Thiago Oliveira Santos
@since 22/05/2013
@version 1.0
/*/
Static Function NDigPattern()
Return bNDigits

/*/{Protheus} AnyPattern

True para qualquer caracter ( . )

@return codeblock, o pattern

@author Thiago Oliveira Santos
@since 22/05/2013
@version 1.0
/*/
Static Function AnyPattern()
Return bAny

/*/{Protheus} CharPattern
Padrão que determina se o char é igual a um caracter específico

@param character, cChar do critério

@return Bloco de código com a comparação
@author thiago.santos
@since 07/06/2013
@version 1.0
/*/
Static Function CharPattern(cStr, lNot)
Local bRet
Default lNot := .F.

If lNot
	bRet := { |cChr| !(cChr $ cStr) }
Else
	bRet := { |cChr| cChr $ cStr }
EndIf

Return bRet

#xTranslate ST_GETTING => 0
#xTranslate ST_CLASSING => 1
#xTranslate ST_GROUPING => 2
#xTranslate ST_QUANTING => 3

#xTranslate TP_PATTERN => 0


	
/*/{Protheus.doc} REComp
	
@author thiago.santos
@since 05/09/2013
@version 1.0
		
@param cPattern, character, Pattern a compilar

@return object, Instância de RegExp

/*/
User Function REComp(cPattern)

Return RegExpComp(cPattern)

/*/{Protheus} RegExpComp
	
@author thiago.santos
@since 05/09/2013
@version 1.0
		
@param cPattern, character, Pattern a compilar
@param nIni, numeric, Posição inicial a processar
@param aParams, array, array com informações sobre grupos de captura

@return object, Instância de RegExp

/*/
Static Function RegExpComp(cPattern, nIni, aParams)
Local cChar
Local nI
Local uEscape
Local cTypeEsc
Local oRet
Local nMin
Local nMax
Local nQuantType
Local nStatus    := ST_GETTING
Local cLiteral   := ""
Local lEscape    := .F.
Local lQntifier  := .F.
Local aPatterns  := {}
Local aOr        := {}
Local lSub       := (ValType(aParams) != "U")
Local lStart     := lSub .Or. Left(cPattern, 1) == "^" //Um sub-grupo sempre deve ser colado ao começo
Local lEnd       := !lSub .And. Right(cPattern, 1) == "$"
Local nEnd       := IIF(lEnd, Len(cPattern)-1, Len(cPattern))
Local lOrLiteral := .T.
Local aGroupIndex := {}
Local cAux
Local nAux
Local nGroup
Local lGroup

Default nIni       := IIF(lStart, 2, 1)
Default aParams    := {}

For nI := nIni To nEnd
	cChar := SubStr(cPattern, nI, 1)
	Do Case
		Case lEscape
			If (cTypeEsc := ValType(uEscape)) != "U"
				If cTypeEsc == "C"
					cLiteral += uEscape
				Else
					addLiteral(aPatterns, @cLiteral)
					If cTypeEsc == "B"
						aAdd(aPatterns, BlCodeRegExpPattern():New(uEscape))
					ElseIf cTypeEsc == "O"
						If nMin == 1 .And. nMax == 1
							aAdd(aPatterns,  uEscape)
						Else
							uEscape:Min := nMin
							uEscape:Max := nMax
							uEscape:QuantType := nQuantType
							nMin := nMax := 1 
							aAdd(aPatterns, uEscape)
						EndIf
					ElseIf cTypeEsc == "A"
						aAdd(aPatterns,  GroupRegExpPattern():New(uEscape,,,,.T.))
					EndIf
					lQntifier := .F.
				EndIf
				uEscape := nil
			EndIf
		//Avalia uma expressão de escape e retorna em uEscape seu real significado
			RegExpEsc(cChar, @uEscape, @cPattern, @nI)
			lEscape := .F.
		Case nStatus == ST_GETTING
		//Verifica se o Caracter atual é um marcador de quantificação, e determina
		//os valores de quantificação
			If cChar $ "{+*?"
				If !RegExpQnt(cPattern, @nI, @nMin, @nMax, @nQuantType)
					UserException("Invalid Quantifier")
				Else
					lQntifier := .T.
				EndIf
				cChar := "" //Limpar cChar porque ele já foi avaliado
			Else
			//Se não for marcador de quantificação, manter q quanficiação padrão: max = min = 1.
				lQntifier := .F.
				nMax := nMin := 1
				nQuantType := REGEXP_QUANTIFIER_NORMAL
			EndIf
			If (cTypeEsc := ValType(uEscape)) != "U"
				If cTypeEsc == "C"
					cLiteral += uEscape
				Else
					addLiteral(aPatterns, @cLiteral)
					If cTypeEsc == "B"
						aAdd(aPatterns, BlCodeRegExpPattern():New(uEscape, nMin, nMax, nQuantType))
					ElseIf cTypeEsc == "O"
						If nMin == 1 .And. nMax == 1
							aAdd(aPatterns,  uEscape)
						Else
							uEscape:Min := nMin
							uEscape:Max := nMax
							aAdd(aPatterns, uEscape)
						EndIf
					ElseIf cTypeEsc == "A"
						aAdd(aPatterns,  GroupRegExpPattern():New(uEscape, nMin, nMax, nQuantType,.T.))
					EndIf
					lQntifier := .F.
				EndIf
				uEscape := nil
			EndIf
			//Se cChar for vazio foi avaliada uma operação de quantificação
			If Len(cChar) == 0
				//Se a operação foi bem sucedida e o quantificador não foi aplicado a um uEscape,
				//Verificar se há caracteres literais recolhidos e aplicar o quantificador ao último deles
				If lQntifier .and. Len(cLiteral) > 0
					//Se houver mais de 1 literal recolhido, aplicar uma regra de comparação literal
					addLiteral(aPatterns, @cLiteral, nMin, nMax, nQuantType)
				EndIf
			//Se o caracter atual for \, o próximo é um caracter de escape, e será avaliado de maneira
			///Especial
			ElseIf cChar == "\"
				lEscape := .T.
			ElseIf cChar == "[" //Classe de caracter
				addLiteral(aPatterns, @cLiteral)
				uEscape := GetREClass(cPattern, @nI)
			ElseIf cChar == "." //Qualquer caracter
				uEscape := AnyPattern()
			ElseIf cChar == "("
				nGroup := nI
				nI++
				cAux := ""
				If SubStr(cPattern, nI, 1) == "?"
					nI++
					If lGroup := (SubStr(cPattern, nI, 1) == ":")
						nI++
					ElseIf SubStr(cPattern, nI, 1) == "<"
						nI++
						While SubStr(cPattern, nI, 1) != ">"
							cAux += SubStr(cPattern, nI, 1)
							nI++
						End
						nI++
					EndIf
				Else
					lGroup := .F.
				EndIf
				uEscape := RegExpComp(cPattern, @nI,@aParams)
				If !lGroup
					If !Empty(cAux) .And. (nAux := aScan(aParams, { |aGroup| aGroup[2, 1] == cAux })) > 0
						aAdd(aParams[nAux,2,2], uEscape)
					Else
						aAdd(aParams, { nGroup, { cAux, { uEscape } } })
					EndIf
				EndIf
			ElseIf cChar == ")"
				If !lSub
					UserException ("Invalid character )")
				EndIf
				Exit
			ElseIf cChar == "|"
				If Len(aPatterns) > 0
					addLiteral(aPatterns, @cLiteral)
					aAdd(aOr, GroupRegExpPattern():New(aPatterns,,,,.T.))
					aPatterns := {}
					lOrLiteral := .F.
				ElseIf !Empty(cLiteral)
					aAdd(aOr, cLiteral)
					cLiteral := ""
				EndIf
			Else
				cLiteral += cChar
			EndIf
	EndCase
Next

If lSub
	If cChar == ")"
		nIni := nI
	Else
		UserException("Unterminated grouping")
	EndIf
EndIf

If (cTypeEsc := ValType(uEscape)) != "U"
	If cTypeEsc == "C"
		cLiteral += uEscape
	Else
		addLiteral(aPatterns, @cLiteral)
		If cTypeEsc == "B"
			aAdd(aPatterns, BlCodeRegExpPattern():New(uEscape))
		ElseIf cTypeEsc == "O"
			If nMin == 1 .And. nMax == 1
				aAdd(aPatterns,  uEscape)
			Else
				uEscape:Min := nMin
				uEscape:Max := nMax
				aAdd(aPatterns, uEscape)
			EndIf
		ElseIf cTypeEsc == "A"
			aAdd(aPatterns,  GroupRegExpPattern():New(uEscape,,,,.T.))
		EndIf
		lQntifier := .F.
	EndIf
EndIf

If Len(aPatterns) > 0 .Or. !lOrLiteral
	addLiteral(aPatterns, @cLiteral)
EndIf

If Len(aOr) > 0
	If Len(aPatterns) > 0
		aAdd(aOr, GroupRegExpPattern():New(aPatterns,,,,.T.))
		lOrLiteral := .F.
	EndIf
	If lOrLiteral
		If !Empty(cLiteral)
			aAdd(aOr, cLiteral)
		EndIf
		aPatterns := { LiteralRegExpPattern():New(aOr) }
	Else
		If !Empty(cLiteral)
			aAdd(aOr, LiteralRegExpPattern():New(cLiteral))
		EndIf
		For nI := 1 To Len(aOr)
			If ValType(aOr[nI]) == "C"
				aOr[nI] := LiteralRegExpPattern():New(aOr[nI])
			EndIf
		Next
		aPatterns := { OrRegExpPattern():New(aOr) }
	EndIf
ElseIf Len(aPatterns) == 0
	aPatterns := { LiteralRegExpPattern():New(cLiteral) }
EndIf

//Cria o Grupo principal
oRet := GroupRegExpPattern():New(aPatterns,,,,lStart,lEnd)

If !lSub
	aSort(aParams,,, { |aLine, aLine2| aLine[1] < aLine2[1] })
	For nI := 1 To Len(aParams)
		aAdd(aGroupIndex, aParams[nI, 2])
	Next
	oRet := RegExp():New(oRet, aGroupIndex)
EndIf

Return oRet

/*/{Protheus} addLiteral
	Analisa e adiciona uma expressão literal à validação 
@author thiago
@since 01/09/2013
@version 1.0

@param aPatterns, array, vetor com as patterns capturadas
@param cLiteral, character, stirng literal a tratar
@param nMin, integer, repetição mínima, padrão 1
@param nMax, integer, repetição máxima, padrão 1
@param nQuantType, integer, tipo do quantificador: 0 - normal, 1 - preguiçoso, 2 - voraz
/*/
Static Function addLiteral(aPatterns, cLiteral, nMin, nMax, nQuantType)
Local nLen := Len(cLiteral)

Default nMin := 1
Default nMax := 1

If nLen == 1
	aAdd(aPatterns, BlCodeRegExpPattern():New(CharPattern(cLiteral), nMin, nMax, nQuantType))
ElseIf nLen > 1
	If nMin != 1 .Or. nMax != 1
		aAdd(aPatterns, LiteralRegExpPattern():New(Left(cLiteral, nLen-1)))
		aAdd(aPatterns, BlCodeRegExpPattern():New(CharPattern(Right(cLiteral, 1)), nMin, nMax, nQuantType))
	Else
		aAdd(aPatterns, LiteralRegExpPattern():New(cLiteral))
	EndIf
EndIf
cLiteral := ""

Return


/*/{Protheus} RegExpEsc
Tratamento de caracteres de Escape na compilação da expressão

@param cChar, character, caracter a analisar
@param uEscape, undefined, Resultado da avaliação

@author thiago.santos
@since 07/06/2013
@version 1.0
/*/
Static Function RegExpEsc(cChar, uEscape, cPattern, nI, lRE)
Static cHexa := "0123456789ABCDEF"
Local cNum
Local nNum

Default lRE := .F.

Do Case
	Case cChar == "w"
		uEscape := WordPattern()
	Case cChar == "W"
		uEscape := NWordPattern()
	Case cChar == "d"
		uEscape := DigPattern()
	Case cChar == "D"
		uEscape := NDigPattern()
	Case cChar == "s"
		uEscape := " "
	Case cChar == "a"
		uEscape := Chr(7)
	Case cChar == "t"
		uEscape := Chr(9)
	Case cChar == "n"
		uEscape := Chr(10)
	Case cChar == "v"
		uEscape := Chr(11)
	Case cChar == "f"
		uEscape := Chr(12)
	Case cChar == "r"
		uEscape := Chr(13)
	Case cChar == "e"
		uEscape := Chr(27)
	Case cChar == "Q"
		nI++
		uEscape := ""
		While nI < Len(cPattern) .And. SubStr(cPattern, nI, 2) != "\E"
			uEscape += SubStr(cPattern, nI, 1)
			nI++
		End
		If nI < Len(cPattern)
			nI += 2
		EndIf
	Case "1" <= cChar .And. cChar <= "9"
		cNum := ""
		While "0" <= cChar .And. cChar <= "9"
			cNum += cChar
			nI++
			cChar := SubStr(cPattern, nI, 1)
		End
		nI-- //Regride um para não pular caracter na próxima volta
		uEscape := ParameterRegExpPattern():New({ int(Val(cNum)), 1})
	Case cChar == "x"
		cNum := Upper(SubStr(cPattern, nI+1, 1))
		If !(cNum $ cHexa)
			nNum := (At(Left(cNum, 1), cHexa)-1)*16
			cNum := Upper(SubStr(cPattern, nI+2, 1))
			If !(cNum $ cHexa)
				nNum += At(Left(cNum, 1), cHexa)-1
				nI += 2
				uEscape := Chr(nNum)
			Else
				UserException ("Invalid Hexa ASCII code")
			EndIf
		Else
			UserException ("Invalid Hexa ASCII code")
		EndIF
	Case lRE .And. cChar == "b"
		uEscape := Char(8)
	OtherWise
		uEscape := cChar
EndCase

Return

/*/{Protheus} RegExpQnt
Tratamento de quantificadores

@param cPattern, character, Padrão a analisar
@param nIni, numeric, Posição Inicial
@param nMin, numeric, Quantidade mínima esperada
@param nMax, numeric, Quantidade máxima esperada

@return boolean, sempre verdadeiro

@author thiago.santos
@since 07/06/2013
@version 1.0
/*/
Static Function RegExpQnt(cPattern, nIni, nMin, nMax, nQuantType)
Local cNum       := ""
Local lMin       := .F.
Local cChar      := "}"
Local lQuant     := .T.
Local nI

If (cChar := SubStr(cPattern, nIni, 1)) == "*"
	nMin := 0
	nMax := 0
ElseIf cChar == "+"
	nMin := 1
	nMax := 0
ElseIf cChar == "?"
	nMin := 0
	nMax := 1
ElseIf cChar == "{"
	For nI := nIni+1 To Len(cPattern)
		If (cChar := SubStr(cPattern, nI,1)) $ "0123456789"
			cNum += cChar
		Else
			If !lMin
				lMin := .T.
				nMin := Int(Val(cNum))
				nMax := nMin
				cNum := ""
			EndIf

			If cChar == ","
				nMax := 0
			ElseIf cChar == "}"
				If !Empty(cNum)
					nMax := Int(Val(cNum))
				EndIf
				Exit
			EndIf
		EndIf
	Next
	If cChar == "}"
		nIni := nI
	Else
		UserException ("Unterminated Quantifier")
	EndIf
Else
	lQuant := .F.
	nMin := 1
	nMax := 1
EndIf

nQuantType := REGEXP_QUANTIFIER_NORMAL
If lQuant
	If (cChar := SubStr(cPattern, nIni+1, 1)) $ "+?"
		nQuantType := Iif(cChar == "?", REGEXP_QUANTIFIER_LAZY, REGEXP_QUANTIFIER_VORACIOUS)
		nIni++
	EndIf
EndIf

Return .T.

/*/{Protheus} GetRECLass
Tratamento de classes de caracter

@param cPattern, character, Pattern a analisar
@param nIni, numeric, Posição inicial a analisar

@return codeblock, Bloco de código ou Pattern

@author thiago.santos
@since 07/06/2013
@version 1.0
/*/
Static Function GetREClass(cPattern, nIni)
Local nI
Local nStatus    := 0
Local lInterval  := .F.
Local uEscape
Local aAnd       := {}
Local aOr        := {}
Local cLiteral   := ""
Local lNot       := .F.

For nI := nIni+1 To Len(cPattern)
	cChar := SubStr(cPattern, nI, 1)
	Do Case
		Case nStatus == 1 //Escape
			RegExpEsc(cChar, @uEscape,,,.T.)
			nStatus := 0
			If (cChar := Valtype(uEscape)) == "C"
				If lInterval
					If Len(cLiteral) == 1
						aAdd(aOr, ClassPattern(cLiteral, uEscape, lNot))
					Else
						UserException("Invalid class interval")
					EndIf
					lInterval := .F.
				Else
					cLiteral += uEscape
				EndIf
			ElseIf cChar == "B"
				If lInterval
					cLiteral += "-"
					lInterval := .F.
				EndIf
				If Len(cLiteral) > 0
					aAdd(aOr, CharPattern(cLiteral, lNot))
					cLiteral := ""
				EndIf
				aAdd(aOr, uEscape)
			Else
				UserException("Invalid class Escape")
			EndIf
		Case cChar == "\" //Escape
			nStatus := 1
		Case cChar == "]" //Fim
			If Len(cLiteral) > 0
				aAdd(aOr, CharPattern(cLiteral, lNot))
			EndIf
			aAdd(aAnd, aOr)
			Exit
		Case cChar == "-" //Interval
			If Len(cLiteral) > 1
				aAdd(aOr, CharPattern(Left(cLiteral, Len(cLiteral)-1), lNot))
				cLiteral := Right(cLiteral, 1)
			EndIf
			If Len(cLiteral) == 1
				lInterval := .T.
			Else
				cLiteral := cChar
			EndIf
		Case cChar == "&"
			If lInterval
				UserException("Invalid class interval")
			ElseIf Len(cLiteral) > 0
				aAdd(aOr, CharPattern(cLiteral, lNot))
				cLiteral := ""
			EndIf
			lNot := .F.
			aAdd(aAnd, aOr)
		Case cChar == "^"
			If Len(cLiteral) > 0
				aAdd(aOr, CharPattern(cLiteral, lNot))
				cLiteral := ""
			EndIf
			lNot := !lNot
		Case cChar == "."
			uEscape := AnyPattern()
			nStatus := 0
			If lInterval
				cLiteral += "-"
				lInterval := .F.
			EndIf
			If Len(cLiteral) > 0
				aAdd(aOr, CharPattern(cLiteral, lNot))
				cLiteral := ""
			EndIf
			aAdd(aOr, uEscape)
		Case lInterval
			If Len(cLiteral) == 1
				aAdd(aOr, ClassPattern(cLiteral, cChar, lNot))
				cLiteral := ""
			Else
				UserException("Invalid class interval")
			EndIf
			lInterval := .F.
		OtherWise
			cLiteral += cChar
	EndCase
Next

If cChar == "]" .And. nStatus == 0
	nIni := nI
Else
	UserException ("Unterminated Classifier")
EndIf

Return {|cChr| NewPattern(aAnd, cChr) }

/*/{Protheus} NewPattern
Criação de Pattern personalizada, criada por meio de [ ]

@param aAnd, array, Lista de patterns "and" a analisar. Cada pattern and contém várias "or"

@return boolean, Verdadeiro se passou no teste, falso se não.

@author thiago.santos
@since 07/06/2013
@version 1.0
/*/
Static Function NewPattern(aAnd, cChar)
Local nI
Local nJ
Local lRet       := .F.

For nI := 1 To Len(aAnd)
	lRet := .F.
	For nJ := 1 To Len(aAnd[nI])
		If (lRet := Eval(aAnd[nI][nJ], cChar))
			Exit
		EndIf
	Next
	If !lRet
		Exit
	EndIf
Next
Return lRet

/*/{Protheus} aIn
Determina se certo valor está dentro da array informada

@param uValue, undefined, valor a verificar
@param aArray, array, Array onde a procura é feita

@return boolean, Verdadeiro ou falso

@author thiago.santos
@since 07/06/2013
@version 1.0
/*/
Static Function aIn(uValue, aArray)

Return aScan(aArray, uValue) > 0