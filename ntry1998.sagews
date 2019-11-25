import collections
import random

#Parameters.
N = 503
p = 3
q = 239
df = 215
dg = 72
dr = 55

#R(N) quotient polynominal ring over Z.
Z.<x> = ZZ[]
RN = Z.quotient((x**N)-1, names='x')

#Rp(N) quotient ring over Fp.
Fp = GF(p)
Zp.<x> = PolynomialRing(GF(p))
Rp = Zp.quotient((x**N)-1, names='x')

#Rq(N) quotient ring over Fq.
Fq = GF(q)
Zq.<x> = PolynomialRing(Fq)
Rq = Zq.quotient((x**N)-1, names='x')

#Ternary polyonomianl generating function.
def poli(d1, d2, N):
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

#Central lift from defined as clq: Rq -> RN.
def clq(f):
    result = []
    for fi in f:
        if fi >= 0 and fi <= q//2:
            result.append(int(fi))
        else:
            result.append(int(fi) - q)
    return result

#Central lift from defined as clp: Rp -> RN.
def clp(f):
    result = []
    for fi in f:
        if fi >= 0 and fi <= p//2:
            result.append(int(fi))
        else:
            result.append(int(fi) - p)
    return result

#Key generation function returns set (priv, pub).
def key_gen():
    f, g = poli(df + 1, df, N), poli(dg, dg, N)
    fp = Rp(f)
    fq = Rq(f)

    fpi = fp**-1
    fqi = fq**-1
    gq = Rq(g)

    fqi_coefs = list(fqi)

    tmp_result = []

    for i in fqi_coefs:
        tmp_result.append((i * p) % q)

    h = Rq(tmp_result)

    h = h * gq
    return ((fq, fpi), h)

#Encryption function returnes ciphertext e.
def enc(pub, m):
    r = poli(dr, dr, N)
    m_in_Rq, r_in_Rq = Rq(m), Rq(r)
    e = r_in_Rq * pub + m_in_Rq
    return e

#Decryption function returnes decrypted message m.
def dec(priv, e):
    fq, fpi = priv
    aq = e * fq
    a = clq(list(aq))

    tmp_result = []

    for i in a:
        tmp_result.append(i % p)
    a = tmp_result

    mp = list(Rp(a) * fpi)

    m = clp(mp)
    return m

#Example of usage. Single cycle of generation, encryption and decryption.
def test():
    #GENERATING

    priv, pub = key_gen()

    #ENCRYPTION
    dm = 55
    m = poli(dm, dm, N)

    e = enc(pub, m)
    #DECRYPTION

    m_decrypted = dec(priv, e)
    if collections.Counter(m) == collections.Counter(m_decrypted):
        return True
    else:
        return False
