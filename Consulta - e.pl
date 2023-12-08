properties_of_individual(Objeto, KB, Propiedades):-
    propiedades_de_objeto(Objeto, KB, Propiedades).
propiedades_de_objeto(Objeto, KB, TodasLasPropiedades):-
    existe_objeto(Objeto, KB, yes),
    propiedades_solo_en_objeto(Objeto, KB, PropiedadesObjeto),
    clase_de_un_objeto(Objeto, KB, Clase),
    class_properties(Clase, KB, PropiedadesClase),
    append(PropiedadesObjeto, PropiedadesClase, Temp),
    eliminar_propiedades_repetidas(Temp, TodasLasPropiedades).
propiedades_de_objeto(_, _, unknown).
propiedades_solo_en_objeto(_, [], []).
propiedades_solo_en_objeto(Objeto, [class(_, _, _, _, O)|_], Propiedades):-
    esElemento([id=>Objeto, Propiedades, _], O).
propiedades_solo_en_objeto(Objeto, [_|T], Propiedades):-
    propiedades_solo_en_objeto(Objeto, T, Propiedades).
concatenar_propiedades_de_ancestros([], _, []).
concatenar_propiedades_de_ancestros([Ancestro|T], KB, [Propiedades|NuevaT]):-
    concatenar_propiedades_de_ancestros(T, KB, NuevaT),
    propiedades_solo_en_la_clase(Ancestro, KB, Propiedades).
cancelar_propiedades_repetidas(X, Z):-
    concatenar_listas_de_listas(X, Y),
    eliminar_propiedades_repetidas(Y, Z).
eliminar_todos_elementos_con_la_misma_propiedad(_, [], []).
eliminar_todos_elementos_con_la_misma_propiedad(X, [X=>_|T], NuevaT):-
    eliminar_todos_elementos_con_la_misma_propiedad(X, T, NuevaT).
eliminar_todos_elementos_con_la_misma_propiedad(X, [H|T], NuevaT):-
    eliminar_todos_elementos_con_la_misma_propiedad(X, T, NuevaT),
    X \= H.
eliminar_todos_elementos_con_la_misma_propiedad_negada(_, [], []).
eliminar_todos_elementos_con_la_misma_propiedad_negada(X, [not(X=>_)|T], NuevaT):-
    eliminar_todos_elementos_con_la_misma_propiedad_negada(X, T, NuevaT).
eliminar_todos_elementos_con_la_misma_propiedad_negada(X, [H|T], NuevaT):-
    eliminar_todos_elementos_con_la_misma_propiedad_negada(X, T, NuevaT),
    X \= not(X=>H).
concatenar_listas_de_listas([], []).
concatenar_listas_de_listas([Lista|Resto], Concatenadas):-
    append(Lista, ListaConcatenada, Concatenadas),
    concatenar_listas_de_listas(Resto, ListaConcatenada).