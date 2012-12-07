package
{

	import flash.desktop.NativeApplication;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import qnx.display.Display;
	import qnx.events.NetworkErrorEvent;
	import qnx.events.WebViewEvent;
	import qnx.fuse.ui.buttons.LabelButton;
	import qnx.fuse.ui.text.Label;
	import qnx.media.QNXStageWebView;
	import qnx.system.AudioManager;
	import qnx.system.QNXSystemPowerMode;
	
	public class x929 extends Sprite
	{
		
		public var myBG:Sprite = new Sprite();
		public var myBGBar:Sprite = new Sprite();
		public var myWidth:uint = new uint();
		public var myHeight:uint = new uint();
		public var fSize:uint = 0;
		public var myBrowser:QNXStageWebView = new QNXStageWebView("myBrowser");
		public var myBrowserOver:QNXStageWebView = new QNXStageWebView("myBrowserOver");		
		public var myURL:String = "http://www.x929.ca/listenlive.php";
		public var myURLBlog:String = "http://www.x929.ca/shows/xblog";
		
		public var lTimer:Timer = new Timer(250);		
		public var myArea:Rectangle = new Rectangle(0,0,300,1280);

		public var myTextStr:Label = new Label();
		public var myVis:uint = 7;
		public var mySize:uint = 40; 
		
		public var goBack:LabelButton = new LabelButton();
		public var goMute:LabelButton = new LabelButton();
		public var isMute:Boolean = false;
		
		
		[SWF(height="1024", width="1280", frameRate="60", backgroundColor="#333333")]
		public function x929()
		{
			super();									
			init();
			load();
		}
		public function load():void {
			trace("Loading url (both audio and blog).");
			myBrowser.loadURL(myURL);
			myBrowserOver.loadURL(myURLBlog);
			lTimer.start();
			setText();
		}
		
		public function rotateDisplay(e:StageOrientationEvent):void {
			switch (Display.display.getDisplayWidth(0)) {
				case Display.display.getDisplayWidth(0) < Display.display.getDisplayHeight(0) :
					trace("Portrait"); 
					break;
				case Display.display.getDisplayWidth(0) > Display.display.getDisplayHeight(0) :
					trace("Landscape"); 
					break;
				case Display.display.getDisplayWidth(0) == Display.display.getDisplayHeight(0) :
					trace("Equal"); 
					break;				
			}
			trace("Regardless, updating image size.");
			myWidth = Display.display.getDisplayWidth(0);
			myHeight = Display.display.getDisplayHeight(0);
			
			//myBrowser.viewPort = new Rectangle(0,0,myWidth,myHeight);
			//myBrowser.zoom = 2;			
			//myBrowser.viewPort = myArea;
			myBrowser.viewPort = new Rectangle(0,0,myWidth,myHeight-10);
			myBrowserOver.viewPort = new Rectangle(0,0,myWidth,myHeight-10);
			myBrowserOver.zoomToFitWidthOnLoad = true;
			//flash.geom.* 
			//import flash.display.* 
			
			var matr:Matrix = new Matrix(); 
			matr.createGradientBox(20, 20, 0, 0, 0); 
			myBG.graphics.clear();
			myBG.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x222222], [1, 1], [0x00, 0xFF], matr, SpreadMethod.PAD); 			
			myBG.graphics.drawRect(0,0,myWidth,myHeight);
			myBG.graphics.endFill();
						
			myBGBar.y = myHeight-10;
			
			myTextStr.width = myWidth;
			myTextStr.y = myHeight - fSize - 10;
			myTextStr.x = 0;


		}
		
		public function init():void {
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			

			qnx.system.QNXSystem.system.inactivePowerMode = QNXSystemPowerMode.THROTTLED; // sets how the PB works when off
			qnx.system.QNXSystem.system.powerMode = QNXSystemPowerMode.NORMAL; // normal running state
			flash.desktop.NativeApplication.nativeApplication.systemIdleMode = "keepAwake";				
			
			//stage.addChild(myBG);
			stage.addChild(myBGBar);
			stage.addChild(myTextStr);
			stage.addChild(goBack);
			stage.addChild(goMute);
				
			myBrowser.zOrder = -1;
			myBrowserOver.zOrder = -1;
			
			myBrowserOver.enableCookies = true;
			myBrowserOver.enablePlugins = true;
			myBrowserOver.enableJavaScript = true;
			myBrowserOver.enableWebSockets = true;
			myBrowserOver.zoomToFitWidthOnLoad = true;
			myBrowserOver.userAgent = "Mozilla/5.0 (Windows NT 5.1; rv:15.0) Gecko/20100101 Firefox/13.0.1";

			myBrowser.enableCookies = true;
			myBrowser.enablePlugins = true;
			myBrowser.enableJavaScript = true;
			myBrowser.enableWebSockets = true;
			myBrowser.zoomToFitWidthOnLoad = true;
			myBrowser.userAgent = "Mozilla/5.0 (Windows NT 5.1; rv:15.0) Gecko/20100101 Firefox/13.0.1";

			myBrowserOver.loadStringWithBase("<body bgcolor='#000000'><center><h1><font color='#FFFFFF' family='arial'>Please wait..." + "</font></h1></center></body>","http://loading.com");

			myBrowserOver.addEventListener("error",networkError);
			myBrowserOver.addEventListener(WebViewEvent.DOCUMENT_LOAD_FAILED, goFail);
			myBrowserOver.addEventListener(WebViewEvent.DOCUMENT_LOAD_FINISHED,goFull);			
			myBrowserOver.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE,rotateDisplay);
			
			myBrowser.addEventListener("error",networkError);
			myBrowser.addEventListener(WebViewEvent.DOCUMENT_LOAD_FAILED, goFail);			
			myBrowser.addEventListener(WebViewEvent.DOCUMENT_LOAD_FINISHED, goFull);
			
			myWidth = Display.display.getDisplayWidth(0);
			myHeight = Display.display.getDisplayHeight(0);
			
			fSize = (Math.round(myHeight / 35))*2;
			
			// myBrowser.viewPort = new Rectangle(0,0,myWidth,myHeight-10);
			//myBrowser.viewPort = myArea;
