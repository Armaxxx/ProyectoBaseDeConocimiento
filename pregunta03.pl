%----------------------------------------------------------
% Eliminación de clases, objetos, propiedades y relaciones
%-----------------------------------------------------------
/* Creación de predicados para eliminar 

a) Clases objetos
b) Propiedades específicas
c) Relaciones específicas
*/

/*
a) Eliminación Clases u objetos cuyo nombre 
será rm_class y rm_object, respectivamente. 
Ambos predicados recibirán tres argumentos: 
(i) el nombre de la clase u objeto a eliminar, 
(ii) la base de conocimientos actual,
(iii) la nueva base de conocimientos donde 
se refleja la eliminación.
*/

%--------------------------------------------------
% Load and Save from files
%--------------------------------------------------


%KB open and save


open_kb(KBPATH,KB):-
	open(KBPATH,read,Stream),
	readclauses(Stream,X),
	close(Stream),
	atom_to_term_conversion(X,KB).

save_kb(KBPATH,KB):-
	open(KBPATH,write,Stream),
	writeq(Stream,KB),
	close(Stream).

readclauses(InStream,W) :-
        get0(InStream,Char),
        checkCharAndReadRest(Char,Chars,InStream),
	atom_chars(W,Chars). 
 

checkCharAndReadRest(-1,[],_) :- !.  % End of Stream	
checkCharAndReadRest(end_of_file,[],_) :- !.

checkCharAndReadRest(Char,[Char|Chars],InStream) :-
        get0(InStream,NextChar),
        checkCharAndReadRest(NextChar,Chars,InStream).

atom_to_term_conversion(ATOM, TERM) :-
	 atom(ATOM),
	 atom_to_chars(ATOM,STR),
	 atom_to_chars('.',PTO),
	 append(STR,PTO,STR_PTO),
	 read_from_chars(STR_PTO,TERM).



/*Rerecusividad para eliminar 
Elimina recursivamente un elemento X contenido en una lista
*/
% Comprueba un elemento en la lista
isElement(X,[X|_]).
isElement(X,[_|T]):-
	isElement(X,T).
%elimina un elemento de la lista
deleteElement(_,[],[]).

deleteElement(X,[X|Y],Z):-
    deleteElement(X,Y,Z).

deleteElement(X,[Ca|Co],[Ca|Nco]):-
    deleteElement(X,Co,Nco),
	X\=Ca.

%modifica un elemento de la lista
changeElement(_,_,[],[]).

changeElement(X,Y,[X|Co],[Y|Nco]):-
	changeElement(X,Y,Co,Nco).

changeElement(X,Y,[Ca|Co],[Ca|Nco]):-
	changeElement(X,Y,Co,Nco).
/* elmina todos los elementos con una propiedad especifica*/
deleteAllElementsWithSameProperty(_,[],[]).

deleteAllElementsWithSameProperty(X,[X=>_|Co],Nco):-
	deleteAllElementsWithSameProperty(X,Co,Nco).

deleteAllElementsWithSameProperty(X,[Ca|Co],[Ca|Nco]):-
	deleteAllElementsWithSameProperty(X,Co,Nco).

/* elmina todos los elementos con una propiedad negada*/
deleteAllElementsWithSameNegatedProperty(_,[],[]).

deleteAllElementsWithSameNegatedProperty(X,[not(X=>_)|Co],Nco):-
	deleteAllElementsWithSameNegatedProperty(X,Co,Nco).

deleteAllElementsWithSameNegatedProperty(X,[Ca|Co],[Ca|Nco]):-
	deleteAllElementsWithSameNegatedProperty(X,Co,Nco).
	
	
%elimina las relaciones de los objetos
delete_relations_with_object(_,[],[]).

delete_relations_with_object(Object,[class(C,M,P,R,O)|Co],[class(C,M,P,NewR,NewO)|Nco]):-
	cancel_relation(Object,R,NewR),
	delete_relations(Object,O,NewO),
	delete_relations_with_object(Object,Co,Nco).


%elimina las relaciones
delete_relations(_,[],[]).

delete_relations(Object,[[id=>N,P,R]|Co],[[id=>N,P,NewR]|Nco]):-
	cancel_relation(Object,R,NewR),
	delete_relations(Object,Co,Nco).

