package de.fork.css {
	import flash.system.System;
	 
	
	
	
	public class CSSDeclarationListItem
	{	
		
		
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		public var m_declarationSpecificity : Number;
		public var m_declarationIndex : Number;
		
		protected var m_selectorStr : String;
		protected var m_selectorRegexp : RegExp;
		public var m_declaration : CSSDeclaration;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSDeclarationListItem(
			selector:String, declaration:Object, index:Number, file:String) 
		{
//			m_selectorStr = selector;
//			
//			var regexp : String = '.*?';
//			//split selector into parts and look at each part
//			var parts : Array = selector.split(' ');
//			for(var i : uint = 0; i < parts.length; i++)
//			{
//				var part : String = parts[i];
//				var directParentChild : Boolean = 
//					part.charAt(part.length - 1) == '>';
//				if (directParentChild)
//				{
//					part = part.substr(0, part.length - 1);
//				}
//				//match everything if part contains * only
//				if (part == '*')
//				{
//					regexp += '\\S';
//				}
//				else
//				{
//					//get rid of superfluous * selector 
//					//and split by class prefix
//					var patternArr : Array = 
//						part.split('*').join('').split('.');
//					
//					//add element name and id part of the pattern 
//					var nameAndId : Array = patternArr.shift().split('#');
//					if (nameAndId.length == 1)
//					{
//						//we've only got an element name (or nothing at all 
//						//in case nameAndId[0] == ''), allow for any id
//						regexp += nameAndId[0] + '\\S*?';
//					}
//					else if (nameAndId[0] == '')
//					{
//						//we've only got an id, allow for any element name
//						regexp += '\\S*?#' + nameAndId[0];
//					}
//					else
//					{
//						//check for element name and id
//						regexp += nameAndId.join('#');
//					}
//					
//					//if there's only one class, just add it to the regexp
//					if (patternArr.length == 1)
//					{
//						regexp += '[\S\.]*\\.' + patternArr[0];
//					}
//					//else, add a disjunct of all (unique) classes
//					else if (patternArr.length > 1)
//					{
//						patternArr.sort();
//						var lastClassName : String = null;
//						var classCount : uint = 0;
//						var classesString : String = '(';
//						for(var j : uint = 0; j < patternArr.length; j++)
//						{
//							var className : String = patternArr[j];
//							if (className != lastClassName)
//							{
//								classesString += '.' + className;
//								classCount++;
//								if (j < patternArr.length - 1)
//								{
//									classesString += '|';
//									lastClassName = className;
//								}
//							}
//						}
//						//match the disjunct as many times as there are classes.
//						//Because the classes are unique, this guarantees all 
//						//classes to be matched
//						regexp += classesString + '){' + classCount + '}';
//					}
//				}
//					
//				//match everything inside the selector to accomodate for 
//				//additional classes
//				regexp += '(\\.\\S)*?';
//				
//				//check for a direct parent child relationship
//				if (i < parts.length - 1)
//				{
//					if (directParentChild)
//					{
//						regexp += ' ';
//					}
//					else
//					{
//						regexp += ' .*?';
//					}
//				}
//			}
//			trace(regexp);
//			m_selectorRegexp = new RegExp(regexp);
			m_selectorStr = (("@" + selector.split(" ").join("@ @").
				split("#").join("|#").split(":").join("|:").split(".").
				join("|.")).split("||").join("|").split("|").join("@|@").
				split(">@").join("@>") + "@").split("@@").join("@");
			m_declarationSpecificity = specificityForSelector(selector);
			m_declaration = CSSDeclaration.
				CSSDeclarationFromObjectDefinedInFile(declaration, file);
			m_declarationIndex = index;
		}
		
		public function declaration() : CSSDeclaration
		{
			return m_declaration;
		}
		
		public function matchesSubjectPath(subjectPath:String) : Boolean
		{
			var patterns : Array = m_selectorStr.split(" ");
			var subjectIndex : Number = subjectPath.length;
			var minSubjectIndex : Number = subjectPath.lastIndexOf(" ") + 1;
			subjectPath += " ";
			
			while(patterns.length)
			{
				//get pattern for the current element from the itemPath
				var currentPattern : Array = patterns.pop().split("|");
				var subjectPartBegin : Number;
				var patternPart : String = String(currentPattern.pop());
				
				//match every element in subjectPath if the current patternPart is
				//a wildcard
				if (patternPart == "@*@" && currentPattern.length == 0)
				{
					subjectPartBegin = 
						subjectPath.lastIndexOf(" ", subjectIndex - 1);
				}
				else 
				{
					//check if the first element of the patternPart is in the 
					//subjectpath at a valid position.
					var patternInSubjectIndex : Number = 
						subjectPath.lastIndexOf(patternPart, subjectIndex);
					if (patternInSubjectIndex < minSubjectIndex)
					{
						return false;
					}
					subjectPartBegin = 
						subjectPath.lastIndexOf(" ", patternInSubjectIndex);
					var subjectPartEnd : Number = 
						subjectPath.indexOf(" ", patternInSubjectIndex);
					var currentSubjectPart : String = 
						subjectPath.substring(subjectPartBegin + 1, subjectPartEnd);
					
					//match all parts of the current pattern to the part of the 
					//subjectPath where the first patternPart occured only.
					while(currentPattern.length)
					{
						patternPart = String(currentPattern.pop());
						if (currentSubjectPart.indexOf(patternPart) == -1)
						{
							return false;
						}
					}
				}
				
				//check if the pattern mandates a direct parent child relationship
				//between the current and the next part and allow matches 
				//in the next part only if true.
				var nextPattern : String = patterns[patterns.length - 1];
				if (nextPattern && nextPattern.charAt(nextPattern.length - 1) == ">")
				{
					minSubjectIndex = 
						subjectPath.lastIndexOf(" ", subjectPartBegin - 1) + 1;
					patterns[patterns.length - 1] = 
						nextPattern.substr(0, nextPattern.length - 2);
				}
				else 
				{
					minSubjectIndex = 0;
				}
				subjectIndex = subjectPartBegin;
			}
			return true;
		}
		
		
		/*
		 pattern for matching selectors against dom paths:
		 
		 first, we have to clean up the selector to guarantee that it contains 
		 no class more than one time for each part of the selector
		 
		 for every part of the selector, the following check has to be built:
		 - does it have an element part?
		 	yes: '[element name]'
		 	no: ''
		 - does it have an id part?
		 	yes: '#[id]'
		 	no: ''
		 - does it have classes?
		 	yes: '(class1|class2|classN)' times N
		 	no: ''
		 
		 next, we have to check if a direct parent child relation holds:
		 	yes: '> '
		 	no: ' .* *' (TODO: verify)
		 
		 repeat for all groups until the last one, but don't execute the 
		 check for parent child relationship for the last one so it doesn't
		 get any trailing stuff
		 
		 exception: * selector
		 implementation: If * is not the only part of the selector, ignore it
		 else, add the following to the regexp: '[^ >]+'
		*/
		public function matchesSubjectPath_regexp(
			subjectPath : String) : Boolean
		{
			subjectPath = subjectPath.split('@').join('');
			subjectPath = subjectPath.split(':').join('.');
//			trace([subjectPath.search(m_selectorRegexp), m_selectorRegexp, subjectPath]);
			return subjectPath.search(m_selectorRegexp) > -1;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function specificityForSelector(selector:String) : Number
		{
			var patterns : Array = selector.split(' ');
			var spec : Number = 0;
			var i : Number = patterns.length;
			
			while (i--)
			{
				spec += specificityForPattern(patterns[i]);
			}			
			return spec;
		}
		
		protected function specificityForPattern(pattern:String) : Number
		{
			var specificityFactorElement : Number = 1;
			var specificityFactorClass : Number = 10;
			var specificityFactorId : Number = 100;
	
			var spec : Number = 0;
			var patternParts : Array = pattern.split('.');
			
			//add specificity of classes multiplied by class count
			spec += (patternParts.length - 1) * specificityFactorClass;
			
			patternParts = patternParts[0].split('#');
			if (patternParts[0] != '')
			{
				spec += specificityFactorElement;
			}
			if (patternParts[1])
			{
				spec += specificityFactorId;
			}
			return spec;
		}
	}
}