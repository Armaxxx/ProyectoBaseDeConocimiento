change_value_class_relation(Clase,Relacion,NuevaClaseRelacionada,KB,NuevoKB):-
	quitar_relacion_clase(Clase,Relacion,KB,KBTemporal),
	agregar_relacion_clase(Clase,Relacion,NuevaClaseRelacionada,KBTemporal,NuevoKB).
change_value_object_relation(Objeto,Relacion,NuevoObjetoRelacionado,KB,NuevoKB):-
	quitar_relacion_objeto(Objeto,Relacion,KB,KBTemporal),
	agregar_relacion_objeto(Objeto,Relacion,NuevoObjetoRelacionado,KBTemporal,NuevoKB).
quitar_relacion_clase(Clase,not(Relacion),KB,NuevoKB) :-
	cambiarElemento(class(Clase,Madre,Propiedades,Relaciones,Objetos),class(Clase,Madre,Propiedades,NuevasRelaciones,Objetos),KB,NuevoKB),
	eliminarTodosLosElementosConLaMismaPropiedadNegada(Relacion,Relaciones,NuevasRelaciones).
quitar_relacion_clase(Clase,Relacion,KB,NuevoKB) :-
	cambiarElemento(class(Clase,Madre,Propiedades,Relaciones,Objetos),class(Clase,Madre,Propiedades,NuevasRelaciones,Objetos),KB,NuevoKB),
	eliminarTodosLosElementosConLaMismaPropiedad(Relacion,Relaciones,NuevasRelaciones).
agregar_relacion_clase(Clase,NuevaRelacion,OtraClase,KB,NuevoKB) :-
	cambiarElemento(class(Clase,Madre,Propiedades,Relaciones,Objetos),class(Clase,Madre,Propiedades,NuevasRelaciones,Objetos),KB,NuevoKB),
	adjuntar_relacion(Relaciones,NuevaRelacion,OtraClase,NuevasRelaciones).
adjuntar_relacion(Relaciones,not(NuevaRelacion),OtraClase,NuevasRelaciones):-
	append(Relaciones,[not(NuevaRelacion=>OtraClase)],NuevasRelaciones).
adjuntar_relacion(Relaciones,NuevaRelacion,OtraClase,NuevasRelaciones):-
	append(Relaciones,[NuevaRelacion=>OtraClase],NuevasRelaciones).
quitar_relacion_objeto(Objeto,not(Relacion),KB,NuevoKB) :-
	cambiarElemento(class(Clase,Madre,Propiedades,Relaciones,Objetos),class(Clase,Madre,Propiedades,Relaciones,NuevosObjetos),KB,NuevoKB),
	esElemento([id=>Objeto,Propiedades,Relaciones],Objetos),
	cambiarElemento([id=>Objeto,Propiedades,Relaciones],[id=>Objeto,Propiedades,NuevasRelaciones],Objetos,NuevosObjetos),
	eliminarTodosLosElementosConLaMismaPropiedadNegada(Relacion,Relaciones,NuevasRelaciones).
quitar_relacion_objeto(Objeto,Relacion,KB,NuevoKB) :-
	cambiarElemento(class(Clase,Madre,Propiedades,Relaciones,Objetos),class(Clase,Madre,Propiedades,Relaciones,NuevosObjetos),KB,NuevoKB),
	esElemento([id=>Objeto,Propiedades,Relaciones],Objetos),
	cambiarElemento([id=>Objeto,Propiedades,Relaciones],[id=>Objeto,Propiedades,NuevasRelaciones],Objetos,NuevosObjetos),
	eliminarTodosLosElementosConLaMismaPropiedad(Relacion,Relaciones,NuevasRelaciones).
agregar_relacion_objeto(Objeto,NuevaRelacion,OtroObjeto,KB,NuevoKB) :-
	cambiarElemento(class(Clase,Madre,Propiedades,Relaciones,Objetos),class(Clase,Madre,Propiedades,Relaciones,NuevosObjetos),KB,NuevoKB),
	esElemento([id=>Objeto,Propiedades,Relaciones],Objetos),
	cambiarElemento([id=>Objeto,Propiedades,Relaciones],[id=>Objeto,Propiedades,NuevasRelaciones],Objetos,NuevosObjetos),
	adjuntar_relacion(Relaciones,NuevaRelacion,OtroObjeto,NuevasRelaciones).
cambiarElemento(_,_,[],[]).
cambiarElemento(X,Y,[X|T],[Y|N]):-
	cambiarElemento(X,Y,T,N).
cambiarElemento(X,Y,[H|T],[H|N]):-
	cambiarElemento(X,Y,T,N).