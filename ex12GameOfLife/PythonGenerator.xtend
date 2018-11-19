package game.life.generator

import game.life.dsl.Rules

class PythonGenerator {

	def static toPy(Rules root) {
		'''
		#rulesoflife.py
		«"\n"»
		«"\n"»
		def apply_rules(current_value, total, on_value, off_value): «"\n"»
		«"\t"»if current_value == on_value: «"\n"»
		«"\t"»«"\t"»if total < «root.small» or total > «root.big»: «"\n"»
		«"\t"»«"\t"»«"\t"»return off_value «"\n"»
		«"\t"»else: «"\n"»
		«"\t"»«"\t"»if total == «root.birth»: «"\n"»
		«"\t"»«"\t"»«"\t"»return on_value «"\n"»
		«"\t"»return current_value «"\n"»
		'''
	}
	
}