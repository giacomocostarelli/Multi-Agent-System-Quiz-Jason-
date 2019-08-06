// Agent quizmaster in project saluti.mas2j

/* Initial beliefs and rules */

question(1).
question(2).
question(3).
question(4).
question(5).
question(6).
question(7).
question(8).
question(9).

is_question_ready(false).
question_asked(0).

contestant_one_points(0).
contestant_two_points(0).
contestant_three_points(0).

interlocutor_points(0).

/* Initial goals */

!start.

/* Plans */

+!start: true <-
	!register_service;
	.wait(3000);
	.print("Io sono il Quizmaster e vi sottoporrò 3 domande: una risposta corretta corrisponde ad 1 punto, 0 altrimenti.");
	.wait(3000);
	.print("Chi otterrà più punti verrà proclamato come l'agente più INTELLIGENTE.");																									
	!prepare_question.

+!register_service : true <-
	 .df_register(ask_question);
	 .print("Benvenuti al Quiz Show più popolare tra gli Agenti! Chi vuole partecipare?").
	 
+!prepare_question : question_asked(N) & N < 4 <-
	.print("*Quizmaster pensa a una domanda...*")
	//random int in range [1,10].
	X = math.ceil(math.random(9));
	
	//L is the list containing the one question the quizmaster is gonna ask. In the form of list(answer(X)).
	.findall(answer(X), question(X), L);
	
	//Change BB for a question is ready.
	-is_question_ready(false);+is_question_ready(true);
	.print("Ci siamo! Ecco la domanda:");
	!ask_question(L,X).
	
+!ask_question(L,X): is_question_ready(true) <- 
	.wait(1000);
	.print("Qual è la risposta a question(", X, ")?");	
	
	//select the first item of the list L : the question.
	.nth(0, L, Question_to_send);
	.broadcast(achieve, search(Question_to_send));
	
	if (question_asked(Number) & Number < 4) {
		-question_asked(Number);+question_asked(Number+1);
	}
	
	-is_question_ready(true);+is_question_ready(false).
	
+answer_from_contestant[source(Contestant)] : true <-
	.wait(1000);
	.print("Molto bene! ", Contestant, " ha risposto correttamente e guadagna un punto!");
	
	if ( Contestant == contestant1 ) {-contestant_one_points(A)+contestant_one_points(A+1); }
	elif ( Contestant == contestant2 ) {-contestant_two_points(B);+contestant_two_points(B+1); }
	elif ( Contestant == contestant3 ) {-contestant_three_points(C);+contestant_three_points(C+1); }
	
	if(question_asked(Q) & Q < 4) {
		//remove the 'answer_from_contestant' belief in order to be processed again in successives iterations of the question-answer dialogue.
		.abolish(answer_from_contestant);
		!prepare_question;
	}elif (question_asked(Q) & Q == 4) {
		!endgame;
	}.
	
+!endgame : question_asked(Q) & Q = 4 <-
	//Finds the 3 lists containing the points of each contestant to merge em into 1, then chooses the member with more correct answers given.
	.findall(A,contestant_one_points(A),Contestant_one_points);
	.findall(B,contestant_two_points(B),Contestant_two_points);
	.findall(C,contestant_three_points(C),Contestant_three_points); 
	.concat(Contestant_one_points, Contestant_two_points, Contestant_three_points, Contestant_list)
	.max(Contestant_list,M);

	.nth(0, Contestant_list, One);
	.nth(1, Contestant_list, Two);
	.nth(2, Contestant_list, Three);
	
	if(One == M){
		Winner = contestant1;		
	}elif (Two == M) {
		Winner = contestant2;
	}elif (Three == M) {
		Winner = contestant3;
	}

	.print("Il quiz è finito! Il vincitore e'...");
	.wait(2000);
	.print(Winner);
	.print("Congratulazioni! Sei il nuovo agente più INTELLIGENTE!");
	!inform_winner(Winner).
	
+!inform_winner(Winner): question_asked(Q) & Q = 4 <-
	.broadcast(tell, the_winner_is(Winner)).
	
