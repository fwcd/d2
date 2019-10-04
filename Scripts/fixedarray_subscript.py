# A small script generating the fixed-size array subscripts.

INDENT_STEP = "    "
CAPACITY = 11

def alphabet(i):
    return chr(ord('a') + i)

def alphabet_until(n):
    return (alphabet(i) for i in range(n))

def alphabet_params_until(n):
    return "" if n == 0 else f"({', '.join(alphabet_until(n))})"

def gen_switch(value, n, indent_n, gen_case, default_case='default: fatalError()'):
    if n == 0:
        return "fatalError(\"Empty\")"
    else:
        indent = indent_n * INDENT_STEP
        next_indent = indent + INDENT_STEP
        cases = f"\n{next_indent}".join([gen_case(i, indent_n) for i in range(n)] + [default_case])
        return "switch " + value + " {\n" + next_indent + cases + "\n" + indent + "}"

def gen_subscript_get_index_case(i, indent_n):
    return f"case {i}: return {alphabet(i)}"

def gen_subscript_get_case(i, indent_n):
    default_case = 'default: fatalError("Index \\(n) is out of bounds")'
    return f"case let .len{i}{alphabet_params_until(i)}: {gen_switch('n', i, indent_n + 1, gen_subscript_get_index_case, default_case)}"

def gen_subscript_get():
    return "get {\n" + INDENT_STEP + gen_switch("self", CAPACITY, 1, gen_subscript_get_case) + "\n}"

print(gen_subscript_get())
