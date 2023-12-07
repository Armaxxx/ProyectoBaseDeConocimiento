class_relations(top, KB, Relaciones):-
    relaciones_solo_en_clase(top, KB, Relaciones).
class_relations(Clase, KB, Relaciones):-
    existe_clase(Clase, KB, yes),
    relaciones_solo_en_clase(Clase, KB, RelacionesClase),
    append([RelacionesClase], RelacionesAncestros, TodasLasRelaciones),
    concatenar_relaciones_ancestros(Ancestros, KB, RelacionesAncestros),
    lista_de_ancestros(Clase, KB, Ancestros),
    cancelar_valores_propiedad_repetidos(TodasLasRelaciones, Relaciones).
class_relations(_, _, unknown).
relaciones_solo_en_clase(_, [], []).
relaciones_solo_en_clase(Clase, [class(Clase, _, _, Relaciones, _)|_], Relaciones).
relaciones_solo_en_clase(Clase, [_|T], Relaciones):-
    relaciones_solo_en_clase(Clase, T, Relaciones).
concatenar_relaciones_ancestros([], _, []).
concatenar_relaciones_ancestros([Ancestro|T], KB, [Relaciones|NuevoT]):-
    concatenar_relaciones_ancestros(T, KB, NuevoT),
    relaciones_solo_en_clase(Ancestro, KB, Relaciones).
concat_lista_de_listas([], []).
concat_lista_de_listas([H|T], X):-
    append(H, TLista, X),
    concat_lista_de_listas(T, TLista).
eliminarTodosLosElementosConLaMismaPropiedad(_, [], []).
eliminarTodosLosElementosConLaMismaPropiedad(X, [X=>_|T], N):-
    eliminarTodosLosElementosConLaMismaPropiedad(X, T, N).
eliminarTodosLosElementosConLaMismaPropiedad(X, [H|T], [H|N]):-
    eliminarTodosLosElementosConLaMismaPropiedad(X, T, N).
eliminarElemento(_, [], []).
eliminarElemento(X, [X|T], N):-
    eliminarElemento(X, T, N).
eliminarElemento(X, [H|T], [H|N]):-
    eliminarElemento(X, T, N),
    X\=H.
eliminarTodosLosElementosConLaMismaPropiedadNegada(_, [], []).
eliminarTodosLosElementosConLaMismaPropiedadNegada(X, [not(X=>_)|T], N):-
    eliminarTodosLosElementosConLaMismaPropiedadNegada(X, T, N).
eliminarTodosLosElementosConLaMismaPropiedadNegada(X, [H|T], [H|N]):-
    eliminarTodosLosElementosConLaMismaPropiedadNegada(X, T, N).



relations_of_individual(Objeto,KB,RelacionesExpandidas):-
    existe_objeto(Objeto,KB,yes),
    relaciones_de_objeto(Objeto,KB,Relaciones),
    expandir_clases_a_objetos(Relaciones,RelacionesExpandidas,KB).
relations_of_individual(_,_,unknown).
expandir_clases_a_objetos([],[],_).
expandir_clases_a_objetos([no(X=>Y)|T],[no(X=>Objetos)|NuevaT],KB):-
    existe_clase(Y,KB,yes),
    objetos_de_una_clase(Y,KB,Objetos),
    expandir_clases_a_objetos(T,NuevaT,KB).
expandir_clases_a_objetos([X=>Y|T],[X=>Objetos|NuevaT],KB):-
    existe_clase(Y,KB,yes),
    objetos_de_una_clase(Y,KB,Objetos),
    expandir_clases_a_objetos(T,NuevaT,KB).
expandir_clases_a_objetos([no(X=>Y)|T],[no(X=>[Y])|NuevaT],KB):-
    expandir_clases_a_objetos(T,NuevaT,KB).
expandir_clases_a_objetos([X=>Y|T],[X=>[Y]|NuevaT],KB):-
    expandir_clases_a_objetos(T,NuevaT,KB).
