package de.fork.css
{	
	import de.fork.core.Application;
	import de.fork.core.ApplicationRegistry;
	import de.fork.css.propertyparsers.RuntimeParser;
	import de.fork.data.collection.IndexedArray;
	import de.fork.events.CommandEvent;
	import de.fork.events.ResourceEvent;
	import de.fork.external.IResource;
	import de.fork.external.ResourceLoader;
	import de.fork.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.StyleSheet;
	import flash.utils.getTimer;
	
	public class CSS extends EventDispatcher implements IResource
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const PROPERTY_TYPE_STRING : uint = 1;
		public static const PROPERTY_TYPE_INT : uint = 2;
		public static const PROPERTY_TYPE_FLOAT : uint = 3;
		public static const PROPERTY_TYPE_BOOL : uint = 4;
		public static const PROPERTY_TYPE_URL : uint = 5;
		public static const PROPERTY_TYPE_COLOR : uint = 6;
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var g_idSource : Number;
		
		
		public var m_id : Number;
		public var m_priority : Number = 0;
		
		protected var m_cssFile : CSSImport;
		protected var m_loader : ResourceLoader;
		protected var m_importQueue : Array;
		protected var m_cssSegments : IndexedArray;
		protected	var m_declarationList : CSSDeclarationList;
		protected var m_cssVariables : Object;
		
		protected var m_baseURL : String;
		protected var m_url : String;
		protected	var m_timeout : Number = 5000;
		protected var m_retryTimes : Number = 3;
		protected var m_failedTimes : Number;
		protected var m_forceReload : Boolean;
		protected var m_isCancelled : Boolean;
		protected var m_didFinishLoading : Boolean;
		protected var m_runtimeParserRegistered : Boolean;
		
		protected var m_cleanupTime : Number;
		protected var m_parseTime : Number;
		protected var m_importsLoaded : Number;
		protected var m_importsTotal : Number;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSS(url:String = null)
		{
			m_id = g_idSource++;
			
			m_cssSegments = new IndexedArray();
			m_loader = new ResourceLoader();
			m_declarationList = new CSSDeclarationList();
			m_importQueue = [];
			m_cssVariables = {};
			
			m_url = url;
			m_cssFile = cssImportWithURL(url);
			m_cssSegments[0] = m_cssFile;
			m_loader.addResource(m_cssFile);
			m_loader.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		public function execute(...rest) : void
		{
			if (m_url == null)
			{
				throw new Error('You didn\'t specify an URL for your ' + 
					'resource! Make sure you do this before calling execute!');
				return;
			}
			
			if (!m_runtimeParserRegistered)
			{
				CSSDeclaration.registerPropertyCollection(RuntimeParser);
				m_runtimeParserRegistered = true;
			}
			
			m_didFinishLoading = false;
			m_isCancelled = false;
			m_parseTime = 0;
			m_cleanupTime = 0;
			m_importsLoaded = 0;
			m_importsTotal = 1;
			m_cssFile.setURL(CSSParsingHelper.resolvePathAgainstPath(
				url(), baseURL()));
			m_loader.execute();
		}
		
		public function setPriority(value : Number) : void
		{
			m_priority = value;
		}
		public function priority() : Number
		{
			return m_priority;
		}
		public function setId(value : Number) : void
		{
			m_id = value;
		}
		public function id() : Number
		{
			return m_id;
		}
	
		public function load(theURL : String = null) : void
		{
			setURL(theURL);
			execute();
		}
		
		public function cancel() : void
		{
			trace('cancel for CSS is not implemented yet!');
			m_isCancelled = true;
			dispatchEvent(new ResourceEvent(Event.CANCEL));
		}
		
		public function getStyleForSelectorPath(sp : String) : CSSDeclaration
		{
			return getStyleForEscapedSelectorPath(escapeSelectorPath(sp));
		}
		public function getStyleForEscapedSelectorPath(sp : String) : CSSDeclaration
		{
			return m_declarationList.getStyleForSelectorsPath(sp);
		}
		
//		public function getStyleForStylableElement(
//			element : ICSSStylable) : CSSDeclaration
//		{
//			var styles : CSSDeclaration = element.cssDefaultStyles.clone();
//			
//			if (element.cssParent)
//			{
//				styles.inheritCSSDeclaration(element.cssParent.activeStyles);
//			}
//			
//			styles.mergeCSSDeclaration(
//				m_declarationList.getStyleForStylableElement(element));
//			
//			styles.mergeCSSDeclaration(
//				CSSDeclaration.CSSDeclarationFromObject(element.instanceStyles));
//			
//			return styles;
//		}
		
		/**
		 * Escapes a selectorPath and thus prepares it for being processed by the 
		 * css implementation.
		 * 
		 * Use this method of you want to prepare a string once and use it multiple 
		 * times later on.
		 * 
		 * <b>Note:</b>
		 * In order to allow for the preparation of strings that are created by 
		 * concatenating strings that have already been escaped with ones that 
		 * haven't, the escaping process starts after the last escape character, 
		 * i.e. the last '@'.
		 */
		public static function escapeSelectorPath(sp : String) : String
		{
			var stringParts : Array = sp.split('@');
			var input : String = String(stringParts.pop());
			input = input.split(' ').join('@ @'). //escape whitespace
			split('#').join('@@#'). //escape id chars
			split('.').join('@@.'). //escape class chars
			split(':').join('@@:'); //escape pseudo class chars
			
			//add leading escape char
			if (input.charAt(0) != '@')
			{
				input = '@' + input;
			}
			//else remove double leading escape char
			else if (input.charAt(1) == '@')
			{
				input = input.substr(1);
			}
			
			//add trailing escape char
			if (input.charAt(input.length - 1) != '@')
			{
				input += '@';
			}
			
			stringParts.push(input);
			return stringParts.join('@');
		}
		
		public function baseURL() : String
		{
			if (m_baseURL == null)
			{
				var app : Application = 
					ApplicationRegistry.instance().applicationForURL(null);
				return app.applicationURL();
			}
			return m_baseURL; 
		}
	
		public function setBaseURL(val:String) : void
		{
			m_baseURL = val;
		}
				
		/**
		* FileResource facade
		**/
		public function setURL(src : String) : void
		{
			m_url = src;
		}	
		public function url() : String
		{
			return m_url;
		}
		public function content() : *
		{
			return m_declarationList;
		}
		public function setTimeout(timeout : Number) : void
		{
			m_timeout = timeout;
		}
		public function timeout() : Number
		{
			return m_timeout;
		}
		public function setForceReload(bFlag : Boolean) : void
		{
			m_forceReload = bFlag;
		}
		public function forceReload() : Boolean
		{
			return m_forceReload;
		}
		public function setRetryTimes(times : Number) : void
		{
			m_retryTimes = times;
		}
		public function retryTimes() : Number
		{
			return m_retryTimes;
		}
		public function getBytesLoaded() : Number
		{
			return m_importsLoaded;
		}
		public function getBytesTotal() : Number
		{
			return m_importsTotal;
		}
		public function getProgress() : Number
		{
			var progress : Number = Math.round(getBytesLoaded() / (getBytesTotal() / 100));
			if (isNaN(progress))
			{
				progress = 0;
			}
			return progress;		
		}
		public function isCancelled() : Boolean
		{
			return m_isCancelled;
		}
		public function didFinishLoading() : Boolean
		{
			return m_didFinishLoading;
		}
		
		public function resolveImport(cssImport:CSSImport) : void
		{
			var index:Number = m_cssSegments.getIndex(cssImport);
			m_cssSegments[index] = cssImport.data();
			parseImportsInCSSSegmentWithIndex(index, cssImport.url());
			m_importsLoaded++;
			dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));
		}
		
		public function parseCSSStringWithBaseURL(str:String, url:String) : void
		{
			url = url || '/';
			var isLoading : Boolean = m_importsLoaded < m_importsTotal;
			m_cssSegments.push(str);
			
			parseImportsInCSSSegmentWithIndex(m_cssSegments.length - 1, url);
			
			if (isLoading)
			{
				return;
			}
			
			if (m_importQueue.length)
			{
				dequeueImports();
				return;
			}
			
			var result : Boolean = parseCSSSegment(m_cssSegments[0]);
			if (!result)
			{
				trace('Error! Couldn\'t parse css string!');
			}
		}
		
		public function addCSSVariableWithNameAndValue(name:String, val:String) : void
		{
			if (m_cssVariables[name] != null)
			{
				trace('w Warning! CSS Variable with name ' + name + ' is already defined! (' +
					m_cssVariables[name] + ' -> ' + val + ')');			
				return;
			}
			m_cssVariables[name] = val;
		}
		
		public function addCSSVariablesFromObject(obj:Object) : void
		{
			var key : String;
			for (key in obj)
			{
				addCSSVariableWithNameAndValue(key, obj[key]);
			}
		}
	
		public function registerProperty(
			name : String, type : uint, inheritable : Boolean) : void
		{
			RuntimeParser.registerProperty(name, type, inheritable);
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function parseCSSVariables() : void
		{
			var i : Number;
			for (i = 0; i < m_cssSegments.length; i++)
			{	
				var seg : CSSSegment = CSSSegment(m_cssSegments[i]);
				var parts : Array = seg.content().split('@define ');
		
				var j : Number;
				for (j = 1; j < parts.length; j++)
				{
					var part : String = parts[j];
					var lbPos : Number = part.indexOf(';\n');
					var scPos : Number = part.indexOf(';');
					var cutPos : Number = scPos == lbPos ? scPos + 1 : scPos;
					
					var varStr : String = part.substring(0, scPos);
					
					var wsPos : Number = part.indexOf(' ');
					var varName : String = varStr.substring(0, wsPos);
					var varCnt : String = varStr.substring(wsPos + 1, scPos);
					
					addCSSVariableWithNameAndValue(varName, varCnt);
					parts[j] = part.substr(cutPos + 1);
				}
				seg.setContent(parts.join(''));
			}
		}
		
		protected function replaceCSSVariables() : void
		{
			var i : Number = m_cssSegments.length;
			while (i--)
			{
				var seg : CSSSegment = CSSSegment(m_cssSegments[i]);
				var cnt : String = seg.content();
				var varName : String;
				for (varName in m_cssVariables)
				{
					var varCnt : String = m_cssVariables[varName];
					cnt = cnt.split('${' + varName + '}').join(varCnt);
				}
				seg.setContent(cnt);			
			}
		}
		
		protected function parseImportsInCSSSegmentWithIndex(
			index:Number, baseURL:String) : void
		{
			var cssString : String = cleanupCSS(m_cssSegments[index]);
			var segments : Array = cssString.split('@import');
			var parsedSegment : CSSSegment;		
			var i : Number;
			var additionalSegments : Array = [];
	
			parsedSegment = new CSSSegment();
			parsedSegment.setContent(segments[0]);
			parsedSegment.setURL(baseURL);
			m_cssSegments[index] = parsedSegment;
			
			for (i = 1; i < segments.length; i++)
			{
				var url : String;
				var pos : Number;
				var cssImport : CSSImport;
				var segment : String;
				var segmentContent : String;
	
				segment = segments[i];
				pos = segment.indexOf(';');
				
				url = CSSParsingHelper.parseURL(segment.substring(0, pos), baseURL);
				cssImport = cssImportWithURL(url);
				m_importQueue.push(cssImport);
				m_importsTotal++;
				additionalSegments.push(cssImport);
				
				segmentContent = segment.substr(pos + 1);
				if (!StringUtil.isWhitespace(segmentContent))
				{
					parsedSegment = new CSSSegment();
					parsedSegment.setContent(segmentContent);
					parsedSegment.setURL(baseURL);
					additionalSegments.push(parsedSegment);
				}
			}
			
			if (additionalSegments.length)
			{
				m_cssSegments.splice.apply(m_cssSegments, ([index + 1, 0]).concat(additionalSegments));
			}
		}
	
		protected function dequeueImports() : void
		{
			var i:Number;
			m_loader.clear();
			for (i = 0; i < m_importQueue.length; i++)
			{
				m_loader.addResource(m_importQueue[i]);
			}
			m_importQueue = [];
			m_loader.execute();
		}
		
		protected function cssImportWithURL(url:String) : CSSImport
		{
			var cssImport : CSSImport = new CSSImport(this);
			cssImport.setTimeout(timeout());
			cssImport.setRetryTimes(retryTimes());
			cssImport.setForceReload(forceReload());
			cssImport.setURL(url);
			return cssImport;
		}
		
		protected function notifyComplete(success:Boolean, reason:String) : void
		{
			if (!success)
			{
				trace('e ' + reason);
			}
			m_didFinishLoading = true;
			dispatchEvent(new CommandEvent(Event.COMPLETE, success));
		}
		
		protected function loader_complete(event:CommandEvent) : void
		{
			if (!event.success)
			{
				notifyComplete(false, 'CSS "' + url() + '" could not be loaded');
				return;
			}
			
			if (m_importQueue.length)
			{
				dequeueImports();
				return;
			}
			
			parseCSS();
		}
	
		protected function parseCSS() : void
		{
			var i : Number;
			var segment : CSSSegment;
			var success : Boolean;
	
			parseCSSVariables();
			replaceCSSVariables();
			
			for (i = 0; i < m_cssSegments.length; i++)
			{
				segment = m_cssSegments[i];
				success = parseCSSSegment(segment);
				if (!success)
				{			
					trace('f Error parsing css file "' + segment.url() + 
						'". Make sure that all ' +
						'your used variables are defined (if any).');
					break;
				}
			}
			m_cssSegments = new IndexedArray();
			
			var stats : String = '----------------- CSS Stats -----------------\n' +
				' time spent cleaning up strings: ' + m_cleanupTime + ' ms\n' +
				' time spent parsing: ' + m_parseTime + ' ms\n' +
				'---------------------------------------------';
			trace('d ' + stats);
			
			dispatchEvent(new CommandEvent(Event.COMPLETE, success));
		}
		
		protected function parseCSSSegment(segment:CSSSegment) : Boolean
		{
			var timestamp : Number = getTimer();		
			//split string into class definitions
			var classesArr:Array = segment.content().split("}");
			var classNamesArr:Array = new Array();
			
			var i : uint;
			
			for (i = classesArr.length; i--;)
			{
				var cssClassDefArr:Array = classesArr[i].split("{");
				if (cssClassDefArr.length == 2)
				{
					classNamesArr[i] = cssClassDefArr[0];
					cssClassDefArr[0] = "class"+i;
					classesArr[i] = cssClassDefArr.join("{");
				}
			}
			var cleanCSSStr:String = classesArr.join("}\n");
	
			var parser:StyleSheet = new StyleSheet();
			
			parser.parseCSS(cleanCSSStr);
			
			//TODO: find a way to enable parser error handling
//			if ( !parser.parseCSS( cleanCSSStr ) )
//			{
//				trace(8);
//				m_parseTime += getTimer() - timestamp;
//				return false;
//			}
			
			var classNamesArrLen:Number = classNamesArr.length;
			for (i = 0; i < classNamesArrLen; i++)
			{
				var classNames:Array = classNamesArr[i].split("\n").join(" ").
					split("  ").join(" ").split(", ").join(",").split(",");			
				
				var style:Object = parser.getStyle("class"+i);
				var classNamesLen:Number = classNames.length;
				for (var j : Number = 0; j < classNamesLen; j++)
				{
					var className:String = classNames[j];
					
					// --- adding parsed style to declarationlist ---
					m_declarationList.addDeclarationWithSelectorFromFile(
						style, className, segment.url());
				}
			}		
			m_parseTime += getTimer() - timestamp;		
			return true;
		}
		
		/**
		* Tidy css in order to get the Flash CSSParser to actually parse it
		**/
		protected function cleanupCSS(cssStr:String) : String
		{
			var timestamp : Number = getTimer();		
			// remove all comments to ease parsing
			var arr : Array = cssStr.split( "/*" );
			for ( var i : uint = arr.length; i-- > 1; )
			{
				var block:String = arr[i];
				var commentClosePosition:Number = block.indexOf("*/");
				if (commentClosePosition == -1)
				{
					arr[i] = "";
				}
				else
				{
					arr[i] = block.substr(commentClosePosition + 2);
				}
			}
			cssStr = arr.join("");		
			
			//compress string by removing all excess whitespace
			cssStr = cssStr.split("\r\n").join("\n");	// convert windows linebreaks to unix linebreaks
			cssStr = cssStr.split( "\r" ).join( "\n" ); // convert mac linebreaks to unix linebreaks
			
			// remove double linebreaks
			while(cssStr.indexOf("\n\n") > -1)
				cssStr = cssStr.split("\n\n").join("\n");
			
			// convert tabs to spaces	
			cssStr = cssStr.split("\t").join(" ");
			
			// convert double spaces to single spaces
			while(cssStr.indexOf("  ") > -1)
				cssStr = cssStr.split("  ").join(" ");
				
			cssStr = cssStr.split("\n ").join("\n").		// remove spaces at the end of lines
				split(" \n").join("\n").					// remove spaces at the beginning of lines
				split(" {").join("{").						// remove spaces before curly braces
				split("\n{").join("{").						// remove linebreaks before curly braces
				split("}\n").join("}").						// remove linebreaks after curly braces
				//split("} ").join("}").						// remove spaces after curly braces
				split("( ").join("(").						// remove spaces after opening brackets
				split(" )").join(")").						// remove spaces before closing brackets
				split("'").join("").						// remove single quotes
				split("\"").join("").						// remove quotes
				split(" !important").join("!important").	// remove spaces before important tag
				split("> ").join(">").						// remove spaces around child selector
				split(" >").join(">").						// remove spaces around child selector
				split(">").join("> ").						// bring child selector into defined state
				split(" :").join(":").						// remove spaces before colons
				split(" ,").join(",").						// remove spaces before commas
				split(", ").join(",").						// remove spaces after commas
				split(" ;").join(";").						// remove spaces before semicolons
				split("{\n}").join("{}");					// clean empty declarations, because the parser returns nothing otherwise
	
			cssStr = StringUtil.lTrim( cssStr );		
			m_cleanupTime += getTimer() - timestamp;		
			return cssStr;
		}	
	}
}