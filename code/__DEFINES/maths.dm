#define NUM_E		2.71828183
#define PI			3.14159265
#define SQRT_2		1.41421356
#define INFINITY	1.#INF

#define QUANTIZE(variable) (round(variable, 0.0001))

#define CLAMP01(x) (clamp(x, 0, 1))

// Similar to clamp but the bottom rolls around to the top and vice versa. MIN is inclusive, MAX is exclusive.
#define WRAP(VAL, MIN, MAX) clamp((MIN == MAX ? MIN : VAL - (round((VAL - MIN) / (MAX - MIN)) * (MAX - MIN))), MIN, MAX)

#define CEILING(x, y) (-round(-(x) / (y)) * (y))