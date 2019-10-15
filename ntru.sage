import sage

N = 5

p = 3a
q = 17

# R(N) quotient polynominal ring over Z
Z.<x> = ZZ[]
RN = Z.quotient((x**N)-1, names='x')

# Rp quotient ring over Fp
Fp = GF(p)
Zp.<x> = PolynomialRing(GF(p))
Rp = Zp.quotient((x**N)-1, names='x')

# Rq quotient ring over Fq
Fq = GF(q)
Zq.<x> = PolynomialRing(Fq)
Rq = Zq.quotient((x**N)-1, names='x')

"""
print(Z)
print(RN.random_element())
print('-'*80)
print(Fp)
print(Rp.random_element())
print('-'*80)
print(Fq)
print(Rq.random_element())

print('-' * 80)
"""

factors = factor(x**N-1)

deg = [f[0].degree() for f in factors]

multi = 1 - (1/float(q^deg[0]))

for i in range(1, len(deg) - 1):
	multi *= 1 - (1/float(q^deg[i]))
	
f, q = R_q

print(multi)
