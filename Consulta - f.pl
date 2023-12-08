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
    relaciones_del_objeto(Objeto,KB,Relaciones),
    expandir_clases_a_objetos(Relaciones,RelacionesExpandidas,KB).
relations_of_individual(_,_,unknown).

expandir_clases_a_objetos([],[],_).
expandir_clases_a_objetos([no(X=>Y)|T],[no(X=>Objetos)|NuevaT],KB):-
    existe_clase(Y,KB,yes),
    objetos_de_clase(Y,KB,Objetos),
    expandir_clases_a_objetos(T,NuevaT,KB).
expandir_clases_a_objetos([X=>Y|T],[X=>Objetos|NuevaT],KB):-
    existe_clase(Y,KB,yes),
    objetos_de_clase(Y,KB,Objetos),
    expandir_clases_a_objetos(T,NuevaT,KB).
expandir_clases_a_objetos([no(X=>Y)|T],[no(X=>[Y])|NuevaT],KB):-
    expandir_clases_a_objetos(T,NuevaT,KB).
expandir_clases_a_objetos([X=>Y|T],[X=>[Y]|NuevaT],KB):-
    expandir_clases_a_objetos(T,NuevaT,KB).

relaciones_del_objeto(Objeto,KB,TodasLasRelaciones):-
    existe_objeto(Objeto,KB,yes),
    solo_relaciones_en_el_objeto(Objeto,KB,RelacionesEnElObjeto),
    clase_de_objeto(Objeto,KB,Clase),
    class_relations(Clase,KB,RelacionesDeClase),
    append([RelacionesEnElObjeto],[RelacionesDeClase],Temp),
    eliminar_propiedades_repetidas(Temp,TodasLasRelaciones).
relaciones_del_objeto(_,_,unknown).

solo_relaciones_en_el_objeto(_,[],[]).
solo_relaciones_en_el_objeto(Objeto,[clase(_,_,_,_,O)|_],Relaciones):-
    esElemento([id=>Objeto,_,Relaciones],O).
solo_relaciones_en_el_objeto(Objeto,[_|T],Relaciones):-
    solo_relaciones_en_el_objeto(Objeto,T,Relaciones).
