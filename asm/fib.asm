FUNC @fib
	arg n

_beginIf_1
	push n
	push_num 0
	cmple
jz _elseIf_1
	push_num 0
	ret ~

jmp _endIf_1
_elseIf_1
_endIf_1

_beginIf_2
	push n
	push_num 1
	cmpeq
jz _elseIf_2
	push_num 1
	ret ~

jmp _endIf_2
_elseIf_2
_endIf_2

	push n
	push_num 1
	sub
	call fib
	push n
	push_num 2
	sub
	call fib
	add
	ret ~

ENDFUNC

	push_num 100
	call fib
	print
