valor_relacion_clase(Clase, Relacion, KB, Valor) :-
    existe_clase(Clase, KB, yes),
    relations_extension(Clase, KB, Relaciones),
    encontrar_valor_relacion(Relacion, Relaciones, Valor).
valor_relacion_clase(_, _, _, unknown).
encontrar_valor_relacion(not(Relacion), Relaciones, Valor) :-
    encontrar_valor_relacion_negativa(Relacion, Relaciones, Valor).
encontrar_valor_relacion(Relacion, Relaciones, Valor) :-
    encontrar_valor_relacion_positiva(Relacion, Relaciones, Valor).
encontrar_valor_relacion_negativa(_, [], unknown).
encontrar_valor_relacion_negativa(Atributo, [not(Atributo => Valor) | _], Valor).
encontrar_valor_relacion_negativa(Atributo, [_ | T], Valor) :-
    encontrar_valor_relacion_negativa(Atributo, T, Valor).
encontrar_valor_relacion_positiva(_, [], unknown).
encontrar_valor_relacion_positiva(Atributo, [Atributo => Valor | _], Valor).
encontrar_valor_relacion_positiva(Atributo, [_ | T], Valor) :-
    encontrar_valor_relacion_positiva(Atributo, T, Valor).
hijos_de_clase(Clase, KB, Respuesta) :-
    existe_clase(Clase, KB, yes),
    hijos_de_una_clase(Clase, KB, Respuesta).
hijos_de_clase(_, _, unknown).
relations_extension(top, KB, Relaciones) :-
    relaciones_solo_en_la_clase(top, KB, Relaciones).
relations_extension(Clase, KB, Relaciones) :-
    existe_clase(Clase, KB, yes),
    relaciones_solo_en_la_clase(Clase, KB, RelacionesClase),
    append([RelacionesClase], RelacionesAncestros, TodasLasRelaciones),
    concatenar_relaciones_de_ancestros(Ancestros, KB, RelacionesAncestros),
    lista_de_ancestros(Clase, KB, Ancestros),
    eliminar_propiedades_repetidas(TodasLasRelaciones, Relaciones).
relations_extension(_, _, unknown).
relaciones_solo_en_la_clase(_, [], []).
relaciones_solo_en_la_clase(Clase, [class(Clase, _, _, Relaciones, _) | _], Relaciones).
relaciones_solo_en_la_clase(Clase, [_ | T], Relaciones) :-
    relaciones_solo_en_la_clase(Clase, T, Relaciones).
concatenar_listas([], []).
concatenar_listas([H | T], X) :-
    append(H, TLista, X),
    concatenar_listas(T, TLista).
eliminar_propiedad_repetida([], []).
eliminar_propiedad_repetida([P => V | T], [P => V | NuevaT]) :-
    eliminar_elemento(P => V, T, L1),
    eliminar_propiedad_repetida(L1, NuevaT).
eliminar_propiedad_repetida([not(P => V) | T], [not(P => V) | NuevaT]) :-
    eliminar_elemento(not(P => V), T, L1),
    eliminar_elemento(P => V, L1, L2),
    eliminar_propiedad_repetida(L2, NuevaT).
eliminar_propiedad_repetida([not(H) | T], [not(H) | NuevaT]) :-
    eliminar_elemento(not(H), T, L1),
    eliminar_elemento(H, L1, L2),
    eliminar_propiedad_repetida(L2, NuevaT).
eliminar_propiedad_repetida([H | T], [H | NuevaT]) :-
    eliminar_elemento(H, T, L1),
    eliminar_elemento(not(H), L1, L2),
    eliminar_propiedad_repetida(L2, NuevaT).
todas_descendientes_de_una_clase([], _, []).
todas_descendientes_de_una_clase(Clases, KB, Descendientes) :-
    hijos_de_lista_de_clases(Clases, KB, Hijos),
    todas_descendientes_de_una_clase(Hijos, KB, RestoDescendientes),
    append(Clases, RestoDescendientes, Descendientes).
hijos_de_lista_de_clases([], _, []).
hijos_de_lista_de_clases([Hijo | T], KB, Nietos) :-
    hijos_de_una_clase(Hijo, KB, Hijos),
    hijos_de_lista_de_clases(T, KB, Sobrinos),
    append(Hijos, Sobrinos, Nietos).
