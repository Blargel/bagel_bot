# encoding: utf-8

require 'cinch'
require 'dentaku'

class Calc
  include Cinch::Plugin

  match(/calc(?:$|(?: (.+)?))/)
  def execute(m, expr)
    if expr.nil?
      m.reply("#{m.user.nick}: Give me a mathematical expression to evaluate.")
      return
    end

    result = nil
    begin
      calculator = Dentaku::Calculator.new
      result = calculator.evaluate(expr)
      result = result.to_f if result.kind_of?(BigDecimal)
      result ||= "No result."
    rescue => e
      case e
      when Dentaku::ZeroDivisionError
        result = "Error - Attempted to divide by zero."
      when Dentaku::ParseError, Dentaku::TokenizerError, Dentaku::ArgumentError
        result = "Error - Failed to parse query."
      else
        m.reply("#{m.user.nick}: Error - Blargel is a scrub at programming!")
        raise e
      end
    end
    m.reply("#{m.user.nick}: #{result}")
  end
end
