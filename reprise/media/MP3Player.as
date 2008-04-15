package reprise.media { 
	import reprise.utils.ProxyFunction;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	public class MP3Player extends EventDispatcher implements IMediaPlayer
	{
		//******************************************************
		//*                  public properties
		//******************************************************
		public static var EVENT_PLAYBACK_START : String = "playbackStartEvent";
		public static var EVENT_PLAYBACK_FINISH : String = "playbackFinishEvent";
		public static var EVENT_BUFFERING : String = "bufferingEvent";
		
		public var bufferingEvent:Event;
		public var playbackStartedEvent:Event;
		public var playbackFinishedEvent:Event;
	
		
		//******************************************************
		//*                  protected properties
		//******************************************************
		protected var m_sound:Sound;
		protected var m_soundTarget:Sprite;
		
		protected var m_loadingStartTime:Number;
		
		protected var m_lastPosition:Number;
		protected var m_isPlaying:Boolean;
		protected var m_isBuffering:Boolean;
		
		protected var m_checkBufferID:Number;
		
		protected var m_volume:Number;
		
		//******************************************************
		//*                  public methods
		//******************************************************
		public function MP3Player (target:Sprite)
		{
			m_soundTarget = target;
			m_sound = new Sound(target);
			m_sound.onSoundComplete = ProxyFunction.create(this, onSoundComplete);
			m_volume = 100;
		}
		
		public function load (source:String) : void
		{
			m_loadingStartTime = getTimer ();
			m_sound.loadSound(source, true);
			pause ();
			clearInterval (m_checkBufferID);
			m_checkBufferID = setInterval(checkBuffer, 50);
			setBuffering (true);
			m_lastPosition = 0;
		}
		
		public function play (offset:Number) : void
		{
			if (offset === null)
			{
				m_sound.start(m_lastPosition);
			} else {
				m_sound.start(offset/1000);
			}
			m_isPlaying = true;
			if (m_sound.getBytesLoaded() > 2000)
			{
				setBuffering(false);
			}
		}
		public function pause () : void
		{
			if (m_isPlaying)
			{
				m_lastPosition = m_sound.position;
				m_isPlaying = false;
				m_sound.stop();
			}
		}
		public function resume () : void
		{
			this.play (m_lastPosition);
		}
		public function stop () : void
		{
			m_lastPosition = 0;
			m_sound.stop();
			m_isPlaying = false;
		}
		
		public function isPlaying () : Boolean
		{
			return m_isPlaying;
		}
		public function isBuffering () : Boolean
		{
			return m_isBuffering;
		}
		
		public function setVolume (volume:Number) : void
		{
			if (volume > 100)
			{
				volume = 100;
			} else if (volume < 0) {
				volume = 0;
			}
			m_volume = volume;
			m_sound.setVolume(volume);
		}
		public function getVolume () : Number
		{
			return m_volume;
		}
		
		public function getBytesLoaded () : Number
		{
			return m_sound.getBytesLoaded();
		}
		public function getBytesTotal () : Number
		{
			return m_sound.getBytesTotal();
		}
		
		public function getDuration () : Number
		{
			return m_sound.duration * m_sound.getBytesTotal() / 
				m_sound.getBytesLoaded();
		}
		public function getDurationLoaded () : Number
		{
			return m_sound.duration;
		}
		
		public function getPosition () : Number
		{
			if (m_isPlaying)
			{
				return m_sound.position;
			} else {
				return m_lastPosition;
			}
		}
		public function getLoadingTimeLeft () : Number
		{
			var loadingTime:Number = getTimer () - m_loadingStartTime;
			var timeLeft:Number = loadingTime / m_sound.getBytesLoaded() * 
				m_sound.getBytesTotal() - loadingTime;
			return timeLeft;
		}
		
		public function getPercentLoaded () : Number
		{
			if (m_sound.getBytesTotal() < 50)
			{
				return 0;
			}
			return m_sound.getBytesLoaded() * 100 / m_sound.getBytesTotal();
		}
		
		public function destroy () : void
		{
			clearInterval (m_checkBufferID);
			m_sound.stop();
			delete m_sound;
		}
		
		
		//******************************************************
		//*                  protected methods
		//******************************************************
		protected function checkBuffer () : void
		{
			if (m_isBuffering)
			{
				var loadingTime:Number = getLoadingTimeLeft();
				if (loadingTime*1.1 < getDuration () - m_lastPosition)
				{
					setBuffering (false);
				}
			}
			else if (m_isPlaying)
			{
				if (m_sound.position == 
					m_sound.duration && m_sound.position < getDuration ())
					{
					setBuffering (true);
				}
			}
		}
		
		protected function setBuffering (buffering:Boolean) : void
		{
			if (buffering)
			{
				m_lastPosition = m_sound.position;
				m_isBuffering = true;
				m_sound.stop ();
				m_sound.setVolume(0);
				dispatchEvent(new Event(EVENT_BUFFERING, this));
			} else {
				m_isBuffering = false;
				m_sound.setVolume(m_volume);
				m_sound.start(m_lastPosition/1000);
				dispatchEvent(new Event(EVENT_PLAYBACK_START, this));
			}
		}
		
		protected function onSoundComplete () : void
		{
			stop();
			dispatchEvent(new Event(EVENT_PLAYBACK_FINISH, this));
		}
	}
}