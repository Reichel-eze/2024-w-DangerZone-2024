class Empleado {
  var property puesto          // puede ser un espia o un oficinista por ahora (COMPOSICION)
  var salud = 100     // lo inicializo con 100

  const habilidades = #{}  // para que no se repitan habilidades (un set en vez de una lista)

  //const subordinados = []  // que!!! (un empleado tiene subordinados??)
  //var esJefe = false  // TA MAL, lo hago directamente pensando que si tiene subordinados, ya es jefe!!
  //method esJefe() = subordinados.notEmpty()  // o subordinados.size() > 0   // una persona es jefe si tiene subordinados!!

  method aprenderHabilidad(nuevaHabilidad) {
    habilidades.add(nuevaHabilidad)
  }

  method saludCritica() = puesto.saludCritica()   // le paso la pelota al puesto..
  
  // 1. Saber si un empleado está incapacitado.
  method estaIncapacitado() = salud < self.saludCritica()
  
  // 2. Saber si un empleado puede usar una habilidad...
  method puedeUsar(habilidad) = not(self.estaIncapacitado()) and self.poseeHabilidad(habilidad)
  
  method poseeHabilidad(habilidad) = habilidades.contains(habilidad) // que el empleado contenga la habilidad

  method recibirDanio(cantidad) { salud -= cantidad }

  method finalizarMision(mision) {
    if (self.estaVivo()){
      self.completarMision(mision)
    }//else throw new DomainException(message="Un Empleado NO esta vivo")
      
  }

  method estaVivo() = salud > 0

  method completarMision(mision) { puesto.completarMision(mision, self) }  // le paso la pelota al puesto.. (polimorfismo)

}

// ------------- JEFE HEREDA DEL EMPLEADO ---------------------------------------
class Jefe inherits Empleado {
  const subordinados = [] // el jefe tiene subordinados
  
  override method poseeHabilidad(habilidad) = super(habilidad) or self.algunSubordinadoPuedeUsarHabilidad(habilidad)  // si el jefe tiene la habilidad o algun subordinado la pueda usar
  
  method algunSubordinadoPuedeUsarHabilidad(habilidad) = subordinados.any({x => x.puedeUsar(habilidad)})
}

// ----------  PUESTOS DE TRABAJO  ---------------
object puestoEspia {    // puede ser un objeto porque todos los puestos espias tienen 15 de salud critica y NO tiene estado interno

  method saludCritica() = 15

  method completarMision(mision, empleado) {  // me traje al empleado como parametro porque lo necesitaba
    mision.enseniarHabilidades(empleado)      // le paso la pelota a la mision.. con el empleado
  }

}

class PuestoOficinista {    // class porque tiene estado interno (la cantidad de estrellas puede ser diferente para cada puesto oficinista)
  var cantEstrellas = 0

  method saludCritica() = 40 - 5 * cantEstrellas

  method completarMision(mision, empleado) {
    self.conseguirUnaEstrella()
    if(cantEstrellas == 3) {
      empleado.puesto(puestoEspia)  // Cuando un oficinista junta tres estrellas adquiere la suficiente experiencia como para empezar a trabajar de espía.
    }
  }

  method conseguirUnaEstrella() {
    cantEstrellas += 1
  }

}

// PUNTO 3: Hacer que un empleado o un equipo cumpla una misión.
class Mision {
  var peligrosidad
  const property habilidadesRequeridas = []

  // mision.serCumplidaPor(empleado)
  // mision.serCumplidaPor(equipo)

  method serCumplidaPor(asignado){
    self.validarHabilidades(asignado)
    asignado.recibirDanio(peligrosidad)
    asignado.finalizarMision(self)
  }

  method validarHabilidades(asignado) {
    if(!self.reuneHabilidadesRequeridas(asignado)){ // si no puede cumplir la mision (es decir, NO reune las habilidades req) lanzo una excepcion!! 
      throw new DomainException(message="La mision NO se puede cumplir")
    }
  }

  // Quien la cumple reúne todas las habilidades requeridas de la misma (si puede usarlas todas). 
  method reuneHabilidadesRequeridas(asignado) = habilidadesRequeridas.all({habilidad => asignado.puedeUsar(habilidad)})  

  method enseniarHabilidades(empleado) {
    self.habilidadesQueNoPosee(empleado).forEach({habilidad => empleado.aprenderHabilidad(habilidad)})
  }

  method habilidadesQueNoPosee(empleado) = habilidadesRequeridas.filter({habilidad => not(empleado.poseeHabilidad(habilidad))})

}

class Equipo {
  const empleados = []

  // Para los equipos alcanza con que al menos uno de sus integrantes pueda usar cada una de ellas.
  method puedeUsar(habilidad) = empleados.any({empleado => empleado.puedeUsar(habilidad)})

  // Para los equipos, esto implica que todos los integrantes reciban un tercio del daño total.
  method recibirDanio(cantidad) {
    empleados.forEach({empleado => empleado.recibirDanio(cantidad / 3)})
  }

  // Esto no lo pone el enunciado, pero es logico
  method finalizarMision(mision) {
    empleados.forEach({empleado => empleado.finalizarMision(mision)}) // simplemente es que cada empleado finalice la mision
  }

}