//			myBrowserOver.viewPort = new Rectangle(0,0,myWidth,myHeight-10);
			myBrowser.viewPort = new Rectangle(0,0,myWidth,myHeight-10);
			myBrowserOver.viewPort = new Rectangle(0,0,myWidth,myHeight-10);

			//myBrowser.scrollBy(10,110);			
			
			var matr:Matrix = new Matrix(); 
			matr.createGradientBox(20, 20, 0, 0, 0); 
			myBG.graphics.clear();
			myBG.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x222222], [1, 1], [0x00, 0xFF], matr, SpreadMethod.PAD); 			
			myBG.graphics.drawRect(0,0,myWidth,myHeight);
			myBG.graphics.endFill();
			
			myBGBar.y = myHeight-10;

			var textTimer:Timer = new Timer(14000);
			textTimer.addEventListener(TimerEvent.TIMER,fadeText);			
			textTimer.start();

			myTextStr.width = myWidth;
			myTextStr.y = myHeight - fSize - 10;
			myTextStr.x = 0;
			myTextStr.height = fSize + 5;

			lTimer.addEventListener(TimerEvent.TIMER,goLoaderBar);
			
			goBack.alpha= 0.50
			goBack.setPosition(5, 5);
			goBack.label = "Back";
			goBack.setActualSize(mySize * 3, mySize * 1.5);
			goBack.addEventListener(MouseEvent.CLICK,goBackBtn);
			
			goMute.alpha= 0.50
			goMute.setPosition(5, 5 + (mySize * 1.5) + 5);
			goMute.label = "Mute";
			goMute.setActualSize(mySize * 3, mySize * 1.5);
			goMute.addEventListener(MouseEvent.CLICK,goMuteBtn);
		}
		
		
		public function goMuteBtn(e:MouseEvent):void {
			trace("User pressed back.");
			var aM:AudioManager = new AudioManager();
			
			if (isMute==false) {
				trace("Muting");		
				isMute = true;				
				goMute.label = "Unmute";
			}
			else
			{
				isMute = false;
				trace ("Unmuting");	
				goMute.label = "Mute";
			}
			aM.setOutputMute(isMute);
		}
		
		public function goBackBtn(e:MouseEvent):void {
			trace("User pressed back.");
			myBrowserOver.historyBack();
		}
		
		public function fadeText(e:TimerEvent):void {			
			trace("Fading text.");

			trace(e.target);
			e.target.stop();				
			
			var hTimer:Timer = new Timer(50);
			hTimer.addEventListener(TimerEvent.TIMER,hideText);
			hTimer.start();
		}
		public function setText():void {			
			trace("Setting text.");
			var myFormat:TextFormat = new TextFormat();
			
			myFormat.bold = true;
			myFormat.size = fSize;
			myFormat.color = 0x999999;
			
			myTextStr.format = myFormat;
			myTextStr.text = "Buffering...";
			
		}
		public function hideText(e:TimerEvent):void {
			trace("Hiding text.");
			if (myVis >0) {
				myVis = myVis - 0.25;
				myTextStr.alpha = (myVis/10);
			}
			else
			{
				stage.removeChild(myTextStr);
				trace(e.target);
				e.target.stop();				
			}			
		}
		
		public function goLoaderBar(e:TimerEvent):void {

				
			myBrowser.stage = stage;
			myBrowserOver.stage = stage;

			var matr:Matrix = new Matrix(); 
			matr.createGradientBox(320, 150, 0, 0, 0); 
			myBGBar.graphics.clear();
			myBGBar.graphics.beginFill(0x777777);
			myBGBar.graphics.drawRect(0,0,myWidth,10);
			myBGBar.graphics.endFill();

			if (myBrowserOver.loadProgress < 100) {
				myBGBar.graphics.beginGradientFill(GradientType.LINEAR, [0x990000, 0x440000], [1, 1], [0x00, 0xFF], matr, SpreadMethod.PAD); 			
				myBGBar.graphics.drawRect(0,0,(myBrowserOver.loadProgress/100)*myWidth,5);
				myBGBar.graphics.endFill();
			} else {
				myBGBar.graphics.beginFill(0x333333);
				myBGBar.graphics.drawRect(0,0,myWidth,5);
				myBGBar.graphics.endFill();
			}
			if (myBrowser.loadProgress < 100) {
				myBGBar.graphics.beginGradientFill(GradientType.LINEAR, [0x990000, 0x440000], [1, 1], [0x00, 0xFF], matr, SpreadMethod.PAD); 			
				myBGBar.graphics.drawRect(0,5,(myBrowser.loadProgress/100)*myWidth,5);
				myBGBar.graphics.endFill();
			} else {
				myBGBar.graphics.beginFill(0x333333);
				myBGBar.graphics.drawRect(0,5,myWidth,5);
				myBGBar.graphics.endFill();
			}
			//mySwv.loadProgress
		}
		
		public function goFull(e:WebViewEvent):void {
			
			trace("Website has loaded.. " + e.target.location);
			//myBrowserOver.fullscreenClientGet();
			
		}
		public function networkError(e:NetworkErrorEvent):void {
			trace("Error occurred: " + e);
		}
		public function goFail(e:WebViewEvent):void {
			trace("View failed: " + e);
			myBrowserOver.loadStringWithBase("<body bgcolor='#000000'><br><br><br><br><br><br><br><br><br><h1><font color='#FFFFFF'>This application requires internet access.</font></h1></body>","http://error.com");			
		}
			
	}
}