cancel_relation(_,[],[]).

cancel_relation(Object,[_=>Object|Co],Nco):-
	cancel_relation(Object,Co,Nco).

cancel_relation(Object,[not(_=>Object)|Co],Nco):-
	cancel_relation(Object,Co,Nco).

cancel_relation(Object,[Ca|Co],[Ca|Nco]):-
	cancel_relation(Object,Co,Nco).
	

/* Cambio de clase de madre, se ocupara para sustiuir cuando se elimine una clase*/
changeMother(_,_,[],[]).
changeMother(Mother,NewMother,[class(C,Mother,P,R,O)|Co],[class(C,NewMother,P,R,O)|Nco]):-
	changeMother(Mother,NewMother,Co,Nco).

changeMother(Mother,NewMother,[Ca|Co],[Ca|Nco]):-
	changeMother(Mother,NewMother,Co,Nco).
/*3a*/
rm_object(O,KB,NewKB) :-
	changeElement(class(Class,Mother,P,R,Objects),class(Class,Mother,P,R,NewObjects),KB,Aux1KB),
	isElement([id=>O|Properties],Objects),
	deleteElement([id=>O|Properties],Objects,NewObjects),
	delete_relations_with_object(O,Aux1KB,NewKB).

rm_class(Class,KB,NewKB) :-
    deleteElement(class(Class,Mother,_,_,_),KB,Aux1KB),
	changeMother(Class,Mother,Aux1KB,Aux2KB),
	delete_relations_with_object(Class,Aux2KB,NewKB).

/*3b*/
rm_class_property(Class,Property,KB,NewKB) :-
	changeElement(class(Class,Mother,Ps,Rs,Os),class(Class,Mother,NewPs,Rs,Os),KB,NewKB),
	deleteAllElementsWithSameProperty(Property,Ps,Aux),
	deleteElement(not(Property),Aux,Aux2),
	deleteElement(Property,Aux2,NewPs).

rm_object_property(Object,Property,KB,NewKB) :-
	changeElement(class(Class,Mother,Ps,Rs,Os),class(Class,Mother,Ps,Rs,NewOs),KB,NewKB),
	isElement([id=>Object,Ps,Rs],Os),
	changeElement([id=>Object,Ps,Rs],[id=>Object,NewPs,Rs],Os,NewOs),
	deleteAllElementsWithSameProperty(Property,Ps,Aux),
	deleteElement(not(Property),Aux,Aux2),
	deleteElement(Property,Aux2,NewPs).
	
/*3c */
%relaciones de objeto específica
rm_object_relation(Object,not(Relation),KB,NewKB) :-
	changeElement(class(Class,Mother,Ps,Rs,Os),class(Class,Mother,Ps,Rs,NewOs),KB,NewKB),
	isElement([id=>Object,Ps,Rs],Os),
	changeElement([id=>Object,Ps,Rs],[id=>Object,Ps,NewRs],Os,NewOs),
	deleteAllElementsWithSameNegatedProperty(Relation,Rs,NewRs).
%relaciones de objeto negada
rm_object_relation(Object,Relation,KB,NewKB) :-
	changeElement(class(Class,Mother,Ps,Rs,Os),class(Class,Mother,Ps,Rs,NewOs),KB,NewKB),
	isElement([id=>Object,Ps,Rs],Os),
	changeElement([id=>Object,Ps,Rs],[id=>Object,Ps,NewRs],Os,NewOs),
	deleteAllElementsWithSameProperty(Relation,Rs,NewRs).
%relaciones de clase negada
rm_class_relation(Class,not(Relation),KB,NewKB) :-
	changeElement(class(Class,Mother,Ps,Rs,Os),class(Class,Mother,Ps,NewRs,Os),KB,NewKB),
	deleteAllElementsWithSameNegatedProperty(Relation,Rs,NewRs).
%relaciones de clase específica
rm_class_relation(Class,Relation,KB,NewKB) :- 
	changeElement(class(Class,Mother,Ps,Rs,Os),class(Class,Mother,Ps,NewRs,Os),KB,NewKB),
	deleteAllElementsWithSameProperty(Relation,Rs,NewRs).