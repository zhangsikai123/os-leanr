#include <string.h>
#include <stdio.h> 
#include <stdlib.h>
#include <stdbool.h>

typedef struct {
	struct ode_t* next;
	int value;
}node_t;

int node_repr(node_t n){
	return n.value;
}

typedef struct LinkedList{
	node_t* head;
	node_t* tail;
}list;

node_t * init_node(int value){
	node_t * n = (node_t *) malloc(sizeof(node_t));
	n->value = value;
	n->next = NULL;
	return n;
}

list* init_linkedlist(int root_value){
	list * l = (list *) malloc(sizeof(list));
	node_t * head = init_node(root_value);
	l->head = head;
	l->tail = head;
	return l;
}


void print_list(list* l){
	node_t* cur = l->head;
	while(cur != NULL){
		printf("%d ->", cur->value);
		cur =  cur->next;
	}
}

void append(list * l, int v){
	node_t* n = init_node(v);
	l->tail->next = n;
	l->tail = n;
}

int main(){
	list * l = init_linkedlist(0);
	int i;
	for(i = 1; i< 10; i++){
		append(l, i);
	}
	print_list(l);
}    

