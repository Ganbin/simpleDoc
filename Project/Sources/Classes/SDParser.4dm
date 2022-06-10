/**
summary: Simple Doc Parser class
description:
This class is the one that will do all the parsing / generation of markdown documentation

You can copy this class in your project directly and run cs.SDParser.generateDoc(). It will automatically parse all the methods and classes and generate the appropriate markdown documentation.

*/
Class constructor
	This:C1470.keywords:=New collection:C1472("summary"; "description")
	
	
/**
description: function that will generate the markdown documentation for the methods and the classes
*/
Function generateDoc()
	This:C1470.generateDocForMethods()
	
/**
description: function that will generate the markdown documentation for the methods
*/
Function generateDocForMethods()
	ARRAY TEXT:C222($_path; 0)
	METHOD GET PATHS:C1163(Path project method:K72:1; $_path)
	var $attributes; $docuMDObject; $parameter : Object
	var $code; $line; $keyword; $currentKeyword : Text
	var $lines; $keywords : Collection
	var $inSPdoc; $inKeyword; $isClass : Boolean
	var $paremeterIndex : Integer
	$isClass:=False:C215
	
	For ($i; 1; Size of array:C274($_path))
		$docuMDObject:=New object:C1471()
		$docuMDObject.parameters:=New collection:C1472()
		$newKeywordFound:=False:C215
		$inKeyword:=False:C215
		
		METHOD GET CODE:C1190($_path{$i}; $code)
		
		If ($isClass=False:C215)
			METHOD GET ATTRIBUTES:C1334($_path{$i}; $attributes)
			$docuMDObject.attributes:=$attributes
		End if 
		
		$lines:=Split string:C1554($code; "\r")
		$keywords:=This:C1470.keywords.copy()
		
		For each ($line; $lines)
			ARRAY LONGINT:C221($_pos_found; 0)
			ARRAY LONGINT:C221($_length_found; 0)
			
			If ($line="#DECLARE(@") | ($line="Function@") | ($line="local Function@") | ($line="exposed Function@") | ($line="local exposed Function@") | ($line="exposed local Function@")
				
				$docuMDObject.parameters:=This:C1470._extractParemetersFromDeclaration($line)
				$docuMDObject.return:=This:C1470._extractReturnFromDeclaration($line)
				$docuMDObject.name:=$isClass ? This:C1470._extractNameFromFunction($line) : $_path{$i}
				
				If ($docuMDObject.return#Null:C1517)
					$keywords.push($docuMDObject.return.name)
				End if 
				For each ($parameter; $docuMDObject.parameters)
					$keywords.push($parameter.name)
				End for each 
				
			End if 
			
			If ($inSPdoc)
				If ($line="*/")
					$inSPdoc:=False:C215
				Else 
					
					// We are inside a simple comment delimited by /** and */
					For each ($keyword; $keywords)
						If ($line=($keyword+": @"))
							$inKeyword:=True:C214
							$currentKeyword:=$keyword
							break
						End if 
					End for each 
					
					If ($inKeyword)
						$paremeterIndex:=$docuMDObject.parameters.extract("name").indexOf($currentKeyword)
						If ($paremeterIndex=-1)
							If ($docuMDObject.return#Null:C1517) && ($currentKeyword=$docuMDObject.return.name)
								// Return value
								$docuMDObject.return.description:=This:C1470._extractDescription($docuMDObject.return.description; $line; $currentKeyword)
								
							Else 
								// Normal keyword
								If ($docuMDObject[$currentKeyword]=Null:C1517)
									$docuMDObject[$currentKeyword]:=""
								End if 
								$docuMDObject[$currentKeyword]:=This:C1470._extractDescription($docuMDObject[$currentKeyword]; $line; $currentKeyword)
								
								
							End if 
						Else 
							// Paremeters description
							$docuMDObject.parameters[$paremeterIndex].description:=This:C1470._extractDescription($docuMDObject.parameters[$paremeterIndex].description; $line; $currentKeyword)
							
						End if 
					End if 
					
				End if 
			Else 
				If ($line="/**")
					$inSPdoc:=True:C214
				End if 
			End if 
			
		End for each 
		This:C1470.storeMarkdownInFile($_path{$i}; This:C1470._markdownFromDefinition($docuMDObject))
		
	End for 
	
/**
description: generate the markdown from the function/method definition
*/
Function _markdownFromDefinition($definition : Object)->$markdown : Text
/*
shields:
invisible: https://img.shields.io/badge/-invisible-lightgrey
preemptive - capable : https://img.shields.io/badge/preemptive-capable-brightgreen
preemptive - incapable: https://img.shields.io/badge/preemptive-incapable-orange
preemptive - indifferent: https://img.shields.io/badge/preemptive-indifferent-lightblue
*/
	var $parameter : Object
	$markdown:=""
	If ($definition.attributes#Null:C1517)
		If ($definition.attributes.invisible)
			$markdown+="![Invisible](https://img.shields.io/badge/-invisible-lightgrey) "
		End if 
		Case of 
			: ($definition.attributes.preemptive="capable")
				$markdown+="![Preemptive - Capable](https://img.shields.io/badge/preemptive-capable-brightgreen)"
			: ($definition.attributes.preemptive="incapable")
				$markdown+="![Preemptive - Incapable](https://img.shields.io/badge/preemptive-incapable-orange)"
			: ($definition.attributes.preemptive="indifferent")
				$markdown+="![Preemptive - Indifferent](https://img.shields.io/badge/preemptive-indifferent-lightblue)"
		End case 
		$markdown+="\n\n"
	End if 
	
	$markdown+="# `"+$definition.name+"("
	
	If ($definition.parameters.length>0)
		For each ($parameter; $definition.parameters)
			$markdown+=$parameter.name+" : "+$parameter.type+"; "
		End for each 
		$markdown:=Substring:C12($markdown; 1; Length:C16($markdown)-2)
	End if 
	
	$markdown+=")"
	If ($definition.return#Null:C1517)
		$markdown+="->"+$definition.return.name+" : "+$definition.return.type
	End if 
	$markdown+="`"
	
	If ($definition.parameters.length>0)
		$markdown+="\n\n## Parameters\n\n"
		
		For each ($parameter; $definition.parameters)
			
			$markdown+="- `"+$parameter.name+"`"+(($parameter.description="") ? "" : ": "+$parameter.description)+"\n"
			
		End for each 
	End if 
	
	If ($definition.return#Null:C1517)
		$markdown+="\n\n## Return\n\n"
		$markdown+="- `"+$definition.return.name+"`"+(($definition.return.description="") ? "" : ": "+$definition.return.description)+"\n"
	End if 
	
	For each ($keyword; $definition)
		If ($keyword#"parameters") && ($keyword#"return") && ($keyword#"name") && ($keyword#"attributes")
			$markdown+="\n\n## "+Uppercase:C13($keyword[[1]])+Substring:C12($keyword; 2)+"\n\n"
			$markdown+=$definition[$keyword]
		End if 
	End for each 
	
	
/**
store the markdown in the documentation file
*/
Function storeMarkdownInFile($methodPath : Text; $markDown : Text)
	Case of 
		: ($methodPath="[class]/@")
			Folder:C1567(fk database folder:K87:14).file("Documentation/Methods/"+Replace string:C233($methodPath; "[class]/"; "")+".md").setText($markDown)
		Else 
			Folder:C1567(fk database folder:K87:14).file("Documentation/Methods/"+$methodPath+".md").setText($markDown)
	End case 
	
/**
$declaration: Declaration of the parameters. From `#DECLARE` or a `Function` declarations
$parameters: Collection of paremeters with their types.
*/
Function _extractParemetersFromDeclaration($declaration : Text)->$parameters : Collection
	var $parameter : Text
	var $parameterCol : Collection
	var $posChar : Integer
	$parameters:=New collection:C1472()
	
	$posChar:=Position:C15("("; $declaration)
	$declaration:=Substring:C12($declaration; $posChar+1)
	
	$posChar:=Position:C15(")"; $declaration)
	$declaration:=Substring:C12($declaration; 1; $posChar-1)
	
	For each ($parameter; Split string:C1554($declaration; ";"; sk trim spaces:K86:2))
		$parameterCol:=Split string:C1554($parameter; ":"; sk trim spaces:K86:2)
		$parameters.push(New object:C1471("name"; $parameterCol[0]; "type"; $parameterCol[1]; "description"; ""))
	End for each 
	
	
/**
$declaration: Declaration of the parameters. From `#DECLARE` or a `Function` declarations
$return: Return variable name with its type.
*/
Function _extractReturnFromDeclaration($declaration : Text)->$return : Object
	var $posChar : Integer
	$posChar:=Position:C15("->"; $declaration)
	If ($posChar>0)
		$declaration:=Substring:C12($declaration; $posChar+2)
		
		var $parameterCol : Collection
		$parameters:=New collection:C1472()
		$parameterCol:=Split string:C1554($declaration; ":"; sk trim spaces:K86:2)
		$return:=New object:C1471("name"; $parameterCol[0]; "type"; $parameterCol[1]; "description"; "")
		
	End if 
	
	
/**
$declaration: Declaration of the parameters. From `#DECLARE` or a `Function` declarations
$functionName: Name of the function.
*/
Function _extractNameFromFunction($declaration : Text)->$functionName : Text
	var $posChar : Integer
	var $keywords : Collection
	
	$posChar:=Position:C15("("; $declaration)
	If ($posChar=0)
		$keywords:=Split string:C1554($declaration; " ")
	Else 
		$keywords:=Split string:C1554(Substring:C12($declaration; 1; $posChar-1); " ")
	End if 
	$functionName:=$keywords[$keywords.length-1]
	
	
/**
description: extract the description and add new line if needed
*/
Function _extractDescription($currentDescription : Text; $line : Text; $keyword : Text)->$newDescription : Text
	$line:=Replace string:C233($line; $keyword+": "; "")
	If ($currentDescription="")  // Trimm first return lines
		$newDescription:=$line
	Else 
		$newDescription:=$currentDescription+"<br>\n"+$line
	End if 