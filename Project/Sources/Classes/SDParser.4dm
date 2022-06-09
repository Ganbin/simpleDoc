/**
summary: Simple Doc Parser class
definition:
This class is the one that will do all the parsing / generation of markdown documentation

You can copy this class in your project directly and run cs.SDParser.generateDoc(). It will automatically parse all the methods and classes and generate the appropriate markdown documentation.

*/
Class constructor
	
/**
definition: function that will generate the markdown documentation
*/
Function generateDoc()
	
/*
shields:
invisible: https://img.shields.io/badge/-invisible-lightgrey
preemptive - capable : https://img.shields.io/badge/preemptive-capable-brightgreen
preemptive - incapable: https://img.shields.io/badge/preemptive-incapable-orange
preemptive - indifferent: https://img.shields.io/badge/preemptive-indifferent-lightblue
*/
	ARRAY TEXT:C222($_path; 0)
	METHOD GET PATHS:C1163(Path project method:K72:1; $_path)
	var $attributes : Object
	var $code; $line; $docuMD; $regexDeclare : Text
	var $lines : Collection
	var $inSPdoc; $continueSamePart : Boolean
	
	$regexDeclare:="(\\$[a-zA-Z0-9_-]{1,32}) : (Text|Integer|Real|Object|Picture|Collection|Object|Pointer|Boolean)"
	"^#DECLARE\\((((\\$[a-zA-Z0-9_-]{1,32}) : (Text|Integer|Real|Object|Picture|Collection|Object|Pointer|Boolean));? )*((\\$[a-zA-Z0-9_-]{1,32}) : (Text|Integer|Real|Object|Picture|Collection|Object|Pointer|Boolean))*\\)(->(\\$[a-zA-Z0-9_-]{1,32}) : (Text|Inte"+"ger|Real|Object|Picture|Collection|Object|Pointer|Boolean))?"
	For ($i; 1; Size of array:C274($_path))
		$docuMD:=""
		METHOD GET CODE:C1190($_path{$i}; $code)
		METHOD GET ATTRIBUTES:C1334($_path{$i}; $attributes)
		
		$lines:=Split string:C1554($code; "\r")
		
		For each ($line; $lines)
			ARRAY LONGINT:C221($_pos_found; 0)
			ARRAY LONGINT:C221($_length_found; 0)
			If ($line="#DECLARE(@" && (Match regex:C1019($regexDeclare; $line; 1; $_pos_found; $_length_found))
				ALERT:C41("YES")
			End if 
			
			If ($inSPdoc)
				If ($line="*/")
					$inSPdoc:=False:C215
				Else 
					
					
				End if 
			Else 
				If ($line="/**")
					$inSPdoc:=True:C214
				End if 
			End if 
			
		End for each 
		
	End for 