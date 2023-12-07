valor_propiedad_clase(Clase, Propiedad, KB, Valor):-
    propiedades_clase(Clase, KB, PropiedadesClase),
    encontrar_valor(Propiedad, PropiedadesClase, Valor).
encontrar_valor(_, [], unknown).
encontrar_valor(Atributo, [Atributo=>Valor|_], Valor).
encontrar_valor(Atributo, [not(Atributo)|_], no).
encontrar_valor(Atributo, [Atributo|_], yes).
encontrar_valor(Atributo, [_|T], Valor):-
    encontrar_valor(Atributo, T, Valor).
extraer_nombres_objetos([], []).
extraer_nombres_objetos([[id=>Nombre, _, _]|T], Objetos):-
    extraer_nombres_objetos(T, Resto),
    append([Nombre], Resto, Objetos).
concat_propiedades_ancestros([], _, []).
concat_propiedades_ancestros([Ancestro|T], KB, [Propiedades|NuevoT]):-
    concat_propiedades_ancestros(T, KB, NuevoT),
    propiedades_solo_en_la_clase(Ancestro, KB, Propiedades).
append_lista_de_listas([], []).
append_lista_de_listas([H|T], X):-
    append(H, TLista, X),
    append_lista_de_listas(T, TLista).
propiedades_clase(top, KB, Propiedades):-
    propiedades_solo_en_la_clase(top, KB, Propiedades).
propiedades_clase(Clase, KB, Propiedades):-
    existe_clase(Clase, KB, yes),
    propiedades_solo_en_la_clase(Clase, KB, PropiedadesClase),
    append([PropiedadesClase], PropiedadesAncestros, TodasPropiedades),
    concat_propiedades_ancestros(Ancestros, KB, PropiedadesAncestros),
    lista_de_ancestros(Clase, KB, Ancestros),
    cancelar_valores_propiedad_repetidos(TodasPropiedades, Propiedades).
propiedades_clase(Clase, KB, unknown):-
    existe_clase(Clase, KB, unknown).
propiedades_objeto(Objeto, KB, TodasPropiedades):-
    existe_objeto(Objeto, KB, yes),
    propiedades_solo_en_el_objeto(Objeto, KB, PropiedadesObjeto),
    clase_de_objeto(Objeto, KB, Clase),
    propiedades_clase(Clase, KB, PropiedadesClase),
    append(PropiedadesObjeto, PropiedadesClase, Temp),
    eliminar_propiedades_repetidas(Temp, TodasPropiedades).
propiedades_objeto(_, _, unknown).
propiedades_solo_en_el_objeto(_, [], []).
propiedades_solo_en_el_objeto(Objeto, [class(_, _, _, _, O)|_], Propiedades):-
    esElemento([id=>Objeto, Propiedades, _], O).
propiedades_solo_en_el_objeto(Objeto, [_|T], Propiedades):-
    propiedades_solo_en_el_objeto(Objeto, T, Propiedades).
valor_propiedad_objeto(Objeto, Propiedad, KB, Valor):-
    existe_objeto(Objeto, KB, yes),
    propiedades_objeto(Objeto, KB, Propiedades),
    encontrar_valor(Propiedad, Propiedades, Valor).
valor_propiedad_objeto(_, _, _, unknown).
property_extension(Propiedad, KB, Resultado):-
    objetos_de_clase(top, KB, TodosObjetos),
    filtrar_objetos_con_propiedad(KB, Propiedad, TodosObjetos, Objetos),
    eliminar_propiedad_nula(Objetos, Resultado).
filtrar_objetos_con_propiedad(_, _, [], []).
filtrar_objetos_con_propiedad(KB, Propiedad, [H|T], [H:Valor|NuevoT]):-
    valor_propiedad_objeto(H, Propiedad, KB, Valor),
    filtrar_objetos_con_propiedad(KB, Propiedad, T, NuevoT).