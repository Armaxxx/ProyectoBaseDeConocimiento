
/*a*/
change_class_name(Class,NewName,KB,NewKB):-
	changeElement(class(Class,Mother,Ps,Rs,Os),class(NewName,Mother,Ps,Rs,Os),KB,Aux1KB),
	changeMother(Class,NewName,Aux1KB,Aux2KB),
	change_relations_with_object(Class,NewName,Aux2KB,NewKB).

change_object_name(Object,NewName,KB,NewKB) :-
    changeElement(class(Class,Mother,Ps,Rs,Os),class(Class,Mother,Ps,Rs,NewOs),KB,Aux1KB),
    isElement([id=>Object|Properties],Os),
    changeElement([id=>Object|Properties],[id=>NewName|Properties],Os,NewOs),
    change_relations_with_object(Object,NewName,Aux1KB,NewKB).


change_relations_with_object(_,_,[],[]).

change_relations_with_object(Object,NewName,[class(C,M,P,R,O)|Co],[class(C,M,P,NewR,NewO)|Nco]):-
    change_relations(Object,NewName,O,NewO),
    change_relation(Object,NewName,R,NewR),
    change_relations_with_object(Object,NewName,Co,Nco).

change_relations(_,_,[],[]).

change_relations(Object,NewName,[[id=>N,P,R]|Co],[[id=>N,P,NewR]|Nco]):-
    change_relation(Object,NewName,R,NewR),
    change_relations(Object,NewName,Co,Nco).

change_relation(_,_,[],[]).

change_relation(OldName,NewName,[R=>OldName|Co],[R=>NewName|Nco]):-
    change_relation(OldName,NewName,Co,Nco).

change_relation(OldName,NewName,[not(R=>OldName)|Co],[not(R=>NewName)|Nco]):-
    change_relation(OldName,NewName,Co,Nco).

change_relation(OldName,NewName,[Ca|Co],[Ca|Nco]):-
    change_relation(OldName,NewName,Co,Nco).

/* b)*/

change_value_object_property(Object,Property,NewValue,KB,NewKB):-
	rm_object_property(Object,Property,KB,Aux1KB),
	add_object_property(Object,Property,NewValue,Aux1KB,NewKB).

change_value_object_relation(Object,Relation,NewObjectRelated,KB,NewKB):-
	rm_object_relation(Object,Relation,KB,Aux1KB),
	add_object_relation(Object,Relation,NewObjectRelated,Aux1KB,NewKB).
		
change_value_class_property(Class,Property,NewValue,KB,NewKB):-
	rm_class_property(Class,Property,KB,Aux1KB),
	add_class_property(Class,Property,NewValue,Aux1KB,NewKB).

change_value_class_relation(Class,Relation,NewClassRelated,KB,NewKB):-
	rm_class_relation(Class,Relation,KB,Aux1KB),
	add_class_relation(Class,Relation,NewClassRelated,Aux1KB,NewKB).

add_class_relation(Class,NewRelation,OtherClass,OriginalKB,NewKB) :-
    changeElement(class(Class,Mother,Props,Rels,Objects),class(Class,Mother,Props,NewRels,Objects),OriginalKB,NewKB),
    append_relation(Rels,NewRelation,OtherClass,NewRels).

append_relation(Rels,not(NewRelation),OtherClass,NewRels):-
    append(Rels,[not(NewRelation=>OtherClass)],NewRels).

append_relation(Rels,NewRelation,OtherClass,NewRels):-
    append(Rels,[NewRelation=>OtherClass],NewRels).

add_object_relation(Object,NewRelation,OtherObject,KB,NewKB) :-
    changeElement(class(Class,Mother,Props,Rels,Objects),class(Class,Mother,Props,Rels,NewObjects),KB,NewKB),
    isElement([id=>Object,Properties,Relations],Objects),
    changeElement([id=>Object,Properties,Relations],[id=>Object,Properties,NewRelations],Objects,NewObjects),
    append_relation(Relations,NewRelation,OtherObject,NewRelations).