relaciones_de_objeto(Objeto,KB,TodasLasRelaciones):-
    existe_objeto(Objeto,KB,yes),
    solo_relaciones_en_el_objeto(Objeto,KB,RelacionesEnElObjeto),
    clase_de_un_objeto(Objeto,KB,Clase),
    relaciones_de_clase(Clase,KB,RelacionesDeClase),
    append([RelacionesEnElObjeto],[RelacionesDeClase],Temp),
    cancelar_valores_repetidos_de_propiedades(Temp,TodasLasRelaciones).
relaciones_de_objeto(_,_,unknown).
solo_relaciones_en_el_objeto(_,[],[]).
solo_relaciones_en_el_objeto(Objeto,[class(_,_,_,_,O)|_],Relaciones):-
    esElemento([id=>Objeto,_,Relaciones],O).
solo_relaciones_en_el_objeto(Objeto,[_|T],Relaciones):-
    solo_relaciones_en_el_objeto(Objeto,T,Relaciones).
objetos_de_una_clase(Clase,KB,Objetos):-
    existe_clase(Clase,KB,yes),
    solo_objetos_en_la_clase(Clase,KB,ObjetosEnLaClase),
    descendientes_de_una_clase(Clase,KB,Hijos),
    objetos_de_todas_las_clases_descendientes(Hijos,KB,ObjetosDescendientes),
    append(ObjetosEnLaClase,ObjetosDescendientes,Objetos).
objetos_de_una_clase(_,_,unknown).
objetos_de_todas_las_clases_descendientes([],_,[]).
objetos_de_todas_las_clases_descendientes([Clase|T],KB,TodosLosObjetos):-
    solo_objetos_en_la_clase(Clase,KB,Objetos),
    objetos_de_todas_las_clases_descendientes(T,KB,Resto),
    append(Objetos,Resto,TodosLosObjetos).
relaciones_de_clase(top,KB,Relaciones):-
    solo_relaciones_en_la_clase(top,KB,Relaciones).
relaciones_de_clase(Clase,KB,Relaciones):-
    existe_clase(Clase,KB,yes),
    solo_relaciones_en_la_clase(Clase,KB,RelacionesDeClase),
    append([RelacionesDeClase],RelacionesDeAncestros,RelacionesTotales),
    concatenar_relaciones_de_ancestros(Ancestros,KB,RelacionesDeAncestros),
    lista_de_ancestros(Clase,KB,Ancestros),
    cancelar_valores_repetidos_de_propiedades(RelacionesTotales,Relaciones).
relaciones_de_clase(_,_,unknown).
solo_relaciones_en_la_clase(_,[],[]).
solo_relaciones_en_la_clase(Clase,[class(Clase,_,_,Relaciones,_)|_],Relaciones).
solo_relaciones_en_la_clase(Clase,[_|T],Relaciones):-
    solo_relaciones_en_la_clase(Clase,T,Relaciones).
cancelar_valores_repetidos_de_propiedades(X,Z):-
    concatenar_lista_de_listas(X,Y),
    eliminar_propiedades_repetidas(Y,Z).
solo_objetos_en_la_clase(_,[],unknown).
solo_objetos_en_la_clase(Clase,[class(Clase,_,_,_,O)|_],Objetos):-
    extraer_nombres_de_objetos(O,Objetos).
solo_objetos_en_la_clase(Clase,[_|T],Objetos):-
    solo_objetos_en_la_clase(Clase,T,Objetos).
hijos_de_una_lista_de_clases([],_,[]).
hijos_de_una_lista_de_clases([Hijo|T],KB,Nietos):-
	hijos_de_una_clase(Hijo,KB,Hijos),
	hijos_de_una_lista_de_clases(T,KB,Primos),
	append(Hijos,Primos,Nietos).
sons_of_class(Class,KB,Answer):-
	existe_clase(Class,KB,yes),
	hijos_de_una_clase(Class,KB,Answer).
todos_los_descendientes_de_una_clase([],_,[]).
todos_los_descendientes_de_una_clase(Clases,KB,Descendientes):-
    hijos_de_una_lista_de_clases(Clases,KB,Hijos),
    todos_los_descendientes_de_una_clase(Hijos,KB,RestoDeDescendientes),
    append(Clases,RestoDeDescendientes,Descendientes).
concatenar_lista_de_listas([],[]).
concatenar_lista_de_listas([H|T],X):-
    append(H,TLista,X),
    concatenar_lista_de_listas(T,TLista).