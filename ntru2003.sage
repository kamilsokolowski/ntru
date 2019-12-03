import collections
import random
import time
import numpy as np

#Parameters

N = 251

p = 2
q = 239
df = 72
dg = 72
dr = 72
dm = 72

gen_t = []
enc_t = []
dec_t = []

def timeit(method):
    def timed(*args, **kw):
        ts = time.time()
        result = method(*args, **kw)
        te = time.time()
        if 'log_time' in kw:
            name = kw.get('log_name', method.__name__.upper())
            kw['log_time'][name] = int((te - ts) * 1000)
        else:
            if method.__name__ == 'key_gen':
                gen_t.append((te - ts))
            if method.__name__ == 'enc':
                enc_t.append((te - ts))
            if method.__name__ == 'dec':
                dec_t.append((te - ts))
            #print '%r  %2.2f ms' % (method.__name__, (te - ts) * 1000)
        return result
    return timed

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
def poli(d1, N):
    lp = [i for i in range(N)]
    p = [0 for i in range(N)]
    ld1 = 0
    ld2 = 0
    while(d1 != ld1):
        tmp1 = random.choice(lp)
        element = p[tmp1]
        if element != 1 and element != -1:
            p[tmp1] = 1
            ld1 = ld1 + 1
    return p

#Central lift from defined as clq: Rq -> RN.
def clq(f):
    return [int(fi) if fi >= 0 and fi <= q//2 else int(fi) - q for fi in f]

#Central lift from defined as clp: Rp -> RN.
def clp(f):
    return [int(fi) if fi >= 0 and fi <= p//2 else int(fi) - p for fi in f]

#Key generation function returns set (priv, pub).
@timeit
def key_gen():
    f1 = poli(df, N)
    g = poli(dg, N)
    f = list(p * Rp(f1) + 1)
    fp = Rp(f)
    fq = Rq(f)
    fpi = fp**-1
    fqi = fq**-1

    h = Rq([(i * p) % q for i in list(fqi)]) * Rq(g)

    return ((fq, fpi), h)

#Encryption function returnes ciphertext e.
@timeit
def enc(pub, m):
    r = poli(dr, N)
    return Rq(r) * pub + Rq(m)

#Decryption function returnes decrypted message m.
@timeit
def dec(priv, e):
    fq, fpi = priv

    return clp(list(Rp([i % p for i in clq(list(e * fq))]) * fpi))

#Example of usage. Single cycle of generation, encryption and decryption.
def test():
    #GENERATING

    priv, pub = key_gen()

    #ENCRYPTION
    m = poli(dm, N)

    e = enc(pub, m)
    #DECRYPTION

    m_decrypted = dec(priv, e)
    if collections.Counter(m) == collections.Counter(m_decrypted):
        return True
    else:
        return False

#Running some iteration of test function to test if
#everthing works correctly.
succes = 0
failure = 0
for i in range(100):
    res = test()
    if res == True:
        succes += 1
    else:
        failure += 1

print("Succeses: {}".format(succes))
print("Failures: {}".format(failure))
print("Gen avarage: {0:.7f}".format(np.average(gen_t)))
print("Enc avarage: {0:.7f}".format(np.average(enc_t)))
print("Dec avarage: {0:.7f}".format(np.average(dec_t)))