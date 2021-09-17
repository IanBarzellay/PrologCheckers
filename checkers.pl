%Checkers game

%Inputs:
%white queen position
%initGame(8),stoneMove("W",(3,1),(4,2)),drew(8),stoneMove("B",(6,4),(5,3)),stoneMove("B",(7,3),(6,4)),stoneMove("B",(6,4),(5,5)),stoneMove("B",(8,2),(7,3)),drew(8),stoneMove("W",(4,2),(6,4)),stoneMove("W",(6,4),(8,2)),drew(8).
%Black queem position
%initGame(8),stoneMove("W",(3,1),(4,2)),stoneMove("W",(4,2),(5,1)),stoneMove("W",(3,3),(4,4)),stoneMove("W",(2,4),(3,3)),stoneMove("W",(3,3),(4,2)),stoneMove("W",(1,3),(2,4)),drew(8),stoneMove("B",(6,4),(5,3)),stoneMove("B",(5,3),(3,1)),stoneMove("B",(3,1),(1,3)),drew(8)


:- dynamic(row/2).
:- dynamic(player/3).


start:-
    write("Enter the size of the board:"), nl, %TODO - add check if the board size is 8 or 10
    read(Size), nl,
    initGame(Size),
    write("The game begin with a white move."),nl,nl,
    game.

game:-
    game(player).

game(Player):-
    repeat,
    write("Please enter your move - position (X1,Y1) to (X2,Y2)"),nl,
    write("Enter the pawn position: "), read((X1,Y1)),nl,
    write("Enter the pawn target: "), read((X2,Y2)),nl,
    playerMove(Player, (X1,Y1),(X2,Y2)),
    drew(8),!,findWinner;
    otherPlayer(Player,P1),
    game(P1).



playerMove(P, (X1,Y1),(X2,Y2)):-
    player(P,Types,_),
    row(X1,Row),
    checkType(Type, Y1, Row),
    member(Type, Types),
    doMove(P,Type,(X1,Y1),(X2,Y2)).

doMove(P,Type,(X1,Y1),(X2,Y2)):-
    (Type = "B" ; Type = "W"),!,
    stoneMove(P,Type,(X1,Y1),(X2,Y2));
    queenMove(P,Type,(X1,Y1),(X2,Y2)).

otherPlayer(player,computer).
otherPlayer(computer,player).


initGame(BoardSize):-
    retractall(row(_,_)),
    retractall(player(_,_,_)),
    initGame(1,BoardSize),
    initPawns(BoardSize),
    drew(BoardSize),

    %TODO - static live for board 8 and 10.
    assert(player(player, ["W","WQ"], 12)),
    assert(player(computer, ["B","BQ"], 12)).

initGame(X,Y):-X>Y,!.
initGame(N,Size):-
    length(Row,Size),
    assert(row(N,Row)),
    N1 is N+1,
    initGame(N1,Size).

initPawns(Size):-
    Rows is ((Size / 2) - 1),
    initPawns(Rows, 1, Size).

initPawns(R,N,_):-N>R,!.
initPawns(R,N,S):-
        X is N mod 2,
        X = 1,!,(
            initRow("W",S,1,Res1),
            initRow("B",S,2,Res2),
            retract(row(N,_)),
            assert(row(N,Res1)),
            BPos is S + 1 - N,
            retract(row(BPos,_)),
            assert(row(BPos,Res2)),
            N1 is N+1,
            initPawns(R,N1,S)
        );(
            initRow("W",S,2,Res1),
            initRow("B",S,1,Res2),
            retract(row(N,_)),
            assert(row(N,Res1)),
            BPos is S + 1 - N,
            retract(row(BPos,_)),
            assert(row(BPos,Res2)),
            N1 is N+1,
            initPawns(R,N1,S)
        ).

initRow(_,0,_,[]):-!.

initRow(Type,Size,1,[Type|Res]):-
    NewSize is Size -1,!,
    initRow(Type,NewSize,2,Res).

initRow(Type,Size,2,[_W|Res]):-
    NewSize is Size -1,!,
    initRow(Type,NewSize,1,Res).

%------ Drew board to console
drew(0):-!.
drew(Size):-
    row(Size,Row),
    %write(Row),nl,  print all the row
    drewRow(Row),
    Size1 is Size - 1,!,
    drew(Size1).


drewRow([]):-nl,!.
drewRow([X|Xs]):-
    (   var(X),tab(1),write("#"),tab(1);
    (   X = "B",tab(1),write("B"),tab(1);
    tab(1),write(X))),
    drewRow(Xs).


%-------- Moves
stoneMove(_,Type,(X1,Y1),(X2,Y2)):-
    legalPos((X1,Y1),(X2,Y2)),
    normalMove(X1,X2),!,   
    row(X1,Row1),
    row(X2,Row2),
    checkType(Type,Y1,Row1),
    checkType(Res2,Y2,Row2),
    stoneLegalMove(Type,X1,X2),
    var(Res2),!,(
        retract(row(X1,_)),
        deleteType(Y1,Row1,NewRow1),
        assert(row(X1,NewRow1)),

        retract(row(X2,_)),
        changeType(Type,X2,Y2,Row2,NewRow2),
        assert(row(X2,NewRow2)),nl
    ).

