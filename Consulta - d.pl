classes_of_individual(Objeto, KB, Clases):-
    existe_objeto(Objeto, KB, yes),
    clase_de_un_objeto(Objeto, KB, Clase),
    ancestros_de_clase(Clase, KB, Ancestros),
    append([Clase], Ancestros, Clases).
classes_of_individual(_, _, unknown).