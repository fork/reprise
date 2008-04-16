////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.media { 
	import reprise.events.MediaEvent;
	import reprise.utils.ProxyFunction;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	public class FLVPlayer extends EventDispatcher implements IMediaPlayer
	{
		
		protected var m_nConn:NetConnection;
		protected var m_nStream:NetStream;
		
		protected var m_sound:Sound;
		protected var m_soundTarget:MovieClip;
		
		protected var m_videoView:Video;
		
		protected var m_loadingStartTime:Number;
		
		protected var m_lastPosition:Number;
		protected var m_isPlaying:Boolean;
		protected var m_isBuffering:Boolean;
		
		protected var m_checkBufferID:Number;
		
		protected var m_duration:Number = NaN;
		protected var m_volume:Number;
	
		protected var m_metaData : Object;
	
		protected var m_videoWidth : Number;
	
		protected var m_videoHeight : Number;
		
		public function FLVPlayer (videoView:Video, soundTarget:MovieClip)
		{
			m_soundTarget = soundTarget;
			m_videoView = videoView;
			
			m_nConn = new NetConnection ();
			m_nConn.connect(null);
			m_nStream = new NetStream (m_nConn);
			
			videoView.attachVideo(m_nStream);
			soundTarget.attachAudio(m_nStream);
			m_sound = new Sound (soundTarget);
			m_volume = 100;
		}
		
		public function load (source:String) : void
		{
			m_duration = 0;
			
			m_nStream.onMetaData = ProxyFunction.create(this, onMetaData);
			m_nStream['onCuePoint'] = ProxyFunction.create(this, onCuePoint);
			m_nStream.onStatus = ProxyFunction.create(this, onStreamStatusChange);
			
			m_loadingStartTime = getTimer ();
			m_nStream.play(source);
			pause ();
			clearInterval (m_checkBufferID);
			m_checkBufferID = setInterval (this, "checkBuffer", 50);
		}
		
		public function play (offset:Number) : void
		{
			if (offset === null)
			{
				offset = m_lastPosition;
			}
			m_nStream.seek(offset/1000);
			m_nStream.pause(false);
			m_isPlaying = true;
			if (m_nStream.bytesLoaded > 2000)
			{
				setBuffering(false);
			}
		}
		public function pause () : void
		{
			if (m_isPlaying)
			{
				m_lastPosition = m_nStream.time * 1000;
				m_isPlaying = false;
				m_nStream.pause(true);
			}
		}
		public function resume () : void
		{
			this.play (m_lastPosition);
		}
		public function stop () : void
		{
			m_lastPosition = 0;
			m_nStream.pause(true);
			m_nStream.seek(0);
			m_isPlaying = false;
		}
		
		public function isPlaying () : Boolean
		{
			return m_isPlaying;
		}
		
		public function setVolume (volume:Number) : void
		{
			if (volume > 100) volume = 100;
			else if (volume < 0) volume = 0;
			m_volume = volume;
			m_sound.setVolume(volume);
		}
		public function getVolume () : Number
		{
			return m_volume;
		}
		
		public function getBytesLoaded () : Number
		{
			return m_nStream.bytesLoaded;
		}
		public function getBytesTotal () : Number
		{
			return m_nStream.bytesTotal;
		}
		
		public function getWidth () : Number
		{
			return m_videoWidth;
		}
		public function getHeight () : Number
		{
			return m_videoHeight;
		}
		
		public function getDuration () : Number
		{
			return m_duration;
		}
		public function getDurationLoaded () : Number
		{
			if (m_duration === null) return null;
			return m_duration / m_nStream.bytesTotal * m_nStream.bytesLoaded;
		}
		
		public function getPosition () : Number
		{
			return m_nStream.time * 1000;
		}
		public function getLoadingTimeLeft () : Number
		{
			var loadingTime:Number = getTimer () - m_loadingStartTime;
			var timeLeft:Number = loadingTime / 
				m_nStream.bytesLoaded * m_nStream.bytesTotal - loadingTime;
			return timeLeft;
		}
		
		public function getPercentLoaded () : Number
		{
			if (m_nStream.bytesTotal < 50) return 0;
			return m_nStream.bytesLoaded * 100 / m_nStream.bytesTotal;
		}
		
		public function getMetaData() : Object
		{
			return m_metaData;
		}
		
		public function destroy () : void {
			clearInterval (m_checkBufferID);
			m_nStream.close();
			delete m_nStream;
			delete m_nConn;
			delete m_sound;
		}
		
		
		
		protected function checkBuffer () : void
		{
			if (!m_duration) {
				m_nStream.pause(true);
				return;
			}
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
				if (m_nStream.bufferLength < 0.01 && 
					m_nStream.time < m_duration / 1000 - 0.1)
				{
					setBuffering (true);
				}
			}
		}
		
		protected function onStreamStatusChange (status:Object) : void
		{
			if (status.level == 'error')
			{
				trace('f FLVPlayer Error: ' + status.code);
			}
			
			if (status.code == "NetStream.Play.Stop" && 
				m_nStream.time * 1000 > m_duration - 1500)
			{
				m_isPlaying = false;
				m_lastPosition = 0;
				dispatchEvent(new MediaEvent(
					MediaEvent.PLAYBACK_FINISH, true));
			}
		}
		protected function onMetaData (metaData:Object) : void
		{
			m_metaData = metaData;
			m_duration = metaData.duration * 1000;
			m_videoWidth = metaData.width;
			m_videoHeight = metaData.height;
			setBuffering(true);
			delete m_nStream.onMetaData;
			var event : MediaEvent = 
				new MediaEvent(MediaEvent.VIDEO_INITIALIZE, true);
			event.metaData = metaData;
			dispatchEvent(event);
		};
		protected function onCuePoint(cuePointData:Object) : void
		{
			var event : MediaEvent = 
				new MediaEvent(MediaEvent.CUE_POINT, true);
			event.cuePoint = cuePointData;
			dispatchEvent(event);
		};
		
		protected function setBuffering(buffering:Boolean) : void
		{
			//TODO: notify listeners of change
			if (buffering)
			{
				m_lastPosition = m_nStream.time * 1000;
				m_isBuffering = true;
				m_nStream.setBufferTime(10000);
				m_nStream.pause(true);
				m_sound.setVolume(0);
				dispatchEvent(new MediaEvent(MediaEvent.BUFFERING, true));
			}
			else
			{
				m_isBuffering = false;
				m_nStream.setBufferTime(0.1);
				if (m_isPlaying) {
					m_nStream.pause(false);
				}
				m_sound.setVolume(m_volume);
				dispatchEvent(new MediaEvent(
					MediaEvent.PLAYBACK_START, true));
			}
		}
	}
	
	
	
	
}