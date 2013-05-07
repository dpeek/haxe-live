import hscript.Parser;
import hscript.Interp;

class Live
{
	var parser:Parser;
	var interp:Interp;
	var script:String;
	var methods:Dynamic;

	public function new()
	{
		parser = new Parser();
		interp = new Interp();
		methods = {};

		interp.variables.set("trace", function(m){ trace(m); });
		interp.variables.set("getProperty", Reflect.getProperty);
		interp.variables.set("setProperty", Reflect.setProperty);
		interp.variables.set("callMethod", Reflect.callMethod);

		load();

		#if sys
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);
		#end
	}

	var counter = 0;
	function update(_)
	{
		counter++;
		if (counter > 30)
		{
			counter = 0;
			load();
		}
	}

	function load()
	{
		var url = "../../script.hs";
		
		#if (flash || js)
		url += "?r="+Math.round(Math.random()*10000000);

		var http = new haxe.Http(url);
		http.onData = function(data) {
			parse(http.responseData);
			haxe.Timer.delay(load, 500);
		}
		http.onError = function(data) {
			parse(http.responseData);
			haxe.Timer.delay(load, 500);
		}
		http.request();
		#end

		#if sys
		url = "../../../../" + url;
		var data = sys.io.File.getContent(url);
		parse(data);
		#end
	}

	function parse(data:String)
	{
		if (data == script) return;
		script = data;
		// trace("parse: " + data);

		var program = parser.parseString(script);
		methods = interp.execute(program);
	}

	public function call(instance:Dynamic, method:String, args:Array<Dynamic>)
	{
		if (Reflect.field(methods, method) == null) return;
		interp.variables.set("this", instance);
		Reflect.callMethod(instance, Reflect.field(methods, method), args);
	}
}