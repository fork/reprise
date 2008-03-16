/**
 * @author till
 */
package de.fork.css.math
{
	public class CSSCalculationGroup extends AbstractCSSCalculation
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const OPERATOR_PLUS : String = '+';
		public static const OPERATOR_MINUS : String = '-';
		public static const OPERATOR_MULTIPLY : String = '*';
		public static const OPERATOR_DIVIDE : String = '/';
		public static const OPERATOR_MODULO : String = 'mod';
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_operations : Object = initializeOperations();
		
		protected var m_operand1 : Object;
		protected var m_operand2 : Object;
		protected var m_operator : String;
		protected var m_operation : Function;
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function PrepareCalculation(
			expression : String) : CSSCalculationGroup
		{
			return parse(expression);
		}
	
		public function CSSCalculationGroup(
			operator : String, operand1 : Object, operand2 : Object)
		{
			setOperator(operator);
			m_operand1 = operand1;
			m_operand2 = operand2;
		}
	
		public function setOperand1(operand : Object) : void
		{
			m_operand1 = operand;
		}
		public function setOperand2(operand : Object) : void
		{
			m_operand2 = operand;
		}
		public function setOperator(operator : String) : void
		{
			m_operator = operator;
			m_operation = g_operations[operator];
		}
	
		public override function resolve(reference : Number) : Number
		{
			//TODO: we should probably profile this to see if it is efficent enough
			var operand1 : Number = (m_operand1 is Number ? m_operand1 as Number : 
				AbstractCSSCalculation(m_operand1).resolve(reference));
			var operand2 : Number = (m_operand2 is Number ? m_operand2 as Number : 
				AbstractCSSCalculation(m_operand2).resolve(reference));
			return m_operation(operand1, operand2);
		}
		public function toString() : String
		{
			return 'CSSCalculationGroup: operator ' + m_operator + 
				', operand1 (' + m_operand1.toString() + 
				'), operand2 (' + m_operand2.toString() + ')';
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected static function initializeOperations() : Object
		{
			var operations : Object = {};
			operations['+'] = operationPlus;
			operations['-'] = operationMinus;
			operations['*'] = operationMultiply;
			operations['/'] = operationDivide;
			operations['mod'] = operationModulo;
			operations['^'] = operationPow;
			return operations;
		}
		
		protected static function operationPlus(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 + operand2;
		}
		protected static function operationMinus(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 - operand2;
		}
		protected static function operationMultiply(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 * operand2;
		}
		protected static function operationDivide(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 / operand2;
		}
		protected static function operationModulo(
			operand1 : Number, operand2 : Number) : Number
		{
			return operand1 % operand2;
		}
		protected static function operationPow(
			operand1 : Number, operand2 : Number) : Number
		{
			return Math.pow(operand1, operand2);
		}
		
		
		
		protected static function parse(expression : String) : CSSCalculationGroup
		{
			var tokens : Array = tokenize(expression);
			var numeric : String = '0123456789x.';
			var ops : Array = [];
			var vals : Array = [];
			
			while(tokens.length)
			{
				var token : String = String(tokens.shift());
				switch (token)
				{
					case '(' :
					{
						ops.push(token);
						break;
					}
					case ')' :
					{
						while (ops[ops.length - 1] != '(')
						{
							reduce(ops, vals);
						}
						ops.pop();
						break;
					}
					case '^':
					case '*':
					case '/':
					case 'm':
					case '+':
					case '-':
					{
						if (ops[ops.length-1] != '(')
						{
							reduce(ops, vals);
						}
						ops.push(token);
						break;
					}
					default :
					{
						while(numeric.indexOf(tokens[0]) != -1)
						{
							token += String(tokens.shift());
						}
						if (tokens[0] == '%')
						{
							vals.push(new CSSCalculationRelativeValue(token));
							tokens.shift();
						}
						else
						{
							vals.push(parseFloat(token));
						}
					}
				}
			}
			return vals[0];
		}
		protected static function tokenize(expression : String) : Array
		{
			expression = addPrecedenceBraces(expression.split(' ').join(''));
			return expression.split('');
		}
		protected static function addPrecedenceBraces(exp : String) : String
		{
			exp = exp.split('(').join('((').split(')').join('))');
			//replace 'mod' operator with one-char-placeholder
			exp = exp.split('mod').join('m');
			var result : String = '(((';
			for (var i : Number = 0; i < exp.length; i++)
			{
				switch(exp.charAt(i))
				{
					case '^' : result += '^'; break;
					case '*' : result += ')*('; break;
					case '/' : result += ')/('; break;
					case 'm' : result += ')m('; break;
					case '+' : result += '))+(('; break;
					case '-' : result += '))-(('; break;
					default: result += exp.charAt(i);
				}
			}
			result += ')))';
			return result;
		}
		
		protected static function reduce(ops : Array, vals : Array) : void
		{
			var val1 : Number = vals[vals.length - 2];
			var val2 : Number = vals[vals.length - 1];
			vals.length -= 2;
			vals.push(new CSSCalculationGroup(String(ops.pop()), val1, val2));
		}
	}
}