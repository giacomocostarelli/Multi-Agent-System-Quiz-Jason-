// Agent contestant1 in project saluti.mas2j

/* Initial beliefs and rules */

answer(1).
answer(2).
answer(3).

/* Initial goals */

!start.

/* Plans */

+!start : true <- 
	 .df_register(answer_question);
	 .wait(1500);
	 .print("Voglio partecipare come concorrente al quiz.").

+!search(X): true <-
	//Search in the BB if it knows the answer in the form of 'answer(x)'. If it does it replies to the quizmaster, otherwise it doesn't.
	.count(X, N);
	if (N > 0) {
		.df_search("ask_question", Lista_dest);
		.nth(0, Lista_dest, Quizmaster);
		.wait(500);
		.print("So la risposta! E' ", X, "!");
		.send(Quizmaster, tell, answer_from_contestant);
		
	} else {
		.print("Non conosco la risposta...");
	}.
	
+the_winner_is(Winner)[source(Other)] : true <-
	.my_name(Me);
	.wait(3000);
	if(Winner == Me) {
		.print("...che emozione! Ho vinto!!!!!!");
	}else {
		.print(":(");
	}.
