package reprise.css { 
	
	
	public class CSSParsingResult
	{
		
		
		
		protected	var m_properties : Object;
		
		
		
		public function CSSParsingResult() 
		{
			m_properties = {};
		}
		
		
		
		public function addPropertyForKey( prop : CSSProperty, key : String ) : void
		{
			m_properties[ key ] = prop;
		}
		
		public function propertyForKey( key : String ) : CSSProperty
		{
			return CSSProperty( m_properties[ key ] );
		}
		
		public function properties() : Object
		{
			return m_properties;
		}
		
		public function addEntriesFromResult( res : CSSParsingResult ) : void
		{
			var props : Object = res.properties();
			var key : String;
			for ( key in props )
				addPropertyForKey( props[ key ], key );
		}
		
		
		
		/**
		* pass instances of CSSProperty and String in an alternating order
		**/
		public static function ResultWithPropertiesAndKeys(... args) : CSSParsingResult
		{
			var res : CSSParsingResult = new CSSParsingResult();
			var prop : CSSProperty;
			var key : String;
			var i : Number;
			
			for ( i = 0; i < args.length; i += 2 )
			{
				prop = args[ i ];
				key = args[ i + 1 ];
				
				if ( !( prop is CSSProperty ) || 
						typeof( key ) != 'string' )
				{
					trace( 'WARNING! Wrong type of parameters in ResultWithPropertiesAndKeys. Please make sure ' +
						' you\'re passing instances of CSSProperty and String in alternating order' );
					//com.nesium.utils.ObjUtils.dump( arguments );
					continue;
				}
				
				res.addPropertyForKey( prop, key );
			}
			
			return res;
		}
		
		
		public function toString() : String
		{
			var str : String = '';
			for (var key : String in m_properties)
				str += key + ': ' + m_properties[key] + '\n';
			return str;
		}
	}
}