// Credits to Nickr5 for the useful procs I've taken from his library resource.

// min is inclusive, max is exclusive
/proc/Wrap(val, min, max)
	var/d = max - min
	var/t = floor((val - min) / d)
	return val - (t * d)

/proc/Default(a, b)
	return a ? a : b

// Trigonometric functions.
/proc/Csc(x)
	return 1 / sin(x)

/proc/Sec(x)
	return 1 / cos(x)

/proc/Cot(x)
	return 1 / tan(x)

/proc/Atan2(x, y)
	if(!x && !y)
		return 0
	var/a = arccos(x / sqrt(x * x + y * y))
	return y >= 0 ? a : -a

// Greatest Common Divisor: Euclid's algorithm.
/proc/Gcd(a, b)
	while (1)
		if(!b)
			return a
		a %= b
		if(!a)
			return b
		b %= a

// Least Common Multiple. The formula is a consequence of: a*b = LCM*GCD.
/proc/Lcm(a, b)
	return abs(a) * abs(b) / Gcd(a, b)

// Useful in the cases when x is a large expression, e.g. x = 3a/2 + b^2 + Function(c)
/proc/Square(x)
	return x * x

/proc/Inverse(x)
	return 1 / x

// Condition checks.
/proc/IsAboutEqual(a, b, delta = 0.1)
	return abs(a - b) <= delta

// Returns true if val is from min to max, inclusive.
/proc/IsInRange(val, min, max)
	return (val >= min) && (val <= max)

/proc/IsInteger(x)
	return floor(x) == x

/proc/IsMultiple(x, y)
	return x % y == 0

/proc/IsEven(x)
	return !(x & 0x1)

/proc/IsOdd(x)
	return (x & 0x1)

// Note: weight=0 returns a, weight=1 returns b, and weight=0.5 returns the mean of a and b.
/proc/Interpolate(a, b, weight = 0.5)
	return a + (b - a) * weight // Equivalent to: a*(1 - weight) + b*weight

/proc/Mean(...)
	var/sum = 0
	for(var/val in args)
		sum += val
	return sum / length(args)

// Returns the nth root of x.
/proc/Root(n, x)
	return x ** (1 / n)

// The quadratic formula. Returns a list with the solutions, or an empty list
// if they are imaginary.
/proc/SolveQuadratic(a, b, c)
	ASSERT(a)

	. = list()
	var/discriminant = b * b - 4 * a * c
	var/bottom = 2 * a

	// Return if the roots are imaginary.
	if(discriminant < 0)
		return

	var/root = sqrt(discriminant)
	. += (-b + root) / bottom
	// If discriminant == 0, there would be two roots at the same position.
	if(discriminant != 0)
		. += (-b - root) / bottom

/proc/ToDegrees(radians)
	// 180 / Pi ~ 57.2957795
	return radians * 57.2957795

/proc/ToRadians(degrees)
	// Pi / 180 ~ 0.0174532925
	return degrees * 0.0174532925

// Vector algebra.
/proc/squaredNorm(x, y)
	return x * x + y * y

/proc/norm(x, y)
	return sqrt(squaredNorm(x, y))

//Forces a variable to be posative
/proc/modulus(M)
	if(M >= 0)
		return M
	if(M < 0)
		return -M

//returns random gauss number
/proc/GaussRand(sigma)
	var/x, y, rsq
	do
		x = 2 * rand() - 1
		y = 2 * rand() - 1
		rsq = x * x + y * y
	while(rsq > 1 || !rsq)
	return sigma * y * sqrt(-2 * log(rsq) / rsq)

//returns random gauss number, rounded to 'roundto'
/proc/GaussRandRound(sigma, roundto)
	return round(GaussRand(sigma), roundto)