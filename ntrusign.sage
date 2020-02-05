import random

# Parameters.
N = 13

p = 3
q = 7
df = 4
dg = 4
dm = 4

# Definition of structures used by NTRUsign scheme.

Z.<x> = ZZ[]
Zx1.<x1> = Z.quotient((x**N) - 1)

Q.<y> = QQ[]
Qy1.<y1> = Q.quotient((y**N) - 1)

Fq = GF(q)
Zq.<z> = PolynomialRing(Fq)
Rq.<z1> = Zq.quotient((z**N) - 1)

# Auxilary function for generating ternary polynomials.
def ternary_polynomial(d1, d2, N):
    lp = [i for i in range(N)]
    p = [0 for i in range(N)]
    ld1 = 0
    ld2 = 0
    while(d1!=ld1):
        tmp1 = random.choice(lp)
        element = p[tmp1]
        if element != 1 and element != -1:
            p[tmp1] = 1
            ld1 = ld1 + 1
    while(d2 != ld2):
        tmp2 = random.choice(lp)
        element = p[tmp2]
        if element != 1 and element != -1:
            p[tmp2] = -1
            ld2 = ld2 + 1
    return p

def message_polynomial(d1, d2, N):
    lp = [i for i in range(N)]
    p = [0 for i in range(N)]
    ld1 = 0
    ld2 = 0
    while(d1!=ld1):
        tmp1 = random.choice(lp)
        element = p[tmp1]
        if element != 1 and element != -1:
            p[tmp1] = randint(0, q)
            ld1 = ld1 + 1
    while(d2 != ld2):
        tmp2 = random.choice(lp)
        element = p[tmp2]
        if element != 1 and element != -1:
            p[tmp2] = -randint(0, q) % q
            ld2 = ld2 + 1
    return p

def cNe(a):
    return sum([ai ** 2 for ai in a]) - ((sum(a) ** 2)/len(a))

"""
    Gen function which generates keys used by NTRUsign scheme.
    Arguments:
        df - number of '1' and '-1' in polynomial f.
        dg - number of '1' and '-1' in polynomial g.
    Return:
        F, G, f, g - private component of key.
        h - public component of key.
"""
def gen(df, dg, N):
    f, g = ternary_polynomial(df + 1, df, N), ternary_polynomial(dg + 1, dg, N)
    r = gen_secound_step(f, g)
    while(r == False):
        f, g = ternary_polynomial(df + 1, df, N), ternary_polynomial(dg + 1, dg, N)
        r = gen_secound_step(f, g)
    F, G = r
    h = list((Rq(f) ** -1) * Rq(g))
    return (F, G, f, g, h)

# Secound step of generating function it is used to compute F and G.
def gen_secound_step(f, g):
    Rf, f1, _ = xgcd(Z(f), Z(x**N - 1))
    Rg, g1, _ = xgcd(Z(g), Z(x**N - 1))
    f1 = list(f1)
    g1 = list(g1)
    d, Sf, Sg = xgcd(Rf, Rg)
    if(d != 1):
        return False
    A = list(q * Sf * Z(f1))
    B = list(-q * Z(Sg) * Z(g1))
    if(Zx1(A) * Zx1(f) - Zx1(B) * Zx1(g) != q):
        return False
    f_inv = Qy1(f) ** -1
    g_inv = Qy1(g) ** -1
    C = (Qy1(B) * f_inv + Qy1(A) * g_inv) / 2
    C = Qy1(map(round, list(C)))
    F = list(Qy1(B) - C * Qy1(f))
    G = list(Qy1(A) - C * Qy1(g))
    return (F, G)

"""
    Sign function which signes message m.
    Arguments:
        F, G, f, g - private component of key.
        h - public component of key.
    Retrun:
        (s, sh) - signature vector
"""
def sign(m, F, G, f, g, h):
    m = map(lambda n : n % q, m)
    m1 = m[len(m)//2:]
    m2 = m[:len(m)//2]
    alpha1 = list(Qy1(m1) * Qy1(G) - Qy1(m2) * Qy1(F))
    alpha2 = list(-Qy1(m1) * Qy1(g) - Qy1(m2) * Qy1(f))
    beta1 = map(lambda a : round(a / q), alpha1)
    beta2 = map(lambda a : round(a / q), alpha2)
    s = list(Rq(list(Qy1(alpha1) * Qy1(f) + Qy1(alpha2) * Qy1(F))))
    sh = list(Rq(h) * (Rq(beta1) * Rq(f) + Rq(beta2) * Rq(F)))
    return (s, sh)

"""
    Verify function is used for verification of message m using
    (s ,sh) signature vector.
    Arguments:
        m - message to verify.
        (s ,sh) - signature vector.
    Retrun:
        d - norm of vector spanned betwen (m1, m2) and (s, sh).
"""
def verify(m, s, sh):
    m1 = m[len(m)//2:]
    m2 = m[:len(m)//2]
    d1 = cNe(list((Rq(m1) - Rq(s)) ** 2))
    d2 = cNe(list((Rq(m2) - Rq(sh)) ** 2))
    return math.sqrt(d1 + d2)
    
# Example of usage
"""
F, G, f, g, h = gen(df ,dg, N)
m = message_polynomial(dm, dm, N) + message_polynomial(dm, dm, N)
s, sh = sign(m, F, G, f, g, h)
print(verify(m, s, sh))
"""
