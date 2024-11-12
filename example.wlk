class Empleado {
  const habilidades = []
  const subordinados = []  // que!!! (un empleado tiene subordinados??)
  
  var salud = 100     // lo inicializo con 100
  
  //var esJefe = false  // TA MAL, lo hago directamente pensando que si tiene subordinados, ya es jefe!!
  method esJefe() = subordinados.notEmpty()  // o subordinados.size() > 0   // una persona es jefe si tiene subordinados!!

  //method resolverMision(){}
  method saludCritica() // metodo abstracto
  
  // 1. Saber si un empleado está incapacitado.
  method quedaIncapacitado() = salud < self.saludCritica()
  
  // 2. Saber si un empleado puede usar una habilidad...
  method puedeUsar(habilidad) = not(self.quedaIncapacitado()) and self.poseeHabilidad(habilidad)
  
  method poseeHabilidad(habilidad) = habilidades.contains(habilidad) or (self.esJefe() and self.algunSubordinadoPuedeUsarHabilidad(habilidad)) 

  method algunSubordinadoPuedeUsarHabilidad(habilidad) = subordinados.any({x => x.puedeUsar(habilidad)})


}

class Espia inherits Empleado {

  //override method resolverMision() {
  //  self.aprenderHabilidad(nuevaHabilidad)
  //}

  method aprenderHabilidad(nuevaHabilidad) {
    habilidades.add(nuevaHabilidad)
  }

  override method saludCritica() = 15
}



class Oficinista inherits Empleado {
  var cantEstrellas = 0

  method sobreviveAUnaMision() {
    cantEstrellas += 1
  }

  override method saludCritica() = 40 - 5 * cantEstrellas
}




