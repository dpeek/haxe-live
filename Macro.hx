import haxe.macro.*;
import haxe.macro.Expr;
using haxe.macro.Tools;
using Lambda;

class Macro
{
	public static function build()
	{
		var methods = [];
		var fields = Context.getBuildFields();

		for (field in fields)
		{
			if (field.meta.exists(function(m){return m.name=="live";}))
			{
				switch (field.kind)
				{
					case FFun(f):
						var name = field.name;
						var args = f.args.map(function(a){ return a.name; }).join(",");
						var expr = f.expr.map(processExpr);
						var body = expr.toString();
						methods.push('$name:function($args)$body');
						f.expr = macro live.call(this, "update", [_]);
					case _:
				}
			}
		}

		// static init causes issues with nme
		// var liveExpr = macro new Live();
		// var live = {name:"live", pos:Context.currentPos(), meta:[], doc:null, access:[AStatic], kind:FVar(null, liveExpr)};
		// fields.push(live);

		var script = "{"+methods.join(",")+"}";
		sys.io.File.saveContent("bin/script.hs", script);

		return fields;
	}

	static function processExpr(expr:Expr):Expr
	{
		return switch (expr.expr)
		{
			case EBinop(OpAssign, e1, e2):
				getSetter(e1, processExpr(e2));
			case EField(e, field):
				e = processExpr(e);
				var prop = Context.makeExpr(field, expr.pos);
				macro getProperty($e, $prop);
			case _: expr.map(processExpr);
		}
	}

	static function getSetter(expr:Expr, value:Expr):Expr
	{
		return switch (expr.expr)
		{
			case EField(e, field):
				e = processExpr(e);
				var prop = Context.makeExpr(field, expr.pos);
				macro setProperty($e, $prop, $value);
			case _:
				processExpr(expr);
		}
	}
}