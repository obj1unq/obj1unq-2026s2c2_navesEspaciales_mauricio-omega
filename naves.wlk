/*
 * justificación:
 * Creé la superclase abstracta Nave porque NaveDeCarga, NaveDePasajeros y
 * NaveDeCombate comparten el atributo velocidad y el mensaje recibirAmenaza().
 * - Evito repetir velocidad en tres clases: queda en un solo lugar, y si
 *   hay que validar o hacer algo con velocidad, se cambia únicamente en Nave.
 * - Toda nave tiene velocidad, así que Nave centraliza ese concepto del dominio.
 * - recibirAmenaza() es abstracto: cada subclase define su propio protocolo.
 * - El resto del comportamiento (sobrecargada, velocidadMaximaPermitida,
 *   estaInvisible, etc.) es específico de cada tipo y queda en su clase.
 */
class Nave {
	var property velocidad = 0
	
	method recibirAmenaza()
	
	method propulsar() {
		self.aumentarVelocidad(self.aumentoVelocidadDePropulsion())
	}
	
	method prepararParaViajar() {
		self.aumentarVelocidad(self.aumentoVelocidadParaViajar())
	}
	
	method aumentarVelocidad(incremento) {
		velocidad += incremento.min((self.maximaVelocidadAlcanzable() - velocidad).max(0))
	}
	
	method aumentoVelocidadDePropulsion() = 20000
	method aumentoVelocidadParaViajar() = 15000
	method maximaVelocidadAlcanzable() = 300000
	
	method encontrarseConUnEnemigo(){
		self.recibirAmenaza()
		self.propulsar()
	}
}


class NaveDeCarga inherits Nave{

	var property carga = 0

	method sobrecargada() = carga > 100000

	method excedidaDeVelocidad() = velocidad > 100000

	override method recibirAmenaza() {
		carga = 0
	}
	
	method enFalta() = self.sobrecargada() and self.excedidaDeVelocidad()
	
	method acercamientoDeControl() {
		if (self.enFalta()) {
			self.recibirAmenaza()
		}
	}

}

class NaveDeResiduoRadioactivo inherits NaveDeCarga {

	var property selladoAlVacio = false

	override method recibirAmenaza() {
		velocidad = 0
	}
	
	override method prepararParaViajar() {
		selladoAlVacio = true
		super()
	}
}

class NaveDePasajeros inherits Nave{

	var property alarma = false
	const cantidadDePasajeros = 0

	method tripulacion() = cantidadDePasajeros + 4

	method velocidadMaximaPermitida() = 300000 / self.tripulacion() - if (cantidadDePasajeros > 100) 200 else 0

	method estaEnPeligro() = velocidad > self.velocidadMaximaPermitida() or alarma

	override method recibirAmenaza() {
		alarma = true
	}

}

class NaveDeCombate inherits Nave {

	var property modo = reposo
	const property mensajesEmitidos = []

	method emitirMensaje(mensaje) {
		mensajesEmitidos.add(mensaje)
	}
	
	method ultimoMensaje() = mensajesEmitidos.last()

	method estaInvisible() = velocidad < 10000 and modo.invisible()

	override method recibirAmenaza() {
		modo.recibirAmenaza(self)
	}

	override method prepararParaViajar() {
		modo.prepararParaViajar(self)
		super()
	}
}

object reposo {

	method invisible() = false

	method recibirAmenaza(nave) {
		nave.emitirMensaje("¡RETIRADA!")
	}
	
	method prepararParaViajar(nave) {
		nave.emitirMensaje("Saliendo en misión")
		nave.modo(ataque)
	}
}

object ataque {

	method invisible() = true

	method recibirAmenaza(nave) {
		nave.emitirMensaje("Enemigo encontrado")
	}
	
	method prepararParaViajar(nave) {
		nave.emitirMensaje("Volviendo a la base")
	}
}