stoneMove(Player,Type,(X1,Y1),(X2,Y2)):-
    legalPos((X1,Y1),(X2,Y2)),
    eatMove(X1,X2),!,( 
         (X1<X2,!,X3 is X1+1 ; X3 is X1-1),
         (Y1>Y2,!, Y3 is Y2+1; Y3 is Y2-1),
         row(X1,Row1),
         row(X2,Row2),
         row(X3,Row3),
         checkType(Type,Y1,Row1),
         checkType(Res2,Y2,Row2),
         checkType(Res3,Y3,Row3),                
         opponent(Type,Res3),
         var(Res2),!,(   
        retract(row(X1,_)),
        deleteType(Y1,Row1,NewRow1),
        assert(row(X1,NewRow1)),

        retract(row(X2,_)),
        changeType(Type,X2,Y2,Row2,NewRow2),
        assert(row(X2,NewRow2)),nl,
                         
        retract(row(X3,_)),
        deleteType(Y3,Row3,NewRow3),
        assert(row(X3,NewRow3)),

        damageOpponent(Player)
                    )              
    ).

queenMove(P,Type,(X1,Y1),(X2,Y2)):-
    legalPos((X1,Y1),(X2,Y2)),
    row(X1,Row1),
    row(X2,Row2),
    checkType(Type,Y1,Row1),
    checkType(Res2,Y2,Row2),
    (   var(Res2),!,
    (   X1>X2,!,(
        Y1>Y2,!,
        queenLegalMove(P,Type,X2,X1,Y2,Y1);
        queenLegalMove(P,Type,X2,X1,Y1,Y2)
    );(
        Y1>Y2,!,
        queenLegalMove(P,Type,X1,X2,Y2,Y1);
        queenLegalMove(P,Type,X1,X2,Y1,Y2)
    ))),retract(row(X1,_)),
        deleteType(Y1,Row1,NewRow1),
        assert(row(X1,NewRow1)),

        retract(row(X2,_)),
        changeType(Type,X2,Y2,Row2,NewRow2),
        assert(row(X2,NewRow2)),nl. 

checkType(Type,1,[Type|_]).
checkType(Type,N,[_|Tail]):-
    N1 is N-1,
    checkType(Type,N1,Tail).

deleteType(1,[_|Xs],[_|Xs]):-!.
deleteType(Pos,[X|Xs],[X|Ys]):-
    Pos1 is Pos-1,
    deleteType(Pos1,Xs,Ys).

changeType(Type,XPos,1,[_|Xs],[NewType|Xs]):-findType(Type,XPos,NewType),!.
changeType(Type,XPos,YPos,[X|Xs],[X|Ys]):-
    YPos1 is YPos-1,
    changeType(Type,XPos,YPos1,Xs,Ys).

normalMove(X,Y):- 
    R is X-Y,R = 1 ; 
    R is Y-X, R = 1.

eatMove(X,Y):-
    R is X-Y,R = 2 ; 
    R is Y-X, R = 2.

opponent(Player,Opp):-nonvar(Player),(Player="W";Player="QW"),nonvar(Opp),(   Opp="B";Opp="QB").
opponent(Player,Opp):-nonvar(Player),(Player="B";Player="QB"),nonvar(Opp),(   Opp="W";Opp="QW").

findType(Type,X,NewType):-
    Type = "W",
    X = 8,!,
    NewType = "QW";
    Type = "B",
    X = 1,!,
    NewType = "QB";
    Type = NewType.

%------ Check legal moves
legalPos((X1,Y1),(X2,Y2)):- N1 is (X1 mod 2), N1 =:= (Y1 mod 2), N2 is (X2 mod 2), N2 =:= (Y2 mod 2).

stoneLegalMove("W",X1,X2):-X1<X2.
stoneLegalMove("B",X1,X2):-X1>X2.


queenLegalMove(Player,Type,X1,X2,Y1,Y2):-
    X is X1 + 1,
    Y is Y2 - 1,
    X<X2,
    Y>Y1,
    row(X,Row),
    checkType(Type,Y,Row),
    (opponent(Player,Type),
     retract(row(X,_)),
     deleteType(Y,Row,NewRow3),
     assert(row(X,NewRow3)),
     damageOpponent(Player)
    ;var(Type)),
    queenLegalMove(Player,Type,X,X2,Y1,Y);
    X1 =:= (X2 - 1).

damageOpponent(Player):-
    otherPlayer(Player,Opp),
    player(Opp,Pawns,N),
    N1 is N-1,
    retract(player(Opp,_,_)),
    assert(player(Opp,Pawns,N1)),
    nl,write(Opp), write(" life: "), write(N1),nl.


%----- Find Winner
findWinner:-
    player(Player,_,0),
    otherPlayer(Player,Winner),
    write("The winner is - "), write(Winner), write("!!!"),nl.
